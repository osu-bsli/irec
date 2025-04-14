use std::time::Instant;

use egui::{Color32, RichText};
use serialport::SerialPortInfo;

use crate::{
    data_log_replay::load_zstd_data_log_v1,
    serial_connection::{self, Status},
    Data, DataSeries, GroundControlApp,
};

impl GroundControlApp {
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

            const BAUD_RATES: [u32; 23] = [
                50, 75, 110, 134, 150, 200, 300, 600, 1200, 1800, 2400, 4800, 9600, 19200, 28800,
                38400, 57600, 76800, 115200, 230400, 460800, 576000, 921600,
            ];
            // baud rate
            egui::ComboBox::from_label("Baud rate")
                .selected_text(format!("{}", self.serial.baud_rate))
                .show_ui(ui, |ui| {
                    for baud_rate in BAUD_RATES {
                        ui.selectable_value(
                            &mut self.serial.baud_rate,
                            baud_rate,
                            format!("{}", baud_rate),
                        );
                    }
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

    pub fn sidebar(&mut self, ui: &mut egui::Ui) {
        // ui.add_space(4.0);
        egui::ScrollArea::vertical().show(ui, |ui| {
            // serial port connection ui
            ui.collapsing("Info", |ui| {
                ui.label(format!("UI frame count: {}", self.frame_count));
            });

            ui.collapsing("Serial port", |ui| {
                ui.add_enabled_ui(self.data_log.is_none(), |ui| {
                    self.ui_add_serialportui(ui);
                });
            });

            ui.collapsing("Data log replay", |ui| {
                ui.add_enabled_ui(
                    self.serial.connection_status() == Status::Disconnected,
                    |ui| {
                        if ui.button("Open data log file").clicked() {
                            let path = rfd::FileDialog::new().pick_file().unwrap();
                            self.open_data_log_v1(path);
                        }

                        ui.add_enabled_ui(self.data_log.is_some(), |ui| {
                            if ui.button("Begin replay").clicked() {
                                self.data = Data::new();
                                self.data_log_replay_playing = true;
                                self.data_log_replay_time_ms = 0.;
                                self.data_log_replay_next_packet_index = 0;
                            }

                            if ui.button("Skip ahead to launch").clicked() {
                                self.replay_skip_ahead_to_launch();
                            }
                        });

                        if self.data_log.is_some() {
                            ui.label(format!("Replay time: {} ms", self.data_log_replay_time_ms));
                        }

                        ui.label(self.data_log_status.clone());
                    },
                );
            });

            ui.collapsing("Telemetry", |ui| {
                ui.label(format!(
                    "Packets accepted: {}",
                    self.telemetry_decoder.packets_accepted
                ));
                ui.label(format!(
                    "Packets rejected: {}",
                    self.telemetry_decoder.packets_rejected
                ));
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

                        display_data_series_label(&self.data.euler_a);
                        display_data_series_label(&self.data.euler_b);
                        display_data_series_label(&self.data.euler_y);
                        display_data_series_label(&self.data.fused_accel_magnitude);
                        display_data_series_label(&self.data.ms5607_temperature_c);
                        display_data_series_label(&self.data.ms5607_pressure_mbar);
                        display_data_series_label(&self.data.bmi323_accel_x);
                        display_data_series_label(&self.data.bmi323_accel_y);
                        display_data_series_label(&self.data.bmi323_accel_z);
                        display_data_series_label(&self.data.bmi323_gyro_x);
                        display_data_series_label(&self.data.bmi323_gyro_y);
                        display_data_series_label(&self.data.bmi323_gyro_z);
                        display_data_series_label(&self.data.adxl375_accel_x);
                        display_data_series_label(&self.data.adxl375_accel_y);
                        display_data_series_label(&self.data.adxl375_accel_z);

                        let mut display_bool_label = |label: &str, value: bool| {
                            ui.label(label);
                            ui.label(format!("{}", value));
                            ui.end_row();
                        };

                        display_bool_label("Recovery Armed", self.data.status_flag_recovery_armed);
                        display_bool_label(
                            "Ematch Drogue Deployed",
                            self.data.status_flag_ematch_drogue_deployed,
                        );
                        display_bool_label(
                            "Ematch Main Deployed",
                            self.data.status_flag_ematch_main_deployed,
                        );
                        display_bool_label(
                            "SD Card Degraded",
                            self.data.status_flag_sd_card_degraded,
                        );
                        display_bool_label(
                            "ADXL375 Degraded",
                            self.data.status_flag_adxl375_degraded,
                        );
                        display_bool_label(
                            "BM1422 Degraded",
                            self.data.status_flag_bm1422_degraded,
                        );
                        display_bool_label(
                            "BMI323 Degraded",
                            self.data.status_flag_bmi323_degraded,
                        );
                        display_bool_label(
                            "MS5607 Degraded",
                            self.data.status_flag_ms5607_degraded,
                        );
                    });
            });
        });
    }
}
