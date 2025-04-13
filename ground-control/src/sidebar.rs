use crate::{DataSeries, GroundControlApp};

impl GroundControlApp {
    pub fn sidebar(&mut self, ui: &mut egui::Ui) {
        // ui.add_space(4.0);
        egui::ScrollArea::vertical().show(ui, |ui| {
            // serial port connection ui
            ui.collapsing("Info", |ui| {
                ui.label(format!("UI frame count: {}", self.frame_count));
            });

            ui.collapsing("Serial port", |ui| {
                self.ui_add_serialportui(ui);
            });

            ui.collapsing("Data log replay", |ui| {
                ui.label("placeholder");
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
                        display_data_series_label(&self.data.accel_magnitude);
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
                        display_bool_label("Ematch Drogue Deployed", self.data.status_flag_ematch_drogue_deployed);
                        display_bool_label("Ematch Main Deployed", self.data.status_flag_ematch_main_deployed);
                        display_bool_label("SD Card Degraded", self.data.status_flag_sd_card_degraded);
                        display_bool_label("ADXL375 Degraded", self.data.status_flag_adxl375_degraded);
                        display_bool_label("BM1422 Degraded", self.data.status_flag_bm1422_degraded);
                        display_bool_label("BMI323 Degraded", self.data.status_flag_bmi323_degraded);
                        display_bool_label("MS5607 Degraded", self.data.status_flag_ms5607_degraded);
                    });
            });
        });
    }
}
