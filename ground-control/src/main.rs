#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")] // hide console window on Windows in release

mod data;
mod livetab;
mod plottab;
mod serialconnection;
use data::Data;
use livetab::LiveTab;
use rand;
use std::{f32::consts::PI, io::BufRead};
use winit::window::Icon;

use log::{debug, error, info};

use eframe::egui::{self, pos2, Color32, Context, Pos2};
use egui_extras;
use plottab::PlotTab;
use serialport::SerialPortInfo;

use bevy::{
    prelude::*,
    render::{
        render_resource::{
            Extent3d, Texture, TextureDescriptor, TextureDimension, TextureFormat, TextureUsages,
        },
        view::RenderLayers,
    },
    window::PrimaryWindow,
    winit::{WinitSettings, WinitWindows},
};
use bevy_egui::{EguiContexts, EguiPlugin, EguiSet, EguiStartupSet};

const CAMERA_TARGET: Vec3 = Vec3::ZERO;

#[derive(Resource, Deref, DerefMut)]
struct OriginalCameraTransform(Transform);

fn main() {
    bevy::prelude::App::new()
        .insert_resource(WinitSettings::desktop_app())
        .add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                title: "BSLI Ground Control".to_string(),
                ..Default::default()
            }),
            ..Default::default()
        }))
        .add_plugins(EguiPlugin)
        .init_non_send_resource::<App>()
        .add_systems(Startup, set_window_icon)
        .add_systems(Startup, setup_system.after(EguiStartupSet::InitContexts))
        .add_systems(Update, ui_example_system)
        .add_systems(Update, rotator_system)
        .run();
}

// https://bevy-cheatbook.github.io/window/icon.html
fn set_window_icon(
    // we have to use `NonSend` here
    windows: NonSend<WinitWindows>,
) {
    // here we use the `image` crate to load our icon data from a png file
    // this is not a very bevy-native solution, but it will do
    let (icon_rgba, icon_width, icon_height) = {
        let image = image::open("assets/bsli_logo.png")
            .expect("Failed to open icon path")
            .into_rgba8();
        let (width, height) = image.dimensions();
        let rgba = image.into_raw();
        (rgba, width, height)
    };
    let icon = winit::window::Icon::from_rgba(icon_rgba, icon_width, icon_height).unwrap();

    // do it for all windows
    for window in windows.windows.values() {
        window.set_window_icon(Some(icon.clone()));
    }
}


#[derive(PartialEq)]
enum AppTab {
    Plot,
    Live,
    Trajectory, // TODO: 3d flight altitude and gps visualization
    Network,    // TODO: packet log
}

// Marks the main pass cube, to which the texture is applied.
#[derive(Component)]
struct Cube;

fn setup_system(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    mut contexts: EguiContexts,
    mut images: ResMut<Assets<Image>>,
    mut ground_control: NonSendMut<App>,
    mut windows: Query<&mut Window>,
    asset_server: Res<AssetServer>,
) {
    let mut window = windows.single_mut();
    window.set_maximized(true);

    let style = egui::Style {
        visuals: egui::Visuals::light(),
        ..egui::Style::default()
    };

    contexts.ctx_mut().set_style(style);
    let size = Extent3d {
        width: 512,
        height: 512,
        ..default()
    };

    // This is the texture that will be rendered to.
    let mut image = Image {
        texture_descriptor: TextureDescriptor {
            label: None,
            size,
            dimension: TextureDimension::D2,
            format: TextureFormat::Bgra8UnormSrgb,
            mip_level_count: 1,
            sample_count: 1,
            usage: TextureUsages::TEXTURE_BINDING
                | TextureUsages::COPY_DST
                | TextureUsages::RENDER_ATTACHMENT,
            view_formats: &[],
        },
        ..default()
    };

    // fill image.data with zeroes
    image.resize(size);

    commands.spawn((PbrBundle {
        mesh: meshes.add(Plane3d::default().mesh().size(5.0, 5.0)),
        material: materials.add(Color::srgb(0.3, 0.5, 0.3)),
        ..Default::default()
    },));
    commands.spawn((
        PbrBundle {
            mesh: meshes.add(Cuboid::new(1.0, 1.0, 1.0)),
            material: materials.add(Color::srgb(0.8, 0.7, 0.6)),
            transform: Transform::from_xyz(0.0, 0.5, 0.0),
            ..Default::default()
        },
        Cube,
    ));
    commands.spawn((PointLightBundle {
        point_light: PointLight {
            shadows_enabled: true,
            ..Default::default()
        },
        transform: Transform::from_xyz(4.0, 8.0, 4.0),
        ..Default::default()
    },));

    commands.spawn(SceneBundle {
        scene: asset_server.load(GltfAssetLabel::Scene(0).from_asset("models/untitled.gltf")),
        ..default()
    });

    let camera_pos = Vec3::new(-2.0, 2.5, 5.0);
    let camera_transform =
        Transform::from_translation(camera_pos).looking_at(CAMERA_TARGET, Vec3::Y);
    commands.insert_resource(OriginalCameraTransform(camera_transform));

    let image_handle = images.add(image);

    commands.spawn(Camera3dBundle {
        camera: Camera {
            target: image_handle.clone().into(),
            clear_color: Color::WHITE.into(),
            ..default()
        },
        transform: camera_transform,
        ..Default::default()
    });

    ground_control.image_3dvis = Some(contexts.add_image(image_handle));
}

