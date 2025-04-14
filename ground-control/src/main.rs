#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")] // hide console window on Windows in release

mod dashboard_tab;
mod data;
mod plot_tab;
mod serial_connection;
mod sidebar;
mod telemetry;
mod vis3d;
mod data_log_replay;

use std::env;
use std::mem::size_of;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::time::Instant;
use std::{collections::VecDeque, io::Cursor};

use data::{Data, DataSeries};
use data_log_replay::DataLogV1;
use eframe::egui::{self};
use egui::RichText;
use ground_control::FusionAhrs;
use image::open;
use serial_connection::SerialConnection;
use serialport::SerialPortInfo;
use telemetry::{LogPacketV1, TelemetryDecoder, TelemetryPacket};
use vis3d::RotatingTriangle;

use crate::telemetry::TelemetryDecoderResult::Packet;

// G to m/s^2
fn G_to_mps2(val: f64) -> f64 {
    const G: f64 = 9.81;
    val as f64 * G
}

fn main() -> eframe::Result {
    env_logger::init(); // Log to stderr (if you run with `RUST_LOG=debug`).

    let args: Vec<String> = env::args().collect();
    let open_data_log_path = args.get(1);

    let native_options = eframe::NativeOptions {
        vsync: false,
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([400.0, 300.0])
            .with_min_inner_size([300.0, 220.0])
            .with_icon(
                // NOTE: Adding an icon is optional
                eframe::icon_data::from_png_bytes(&include_bytes!("assets/bsli_logo.png")[..])
                    .expect("Failed to load icon"),
            ),
        ..Default::default()
    };
    eframe::run_native(
        "BSLI IREC Ground Control",
        native_options,
        Box::new(|cc| Ok(Box::new(GroundControlApp::new(cc, open_data_log_path.cloned())))),
    )
}

#[derive(PartialEq)]
enum AppTab {
    Plot,
    Dashboard,
}

struct GroundControlApp {
    data: data::Data,

    last_t: Instant,

    serial: SerialConnection,
    telemetry_decoder: TelemetryDecoder<TelemetryPacket>,

    ui_showsidebar: bool,
    ui_selected_tab: AppTab,

    frame_count: u64,

    rocket_angle_ema: f32,

    last_packet_fc_time: f64,
    triangle: Arc<Mutex<RotatingTriangle>>,
    triangle_angle: f32,

    data_log: Option<DataLogV1>,
    data_log_status: RichText,
    data_log_replay_time_ms: f64,
    data_log_replay_playing: bool,
    data_log_replay_next_packet_index: usize,
}

impl GroundControlApp {
    /// Called once before the first frame.
    pub fn new(cc: &eframe::CreationContext<'_>, open_data_log_path: Option<String>) -> Self {
        egui_extras::install_image_loaders(&cc.egui_ctx);

        // This is also where you can customize the look and feel of egui using
        // `cc.egui_ctx.set_visuals` and `cc.egui_ctx.set_fonts`.

        // Load previous app state (if any).
        // Note that you must enable the `persistence` feature for this to work.
        // if let Some(storage) = cc.storage {
        //     return eframe::get_value(storage, eframe::APP_KEY).unwrap_or_default();
        // }

        let gl = cc
            .gl
            .as_ref()
            .expect("You need to run eframe with the glow backend");

        let mut app = Self {
            data: Data::new(),

            last_t: Instant::now(),

            serial: serial_connection::SerialConnection::new(),
            telemetry_decoder: TelemetryDecoder::new(),

            ui_showsidebar: true,
            ui_selected_tab: AppTab::Plot,

            frame_count: 0,

            rocket_angle_ema: 0.0,
            last_packet_fc_time: 0.0,
            triangle: Arc::new(Mutex::new(RotatingTriangle::new(gl))),
            triangle_angle: 0.0,

            data_log: None,
            data_log_status: RichText::new(""),
            data_log_replay_time_ms: 0.,
            data_log_replay_playing: false,
            data_log_replay_next_packet_index: 0,
        };

        if let Some(open_data_log_path) = open_data_log_path {
            app.open_data_log_v1(open_data_log_path.into());
        }
        
        app.serial.refresh_known_ports();

        app
    }
}

