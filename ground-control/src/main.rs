#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")] // hide console window on Windows in release

mod data;
mod plottab;
mod livetab;
mod serialconnection;
use data::Data;
use livetab::LiveTab;
use std::io::BufRead;
use rand;

use log::{debug, info, error};

use eframe::egui;
use egui_extras;
use plottab::PlotTab;
use serialport::SerialPortInfo;

fn main() -> eframe::Result {
    env_logger::init();

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

#[derive(PartialEq)]
enum AppTab {
    Plot,
    Live,
    Trajectory, // TODO: 3d flight altitude and gps visualization
    Network, // TODO: packet log
}

struct MyApp {
    frame: egui::Frame,
    tab_plot: plottab::PlotTab,
    tab_live: livetab::LiveTab,

    data: data::Data,
    data_t: f64,

    serialconnection: serialconnection::SerialConnection,

    // TODO: clean up relationship between activeport and selectedport
    // TODO: clean up representation of port status (ConnectionStatus vs. Option vs. Result, etc.)
    serialport_knownports: Vec<SerialPortInfo>,
    serialport_selectedport: String, // the name of the port selected in the ui, "" if not connected
    serialport_baudrate: u32,
    serialport_databits: serialport::DataBits,
    serialport_parity: serialport::Parity,
    serialport_stopbits: serialport::StopBits,

    serialport_messages: Vec<String>,

    ui_showsidebar: bool,
    ui_selectedtab: AppTab,
}

impl MyApp {
    fn serialport_connect(&mut self) {
        self.serialconnection.connect(
            self.serialport_selectedport.clone(),
            self.serialport_baudrate,
            self.serialport_databits,
            self.serialport_parity,
            self.serialport_stopbits,
            100);
    }

    fn serialport_disconnect(&mut self) {
        self.serialconnection.disconnect();
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

            tab_plot: PlotTab::new(),
            tab_live: LiveTab::new(),

            data: Data::new(),
            data_t: 0.0,

            serialconnection: serialconnection::SerialConnection::new(),

            serialport_knownports: Vec::new(),
            serialport_selectedport: "".to_string(),
            serialport_baudrate: 9600,
            serialport_databits: serialport::DataBits::Eight,
            serialport_parity: serialport::Parity::None,
            serialport_stopbits: serialport::StopBits::One,

            serialport_messages: Vec::new(),

            ui_showsidebar: true,
            ui_selectedtab: AppTab::Plot,
        }
    }
}

impl eframe::App for MyApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {

        // read serialport
        // TODO: move to another thread
        match &mut self.serialconnection.reader {
            Some(r) => {
                let mut buffer = String::new();
                let _ = r.read_line(&mut buffer);
                let _ = buffer.pop(); // remove trailing '\n'
                self.serialport_messages.push(buffer);
            },
            None => {},
        }

        // add fake data
        self.data.altitude.add_point(self.data_t, rand::random::<f64>() * 30000.0);
        self.data.airpressure.add_point(self.data_t, rand::random::<f64>() * 100.0);
        self.data.acceleration_x.add_point(self.data_t, rand::random::<f64>() * 100.0);
        self.data.acceleration_y.add_point(self.data_t, rand::random::<f64>() * 1000.0);
        self.data.acceleration_z.add_point(self.data_t, rand::random::<f64>() * 100.0);
        self.data_t += 0.1 / 60.0;

