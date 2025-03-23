#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")] // hide console window on Windows in release

mod data;
mod plot_tab;
mod serial_connection;

use std::{collections::VecDeque, io::Cursor};
use std::mem::size_of;

use data::{Data, DataSeries};
use serial_connection::SerialConnection; 
use eframe::egui::{self};
use plot_tab::PlotTab;
use serialport::SerialPortInfo;

// G to m/s^2
fn scale_G_to_mps2(val: f64) -> f64 {
    const G: f64 = 9.81;
    val as f64 * G
}

fn main() -> eframe::Result {
    env_logger::init(); // Log to stderr (if you run with `RUST_LOG=debug`).

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
        Box::new(|cc| Ok(Box::new(GroundControlApp::new(cc)))),
    )
}

#[derive(PartialEq)]
enum AppTab {
    Plot,
}

#[repr(C, packed)]
#[derive(Clone)]
struct TelemetryPacket {
    magic: [u8; 9], // 'FUCKPETER' in ASCII with no null terminator
    size: u8, // Total size of struct
    crc16: u16, // CRC16 
    status_flags: u8, // StatusFlags bitfield
    time_boot_ms: u32, // Timestamp (ms since system boot)
    ms5607_pressure_mbar: f32, // MS5607 Air Pressure
    ms5607_temperature_c: f32, // MS5607 Temperature
    bmi323_accel_x: f32, // BMI323 Acceleration X
    bmi323_accel_y: f32, // BMI323 Acceleration Y
    bmi323_accel_z: f32, // BMI323 Acceleration Z
    bmi323_gyro_x: f32, // BMI323 Gyroscope X
    bmi323_gyro_y: f32, // BMI323 Gyroscope Y
    bmi323_gyro_z: f32, // BMI323 Gyroscope Z
    adxl375_accel_x: f32, // ADXL375 Acceleration X
    adxl375_accel_y: f32, // ADXL375 Acceleration Y
    adxl375_accel_z: f32, // ADXL375 Acceleration Z
}

struct TelemetryDecoder {
    data: [u8; size_of::<TelemetryPacket>()],
    data_pos: usize
}

impl TelemetryDecoder {
    const MAGIC: &'static [u8] = "FUCKPETER".as_bytes();

    fn new() -> Self {
        Self {
            data: [0; size_of::<TelemetryPacket>()],
            data_pos: 0,
        }
    }

    fn decode(&mut self, byte: u8) -> Option<TelemetryPacket> {
        if self.data_pos < TelemetryDecoder::MAGIC.len() {
            self.data[self.data_pos] = byte;

            if byte == TelemetryDecoder::MAGIC[self.data_pos] {
                self.data_pos += 1;
            } else {
                self.data_pos = 0;
            }
        } else {
            // decode the packet!!!
            self.data[self.data_pos] = byte;
            self.data_pos += 1;

            if self.data_pos >= size_of::<TelemetryPacket>() {
                self.data_pos = 0;

                // Cast array to telemetry packet :sob: 
                let ptr = &mut self.data;
                let packet = unsafe { &mut *(ptr as *mut [u8; size_of::<TelemetryPacket>()] as *mut TelemetryPacket) };

                // extern crate hexdump;
                // hexdump::hexdump(&self.data);

                let packet_crc16 = packet.crc16;
                // the crc16 in the packet is the CRC of the packet data with the crc16 field zeroed out
                packet.crc16 = 0;
                const crc16: crc::Crc<u16> = crc::Crc::<u16>::new(&crc::CRC_16_MODBUS);
                let calculated_crc16 = crc16.checksum(&self.data);
                if calculated_crc16 != packet_crc16 {
                    println!("warning: Telemetry packet CRC16 mismatch. In packet: {:#x} Calculated: {:#x}", packet_crc16, calculated_crc16);
                    return None;
                }

                return Some(packet.clone());
            }
        }

        None
    }
}

struct GroundControlApp {
    plot_tab: PlotTab,

    data: data::Data,

    serial: SerialConnection,
    telemetry_decoder: TelemetryDecoder,

    ui_showsidebar: bool,
    ui_selected_tab: AppTab,

    frame_count: u64,
    packets_received: u32,
}

impl GroundControlApp {
    /// Called once before the first frame.
    pub fn new(cc: &eframe::CreationContext<'_>) -> Self {
        // This is also where you can customize the look and feel of egui using
        // `cc.egui_ctx.set_visuals` and `cc.egui_ctx.set_fonts`.

        // Load previous app state (if any).
        // Note that you must enable the `persistence` feature for this to work.
        // if let Some(storage) = cc.storage {
        //     return eframe::get_value(storage, eframe::APP_KEY).unwrap_or_default();
        // }

        let mut app = Self {
            plot_tab: PlotTab::new(),

            data: Data::new(),

            serial: serial_connection::SerialConnection::new(),
            telemetry_decoder: TelemetryDecoder::new(),

            ui_showsidebar: true,
            ui_selected_tab: AppTab::Plot,

            frame_count: 0,
            packets_received: 0,
        };

        app.serial.refresh_known_ports();

        app
    }