impl eframe::App for GroundControlApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        self.frame_count += 1;

        let t = Instant::now();
        let t_elapsed = t - self.last_t;
        self.last_t = t;

        /* Read all pending data from serial port buffer and place in recieve buffer */
        loop {
            if let Ok(b) = self.serial.read_byte() {
                if let Packet(p) = self.telemetry_decoder.decode(b) {
                    let t: f64 = p.time_boot_ms as f64 / 1000.0;

                    // Reset all data if flight computer time goes backwards
                    if t < self.last_packet_fc_time {
                        self.data = Data::new();
                    }
                    self.last_packet_fc_time = t;

                    self.data.euler_a.add_point(t, p.euler_a as f64);
                    self.data.euler_b.add_point(t, p.euler_b as f64);
                    self.data.euler_y.add_point(t, p.euler_y as f64);
                    self.data
                        .fused_accel_magnitude
                        .add_point(t, G_to_mps2(p.accel_magnitude as f64));
                    self.data
                        .ms5607_pressure_mbar
                        .add_point(t, p.ms5607_pressure_mbar as f64);

                    self.data.status_flag_recovery_armed = p.status_flags & (1 << 0) != 0;
                    self.data.status_flag_ematch_drogue_deployed = p.status_flags & (1 << 1) != 0;
                    self.data.status_flag_ematch_main_deployed = p.status_flags & (1 << 2) != 0;
                    self.data.status_flag_sd_card_degraded = p.status_flags & (1 << 3) != 0;
                    self.data.status_flag_adxl375_degraded = p.status_flags & (1 << 4) != 0;
                    self.data.status_flag_bm1422_degraded = p.status_flags & (1 << 5) != 0;
                    self.data.status_flag_bmi323_degraded = p.status_flags & (1 << 6) != 0;
                    self.data.status_flag_ms5607_degraded = p.status_flags & (1 << 7) != 0;
                }
            } else {
                break;
            }
        }

        if self.data_log_replay_playing {
            self.replay_until_time_ms(self.data_log_replay_time_ms + t_elapsed.as_secs_f64() * 1000.0);
        }

        /* Make sure packets are read at least every 0.1 seconds */
        ctx.request_repaint_after_secs(0.1);

        egui::TopBottomPanel::top("menubar").show(ctx, |ui| {
            egui::menu::bar(ui, |ui| {
                ui.label("BSLI Ground Control");

                ui.separator();

                ui.menu_button("File", |ui| {
                    ui.style_mut().wrap_mode = Some(egui::TextWrapMode::Extend);

                    if ui.add(egui::Button::new("Placeholder")).clicked() {
                        ui.close_menu();
                    }
                    if ui.add(egui::Button::new("Placeholder")).clicked() {
                        ui.close_menu();
                    }
                    if ui.add(egui::Button::new("Placeholder")).clicked() {
                        ui.close_menu();
                    }
                });

                egui::global_theme_preference_switch(ui);

                ui.separator();

                ui.toggle_value(&mut self.ui_showsidebar, "Sidebar");
                ui.selectable_value(&mut self.ui_selected_tab, AppTab::Plot, "Plot");
                ui.selectable_value(&mut self.ui_selected_tab, AppTab::Dashboard, "Dashboard");
            });
        });

        egui::SidePanel::left("sidebar")
            .resizable(false)
            .default_width(160.0)
            .min_width(160.0)
            .show_animated(ctx, self.ui_showsidebar, |ui| {
                self.sidebar(ui);
            });

        egui::CentralPanel::default().show(ctx, |ui| match self.ui_selected_tab {
            AppTab::Plot => {
                self.plot_tab(ui);
            }
            AppTab::Dashboard => {
                self.dashboard_tab(ui);
            }
        });
    }
}