        egui::TopBottomPanel::top("menubar").show(ctx, |ui| {
            egui::menu::bar(ui, |ui| {
                ui.label("BSLI Ground Control");

                // ui.add_space(8.0);
                ui.separator();
                // ui.add_space(8.0);

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

                ui.menu_button("Options", |ui| {
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

                ui.menu_button("Help", |ui| {
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

                // ui.add_space(8.0);
                ui.separator();
                // ui.add_space(8.0);

                ui.toggle_value(&mut self.ui_showsidebar, "Sidebar");
                ui.selectable_value(&mut self.ui_selectedtab, AppTab::Plot, "Plot");
                ui.selectable_value(&mut self.ui_selectedtab, AppTab::Live, "Live");
                ui.selectable_value(&mut self.ui_selectedtab, AppTab::Trajectory, "Trajectory");
                ui.selectable_value(&mut self.ui_selectedtab, AppTab::Network, "Network");
            });
        });

        egui::SidePanel::left("sidebar")
            .resizable(false)
            .default_width(160.0)
            .min_width(160.0)
            .show_animated(ctx, self.ui_showsidebar, |ui| {
                // ui.add_space(4.0);
                egui::ScrollArea::vertical()
                    .show(ui, |ui| {

                    // serial port connection ui
                    ui.collapsing("Serial port", |ui| {
                        ui_add_serialportui(ui, self);
                    });

                    ui.collapsing("Logging", |ui| {
                        ui.label("placeholder");
                    });

                    ui.collapsing("MAVLink", |ui| {
                        ui.label("Packet rate: 0 p/s");
                        ui.label("Error rate: 0%");
                        ui.label("Recovery: disarmed");

                        ui.collapsing("Arming", |ui| {
                            ui.horizontal(|ui| {
                                if ui.button("Arm").clicked() {
                                    // TODO
                                }
                                if ui.button("Disarm").clicked() {
                                    // TODO
                                }
                            });
                        });
                        ui.label("placeholder");

                        ui.collapsing("Log", |ui| {
                            for m in &self.serialport_messages {
                                ui.label(m);
                            }
                        });
                    });

                    ui.collapsing("Data", |ui| {
                        egui::Grid::new("sidebar-data-grid")
                            .num_columns(2)
                            .striped(true)
                            .show(ui, |ui| {
                                ui.label("Altitude:");
                                ui.label("3000.0 m");
                                ui.end_row();

                                ui.label("Air pressure:");
                                ui.label("0.0 Pa");
                                ui.end_row();

                                ui.label("Speed:");
                                ui.label("299792458.0 m/s");
                                ui.end_row();

                                ui.label("Acceleration:");
                                ui.label("0.0 m/s²");
                                ui.end_row();
                            });
                        ui.label("placeholder");
                    });
                });
            });

        egui::CentralPanel::default().show(ctx, |ui| {
            match self.ui_selectedtab {
                AppTab::Plot => {
                    self.tab_plot.ui(ui, &self.data);
                },
                AppTab::Live => {
                    self.tab_live.ui(ui, &self.data);
                },
                AppTab::Trajectory => {
                    ui.label("placeholder");
                },
                AppTab::Network => {
                    ui.label("placeholder");
                },
            }
        });
    }
}

fn ui_add_serialportui(ui: &mut egui::Ui, app: &mut MyApp) {
    // let mut settings_isenabled = false; // port name, baud rate, etc.
    // let mut connect_isenabled = false; // connect button
    // let mut disconnect_isenabled = true; // disconnect button
    let isconnected = app.serialconnection.isconnected();
    let settings_isenabled =   !isconnected;
    let connect_isenabled =    !isconnected && !app.serialport_selectedport.is_empty();
    let disconnect_isenabled =  isconnected;
    // match &app.serialport_activeport {
    //     Err(e) => match e.kind {
    //         serialport::ErrorKind::NoDevice => {
    //             settings_isenabled = true;
    //             connect_isenabled = true;
    //             disconnect_isenabled = false;
    //         },
    //         _ => {},
    //     },
    //     _ => {},
    // }

    // port settings
    ui.add_enabled_ui(settings_isenabled, |ui| {

        // port selection
        ui.horizontal(|ui| {
            ui_add_serialportdropdown(ui, &mut app.serialport_knownports, &mut app.serialport_selectedport);
            ui.label("Port");
            if ui.button("Refresh").clicked() {
                app.serialport_knownports = serialport::available_ports().unwrap_or(Vec::new()); // TODO: handle this error properly
            }
        });

        // baud rate
        egui::ComboBox::from_label("Baud rate")
            .selected_text(format!("{}", app.serialport_baudrate))
            .show_ui(ui, |ui| {
                ui.selectable_value(&mut app.serialport_baudrate, 50, "50");
                ui.selectable_value(&mut app.serialport_baudrate, 75, "75");
                ui.selectable_value(&mut app.serialport_baudrate, 110, "110");
                ui.selectable_value(&mut app.serialport_baudrate, 134, "134");
                ui.selectable_value(&mut app.serialport_baudrate, 150, "150");
                ui.selectable_value(&mut app.serialport_baudrate, 200, "200");
                ui.selectable_value(&mut app.serialport_baudrate, 300, "300");
                ui.selectable_value(&mut app.serialport_baudrate, 600, "600");
                ui.selectable_value(&mut app.serialport_baudrate, 1200, "1200");
                ui.selectable_value(&mut app.serialport_baudrate, 1800, "1800");
                ui.selectable_value(&mut app.serialport_baudrate, 2400, "2400");
                ui.selectable_value(&mut app.serialport_baudrate, 4800, "4800");
                ui.selectable_value(&mut app.serialport_baudrate, 9600, "9600");
                ui.selectable_value(&mut app.serialport_baudrate, 19200, "19200");
                ui.selectable_value(&mut app.serialport_baudrate, 28800, "28800");
                ui.selectable_value(&mut app.serialport_baudrate, 38400, "38400");
                ui.selectable_value(&mut app.serialport_baudrate, 57600, "57600");
                ui.selectable_value(&mut app.serialport_baudrate, 76800, "76800");
                ui.selectable_value(&mut app.serialport_baudrate, 115200, "115200");
                ui.selectable_value(&mut app.serialport_baudrate, 230400, "230400");
                ui.selectable_value(&mut app.serialport_baudrate, 460800, "460800");
                ui.selectable_value(&mut app.serialport_baudrate, 576000, "576000");
                ui.selectable_value(&mut app.serialport_baudrate, 921600, "921600");
            });
        
        // data bits
        egui::ComboBox::from_label("Data bits")
            .selected_text(match app.serialport_databits {
                serialport::DataBits::Five => "5",
                serialport::DataBits::Six => "6",
                serialport::DataBits::Seven => "7",
                serialport::DataBits::Eight => "8",
            })
            .show_ui(ui, |ui| {
                ui.selectable_value(&mut app.serialport_databits, serialport::DataBits::Five, "5");
                ui.selectable_value(&mut app.serialport_databits, serialport::DataBits::Six, "6");
                ui.selectable_value(&mut app.serialport_databits, serialport::DataBits::Seven, "7");
                ui.selectable_value(&mut app.serialport_databits, serialport::DataBits::Eight, "8");
            });

        // parity
        egui::ComboBox::from_label("Parity")
            .selected_text(match app.serialport_parity {
                serialport::Parity::Even => "Even",
                serialport::Parity::Odd => "Odd",
                serialport::Parity::None => "None",
            })
            .show_ui(ui, |ui| {
                ui.selectable_value(&mut app.serialport_parity, serialport::Parity::None, "None");
                ui.selectable_value(&mut app.serialport_parity, serialport::Parity::Even, "Even");
                ui.selectable_value(&mut app.serialport_parity, serialport::Parity::Odd, "Odd");
            });

        // stop bits
        egui::ComboBox::from_label("Stop bits")
            .selected_text(match app.serialport_stopbits {
                serialport::StopBits::One => "1",
                serialport::StopBits::Two => "2",
            })
            .show_ui(ui, |ui| {
                ui.selectable_value(&mut app.serialport_stopbits, serialport::StopBits::One, "1");
                ui.selectable_value(&mut app.serialport_stopbits, serialport::StopBits::Two, "2");
            });
    });
    
    // status
    ui.label(format!("Status: {}", match app.serialconnection.isconnected() {
        true => "connected",
        false => "disconnected",
    }));
    ui.label("Error rate: 0% (placeholder)");

    // connect/disconnect buttons
    ui.horizontal(|ui| {
        ui.add_enabled_ui(connect_isenabled, |ui| {
            if ui.button("Connect").clicked() {
                app.serialconnection.connect(
                    app.serialport_selectedport.clone(),
                    app.serialport_baudrate,
                    app.serialport_databits,
                    app.serialport_parity,
                    app.serialport_stopbits,
                    100
                );
            }
        });

        ui.add_enabled_ui(disconnect_isenabled, |ui| {
            if ui.button("Disconnect").clicked() {
                app.serialport_disconnect();
            }
        });
    });
}

fn ui_add_serialportdropdown(ui: &mut egui::Ui, availableports: &mut Vec<SerialPortInfo>, selectedport: &mut String) {
    egui::ComboBox::from_id_salt("serialport-name")
        .selected_text(selectedport.clone())
        .show_ui(ui, |ui| {
            for p in availableports {
                ui.selectable_value(selectedport, p.port_name.clone(), p.port_name.clone()); // TODO: cloning port info every time is probably horrible lol
            }
        });
}