    fn ui_add_serialportui(&mut self, ui: &mut egui::Ui) {
        let settings_isenabled = self.serial.connection_allowed();
        let connect_isenabled =
            self.serial.connection_allowed() && !self.serial.selected_port.is_empty();
        let disconnect_isenabled = self.serial.disconnection_allowed();

        // port settings
        ui.add_enabled_ui(settings_isenabled, |ui| {
            // port selection
            ui.horizontal(|ui| {
                GroundControlApp::ui_draw_serialportdropdown(
                    ui,
                    &mut self.serial.known_ports,
                    &mut self.serial.selected_port,
                );
                ui.label("Port");
                if ui.button("Refresh").clicked() {
                    self.serial.refresh_known_ports();
                }
            });

            // baud rate
            egui::ComboBox::from_label("Baud rate")
                .selected_text(format!("{}", self.serial.baud_rate))
                .show_ui(ui, |ui| {
                    ui.selectable_value(&mut self.serial.baud_rate, 50, "50");
                    ui.selectable_value(&mut self.serial.baud_rate, 75, "75");
                    ui.selectable_value(&mut self.serial.baud_rate, 110, "110");
                    ui.selectable_value(&mut self.serial.baud_rate, 134, "134");
                    ui.selectable_value(&mut self.serial.baud_rate, 150, "150");
                    ui.selectable_value(&mut self.serial.baud_rate, 200, "200");
                    ui.selectable_value(&mut self.serial.baud_rate, 300, "300");
                    ui.selectable_value(&mut self.serial.baud_rate, 600, "600");
                    ui.selectable_value(&mut self.serial.baud_rate, 1200, "1200");
                    ui.selectable_value(&mut self.serial.baud_rate, 1800, "1800");
                    ui.selectable_value(&mut self.serial.baud_rate, 2400, "2400");
                    ui.selectable_value(&mut self.serial.baud_rate, 4800, "4800");
                    ui.selectable_value(&mut self.serial.baud_rate, 9600, "9600");
                    ui.selectable_value(&mut self.serial.baud_rate, 19200, "19200");
                    ui.selectable_value(&mut self.serial.baud_rate, 28800, "28800");
                    ui.selectable_value(&mut self.serial.baud_rate, 38400, "38400");
                    ui.selectable_value(&mut self.serial.baud_rate, 57600, "57600");
                    ui.selectable_value(&mut self.serial.baud_rate, 76800, "76800");
                    ui.selectable_value(&mut self.serial.baud_rate, 115200, "115200");
                    ui.selectable_value(&mut self.serial.baud_rate, 230400, "230400");
                    ui.selectable_value(&mut self.serial.baud_rate, 460800, "460800");
                    ui.selectable_value(&mut self.serial.baud_rate, 576000, "576000");
                    ui.selectable_value(&mut self.serial.baud_rate, 921600, "921600");
                });
        });

        // status
        ui.label(format!(
            "Status: {}",
            match self.serial.connection_status() {
                serial_connection::Status::Connected => "Connected",
                serial_connection::Status::Connecting => "Connecting...",
                serial_connection::Status::Disconnected => "Disconnected",
                serial_connection::Status::Disconnecting => "Disconnecting...",
                serial_connection::Status::Failed => "Failed",
            }
        ));
        ui.label(format!("Bytes read: {}", self.serial.bytes_read()));
        ui.label("Error rate: 0% (placeholder)");

        // connect/disconnect buttons
        ui.horizontal(|ui| {
            ui.add_enabled_ui(connect_isenabled, |ui| {
                if ui.button("Connect").clicked() {
                    self.serial.connect(self.serial.selected_port.clone());
                }
            });

            ui.add_enabled_ui(disconnect_isenabled, |ui| {
                if ui.button("Disconnect").clicked() {
                    self.serial.disconnect();
                }
            });
        });
    }

    fn ui_draw_serialportdropdown(
        ui: &mut egui::Ui,
        availableports: &mut Vec<SerialPortInfo>,
        selectedport: &mut String,
    ) {
        egui::ComboBox::from_id_salt("serialport-name")
            .selected_text(selectedport.clone())
            .show_ui(ui, |ui| {
                for p in availableports {
                    ui.selectable_value(selectedport, p.port_name.clone(), p.port_name.clone());
                    // TODO: cloning port info every time is probably horrible lol
                }
            });
    }
}

