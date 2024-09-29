#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")] // hide console window on Windows in release
#![allow(rustdoc::missing_crate_level_docs)] // it's an example

mod data;
mod graphs;
use std::{f64::consts::TAU, time::Duration};

use eframe::egui::{
    self, remap, Color32, ComboBox, NumExt, Pos2, Response, ScrollArea, TextWrapMode,
};
use egui_extras::{Size, StripBuilder};
use egui_plot::{CoordinatesFormatter, Corner, Legend, Line, LineStyle, Plot, PlotPoints};
use graphs::Graphs;
use serialport::SerialPortInfo;

fn main() -> eframe::Result {
    env_logger::init(); // Log to stderr (if you run with `RUST_LOG=debug`).
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default().with_maximized(true),
        ..Default::default()
    };

    eframe::run_native(
        "BSLI Ground Control",
        options,
        Box::new(|cc| {
            // This gives us image support:
            egui_extras::install_image_loaders(&cc.egui_ctx);

            Ok(Box::<MyApp>::default())
        }),
    )
}

enum ConnectionStatus {
    NotConnected,
    Connecting,
    Failed,
    Connected,
    TimedOut,
}

struct MyApp {
    frame: egui::Frame,
    graphs: Graphs,
    connection_status: ConnectionStatus,
    selected_port: String,
}

impl MyApp {
    fn serial_port_connect(&mut self, path: String) {
        let port = serialport::new(path, 115_200)
            .timeout(Duration::from_millis(100))
            .open();

        if let Ok(port) = port {
            self.connection_status = ConnectionStatus::Connecting;
        } else {
            self.connection_status = ConnectionStatus::Failed;
        }
    }
}

impl Default for MyApp {
    fn default() -> Self {
        Self {
            frame: egui::Frame {
                inner_margin: 12.0.into(),
                outer_margin: 24.0.into(),
                rounding: 14.0.into(),
                shadow: egui::Shadow {
                    offset: [8.0, 12.0].into(),
                    blur: 16.0,
                    spread: 0.0,
                    color: egui::Color32::from_black_alpha(180),
                },
                fill: egui::Color32::from_rgba_unmultiplied(97, 0, 255, 128),
                stroke: egui::Stroke::new(1.0, egui::Color32::GRAY),
            },
            graphs: Graphs::default(),
            connection_status: ConnectionStatus::NotConnected,
            selected_port: "".to_string(),
        }
    }
}

impl eframe::App for MyApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        

        egui::SidePanel::left("egui_demo_panel")
            .resizable(false)
            .default_width(160.0)
            .min_width(160.0)
            .show(ctx, |ui| {
                ui.add_space(4.0);
                ui.vertical_centered(|ui| {
                    ui.heading("BSLI Ground Control");

                    ui.image(egui::include_image!("../assets/bsli_logo.png"));

                    ui.separator();

                    match (self.connection_status) {
                        ConnectionStatus::NotConnected => {
                            ui.label("GROUND CONTROL IS NOT CONNECTED");
                        }
                        ConnectionStatus::Connecting => {
                            ui.label("Connecting...");
                        }
                        ConnectionStatus::Connected => {
                            ui.label("Connected!");
                        }
                        ConnectionStatus::TimedOut => {
                            ui.label("Timed out.");
                        }
                        ConnectionStatus::Failed => {
                            ui.label("Connection failed :(");
                        }
                    }

                    let ports = serialport::available_ports();

                    match (ports) {
                        Ok(ports) => {
                            egui::ComboBox::from_id_salt("serial_port_selector")
                                .selected_text(self.selected_port.clone())
                                .show_ui(ui, |ui| {
                                    for p in ports {
                                        ui.selectable_value(
                                            &mut self.selected_port,
                                            p.port_name.clone(),
                                            p.port_name.clone(),
                                        );
                                    }
                                });
                        }
                        Err(e) => {
                            ui.label("Failed to find serial ports :(");
                        }
                    }

                    if self.selected_port != "" {
                        if (ui.add_sized(
                            (120.0, 40.0),
                            egui::Button::new(format!("CONNECT to {}", self.selected_port)),
                        ))
                        .clicked()
                        {
                            self.serial_port_connect(self.selected_port.clone());
                        }
                    }
                });

                ui.separator();
            });

        egui::TopBottomPanel::top("menu_bar").show(ctx, |ui| {
            egui::menu::bar(ui, |ui| {
                ui.menu_button("File", |ui| {
                    ui.style_mut().wrap_mode = Some(egui::TextWrapMode::Extend);

                    if ui.add(egui::Button::new("Connect")).clicked() {
                        ui.close_menu();
                    }
                });
            });
        });

        egui::CentralPanel::default().show(ctx, |ui| {
            self.graphs.ui(ctx);
        });
    }
}