struct App {
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

    image_3dvis: Option<egui::TextureId>,
}

impl App {
    fn update(&mut self, ctx: &mut Context) {
        ctx.request_repaint();

        // read serialport
        // TODO: move to another thread
        match &mut self.serialconnection.reader {
            Some(r) => {
                let mut buffer = String::new();
                let _ = r.read_line(&mut buffer);
                let _ = buffer.pop(); // remove trailing '\n'
                self.serialport_messages.push(buffer);
            }
            None => {}
        }

        // add fake data
        self.data
            .altitude
            .add_point(self.data_t, rand::random::<f64>() * 30000.0);
        self.data
            .airpressure
            .add_point(self.data_t, rand::random::<f64>() * 100.0);
        self.data
            .acceleration_x
            .add_point(self.data_t, rand::random::<f64>() * 100.0);
        self.data
            .acceleration_y
            .add_point(self.data_t, rand::random::<f64>() * 1000.0);
        self.data
            .acceleration_z
            .add_point(self.data_t, rand::random::<f64>() * 100.0);
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
                egui::ScrollArea::vertical().show(ui, |ui| {
                    // serial port connection ui
                    ui.collapsing("Serial port", |ui| {
                        self.ui_add_serialportui(ui);
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

        egui::CentralPanel::default().show(ctx, |ui| match self.ui_selectedtab {
            AppTab::Plot => {
                self.tab_plot.ui(ui, &self.data);
            }
            AppTab::Live => {
                self.tab_live.ui(ui, &self.data);
            }
            AppTab::Trajectory => {
                ui.label("placeholder");
            }
            AppTab::Network => {
                ui.label("placeholder");
            }
        });

        egui::Window::new("3D Visualizer")
            .vscroll(true)
            .show(ctx, |ui| {
                if let Some(image_3dvis) = self.image_3dvis {
                    let image_pos = ui.next_widget_position();
                    let image_rect = egui::Rect {
                        min: image_pos,
                        max: image_pos + egui::Vec2 { x: 512.0, y: 512.0 },
                    };

                    ui.label(ui.cursor().to_string());
                    ui.painter().image(
                        image_3dvis,
                        image_rect,
                        egui::Rect::from_min_max(pos2(0.0, 0.0), pos2(1.0, 1.0)),
                        Color32::WHITE,
                    );
                } else {
                    ui.label("Initializing...");
                }
            });
    }

    fn serialport_connect(&mut self) {
        self.serialconnection.connect(
            self.serialport_selectedport.clone(),
            self.serialport_baudrate,
            self.serialport_databits,
            self.serialport_parity,
            self.serialport_stopbits,
            100,
        );
    }

    fn serialport_disconnect(&mut self) {
        self.serialconnection.disconnect();
    }

    fn ui_add_serialportui(&mut self, ui: &mut egui::Ui) {
        // let mut settings_isenabled = false; // port name, baud rate, etc.
        // let mut connect_isenabled = false; // connect button
        // let mut disconnect_isenabled = true; // disconnect button
        let isconnected = self.serialconnection.isconnected();
        let settings_isenabled = !isconnected;
        let connect_isenabled = !isconnected && !self.serialport_selectedport.is_empty();
        let disconnect_isenabled = isconnected;
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
                App::ui_draw_serialportdropdown(
                    ui,
                    &mut self.serialport_knownports,
                    &mut self.serialport_selectedport,
                );
                ui.label("Port");
                if ui.button("Refresh").clicked() {
                    self.serialport_knownports =
                        serialport::available_ports().unwrap_or(Vec::new());
                    // TODO: handle this error properly
                }
            });

            // baud rate
            egui::ComboBox::from_label("Baud rate")
                .selected_text(format!("{}", self.serialport_baudrate))
                .show_ui(ui, |ui| {
                    ui.selectable_value(&mut self.serialport_baudrate, 50, "50");
                    ui.selectable_value(&mut self.serialport_baudrate, 75, "75");
                    ui.selectable_value(&mut self.serialport_baudrate, 110, "110");
                    ui.selectable_value(&mut self.serialport_baudrate, 134, "134");
                    ui.selectable_value(&mut self.serialport_baudrate, 150, "150");
                    ui.selectable_value(&mut self.serialport_baudrate, 200, "200");
                    ui.selectable_value(&mut self.serialport_baudrate, 300, "300");
                    ui.selectable_value(&mut self.serialport_baudrate, 600, "600");
                    ui.selectable_value(&mut self.serialport_baudrate, 1200, "1200");
                    ui.selectable_value(&mut self.serialport_baudrate, 1800, "1800");
                    ui.selectable_value(&mut self.serialport_baudrate, 2400, "2400");
                    ui.selectable_value(&mut self.serialport_baudrate, 4800, "4800");
                    ui.selectable_value(&mut self.serialport_baudrate, 9600, "9600");
                    ui.selectable_value(&mut self.serialport_baudrate, 19200, "19200");
                    ui.selectable_value(&mut self.serialport_baudrate, 28800, "28800");
                    ui.selectable_value(&mut self.serialport_baudrate, 38400, "38400");
                    ui.selectable_value(&mut self.serialport_baudrate, 57600, "57600");
                    ui.selectable_value(&mut self.serialport_baudrate, 76800, "76800");
                    ui.selectable_value(&mut self.serialport_baudrate, 115200, "115200");
                    ui.selectable_value(&mut self.serialport_baudrate, 230400, "230400");
                    ui.selectable_value(&mut self.serialport_baudrate, 460800, "460800");
                    ui.selectable_value(&mut self.serialport_baudrate, 576000, "576000");
                    ui.selectable_value(&mut self.serialport_baudrate, 921600, "921600");
                });

            // data bits
            egui::ComboBox::from_label("Data bits")
                .selected_text(match self.serialport_databits {
                    serialport::DataBits::Five => "5",
                    serialport::DataBits::Six => "6",
                    serialport::DataBits::Seven => "7",
                    serialport::DataBits::Eight => "8",
                })
                .show_ui(ui, |ui| {
                    ui.selectable_value(
                        &mut self.serialport_databits,
                        serialport::DataBits::Five,
                        "5",
                    );
                    ui.selectable_value(
                        &mut self.serialport_databits,
                        serialport::DataBits::Six,
                        "6",
                    );
                    ui.selectable_value(
                        &mut self.serialport_databits,
                        serialport::DataBits::Seven,
                        "7",
                    );
                    ui.selectable_value(
                        &mut self.serialport_databits,
                        serialport::DataBits::Eight,
                        "8",
                    );
                });

            // parity
            egui::ComboBox::from_label("Parity")
                .selected_text(match self.serialport_parity {
                    serialport::Parity::Even => "Even",
                    serialport::Parity::Odd => "Odd",
                    serialport::Parity::None => "None",
                })
                .show_ui(ui, |ui| {
                    ui.selectable_value(
                        &mut self.serialport_parity,
                        serialport::Parity::None,
                        "None",
                    );
                    ui.selectable_value(
                        &mut self.serialport_parity,
                        serialport::Parity::Even,
                        "Even",
                    );
                    ui.selectable_value(
                        &mut self.serialport_parity,
                        serialport::Parity::Odd,
                        "Odd",
                    );
                });

            // stop bits
            egui::ComboBox::from_label("Stop bits")
                .selected_text(match self.serialport_stopbits {
                    serialport::StopBits::One => "1",
                    serialport::StopBits::Two => "2",
                })
                .show_ui(ui, |ui| {
                    ui.selectable_value(
                        &mut self.serialport_stopbits,
                        serialport::StopBits::One,
                        "1",
                    );
                    ui.selectable_value(
                        &mut self.serialport_stopbits,
                        serialport::StopBits::Two,
                        "2",
                    );
                });
        });

        // status
        ui.label(format!(
            "Status: {}",
            match self.serialconnection.isconnected() {
                true => "connected",
                false => "disconnected",
            }
        ));
        ui.label("Error rate: 0% (placeholder)");

        // connect/disconnect buttons
        ui.horizontal(|ui| {
            ui.add_enabled_ui(connect_isenabled, |ui| {
                if ui.button("Connect").clicked() {
                    self.serialconnection.connect(
                        self.serialport_selectedport.clone(),
                        self.serialport_baudrate,
                        self.serialport_databits,
                        self.serialport_parity,
                        self.serialport_stopbits,
                        100,
                    );
                }
            });

            ui.add_enabled_ui(disconnect_isenabled, |ui| {
                if ui.button("Disconnect").clicked() {
                    self.serialport_disconnect();
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

fn ui_example_system(
    mut is_last_selected: Local<bool>,
    mut contexts: EguiContexts,
    mut app: NonSendMut<App>,
) {
    let ctx = contexts.ctx_mut();
    app.update(ctx);
}

impl Default for App {
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

            image_3dvis: None,
        }
    }
}

/// Rotates the inner cube (first pass)
fn rotator_system(time: Res<Time>, mut query: Query<&mut Transform, With<Cube>>) {
    for mut transform in &mut query {
        transform.rotate_x(1.5 * time.delta_seconds());
        transform.rotate_z(1.3 * time.delta_seconds());
    }
}