impl eframe::App for GroundControlApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        self.frame_count += 1;

        /* Read all pending data from serial port buffer and place in recieve buffer */
        loop {
            if let Ok(b) = self.serial.read_byte() {
                if let Some(p) = self.telemetry_decoder.decode(b) {
                    self.packets_received += 1;
                    
                    let t: f64 = p.time_boot_ms as f64 / 1000.0; 
                    let time_boot_ms = p.time_boot_ms;
                    self.data.ms5607_pressure_mbar.add_point(t, p.ms5607_pressure_mbar as f64);
                    self.data.ms5607_temperature_c.add_point(t, p.ms5607_temperature_c as f64);
                    self.data.bmi323_accel_x.add_point(t, scale_G_to_mps2(p.bmi323_accel_x as f64));
                    self.data.bmi323_accel_y.add_point(t, scale_G_to_mps2(p.bmi323_accel_y as f64));
                    self.data.bmi323_accel_z.add_point(t, scale_G_to_mps2(p.bmi323_accel_z as f64));
                    self.data.bmi323_gyro_x.add_point(t, p.bmi323_gyro_x as f64);
                    self.data.bmi323_gyro_y.add_point(t, p.bmi323_gyro_y as f64);
                    self.data.bmi323_gyro_z.add_point(t, p.bmi323_gyro_z as f64);
                    self.data.adxl375_accel_x.add_point(t, scale_G_to_mps2(p.adxl375_accel_x as f64));
                    self.data.adxl375_accel_y.add_point(t, scale_G_to_mps2(p.adxl375_accel_y as f64));
                    self.data.adxl375_accel_z.add_point(t, scale_G_to_mps2(p.adxl375_accel_z as f64));

                    self.data.status_flag_recovery_armed = p.status_flags & (1 << 0) != 0;
                    self.data.status_flag_ematch_drogue_deployed = p.status_flags & (1 << 1) != 0;
                    self.data.status_flag_ematch_main_deployed = p.status_flags & (1 << 2) != 0;
                    self.data.status_flag_sd_card_working = p.status_flags & (1 << 3) != 0;
                }
            } else {
                break;
            }
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
            });
        });

        egui::SidePanel::left("sidebar")
            .resizable(false)
            .default_width(160.0)
            .min_width(160.0)
            .show_animated(ctx, self.ui_showsidebar, |ui| {
                // ui.add_space(4.0);
                egui::ScrollArea::vertical().show(ui, |ui| {
                    // serial port connection ui
                    ui.collapsing("Info", |ui| {
                        ui.label(format!("UI frame count: {}", self.frame_count));
                    });

                    ui.collapsing("Serial port", |ui| {
                        self.ui_add_serialportui(ui);
                    });

                    ui.collapsing("Logging", |ui| {
                        ui.label("placeholder");
                    });

                    ui.collapsing("Telemetry", |ui| {
                        ui.label(format!("Packets received: {}", self.packets_received));
                        ui.label("Error rate: 0% (placeholder)");
                    });

                    ui.collapsing("Data", |ui| {
                        egui::Grid::new("sidebar-data-grid")
                            .num_columns(2)
                            .striped(true)
                            .show(ui, |ui| {
                                let mut display_data_series_label = |s: &DataSeries| {
                                    ui.label(format!("{}:", s.name));
                                    ui.label(format!("{} {}", s.last_y_str(), s.units));
                                    ui.end_row();
                                };

                                display_data_series_label(&self.data.ms5607_pressure_mbar);
                                display_data_series_label(&self.data.ms5607_temperature_c);
                                display_data_series_label(&self.data.bmi323_accel_x);
                                display_data_series_label(&self.data.bmi323_accel_y);
                                display_data_series_label(&self.data.bmi323_accel_z);
                                display_data_series_label(&self.data.bmi323_gyro_x);
                                display_data_series_label(&self.data.bmi323_gyro_y);
                                display_data_series_label(&self.data.bmi323_gyro_z);
                                display_data_series_label(&self.data.adxl375_accel_x);
                                display_data_series_label(&self.data.adxl375_accel_y);
                                display_data_series_label(&self.data.adxl375_accel_z);

                                ui.label("SD Card Working");
                                ui.label(format!("{}", self.data.status_flag_sd_card_working));
                                ui.end_row();
                            });
                    });
                });
            });

        egui::CentralPanel::default().show(ctx, |ui| match self.ui_selected_tab {
            AppTab::Plot => {
                self.plot_tab.ui(ui, &self.data);
            }
        });
    }
}
