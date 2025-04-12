use std::f32::consts::PI;

use eframe::{egui_glow, glow::MAX_TESS_CONTROL_SHADER_STORAGE_BLOCKS};
use egui::{Label, RichText, Vec2};

use crate::GroundControlApp;

#[allow(dead_code)]
pub fn dashboard_tab(ui: &mut egui::Ui, app: &mut GroundControlApp) {
    ui.ctx().request_repaint_after_secs(1.0 / 30.0);

    ui.horizontal(|ui| {
        ui.spacing_mut().item_spacing.x = 0.0;
        ui.label("The triangle is being painted using ");
        ui.hyperlink_to("glow", "https://github.com/grovesNL/glow");
        ui.label(" (OpenGL).");
    });

    egui::SidePanel::left("left_panel")
        .resizable(true)
        .default_width(500.0)
        .show_inside(ui, |ui| {
            ui.vertical_centered(|ui| {
                // TODO
                ui.add_space(200.0);
                let pressure_mbar = app.data.ms5607_pressure_mbar.last_y();
                ui.label(RichText::new("PRESSURE ALTITUDE").size(40.0));
                if let Some(pressure_mbar) = pressure_mbar {
                    // TODO: Adjustable QNH
                    let altitude_ft = 145366.45 * (1.0 - (pressure_mbar / 1013.25).powf(0.190284));
                    ui.label(RichText::new(format!("{:.0} ft", altitude_ft)).size(120.0).strong());
                } else {
                    ui.label(RichText::new("N/A").size(120.0).strong());
                }
                ui.add_space(300.0);
                ui.label(RichText::new("ACCELERATION").size(40.0));
                if let Some(acceleration) = app.data.accel_magnitude.last_y() {
                    ui.label(RichText::new(format!("{:.0} m/s²", acceleration)).size(120.0).strong());
                } else {
                    ui.label(RichText::new("N/A").size(120.0).strong());
                }
            });
        });

    egui::CentralPanel::default().show_inside(ui, |ui| {
        egui::Frame::canvas(ui.style()).show(ui, |ui| {
            let (rect, response) =
                ui.allocate_exact_size(egui::Vec2::splat(300.0), egui::Sense::drag());

            app.triangle_angle += response.drag_motion().x * 0.01;

            // Clone locals so we can move them into the paint callback:
            // let angle = app.triangle_angle;
            let angle = (app.data.euler_y.last_y().unwrap_or(0.0) as f32).to_radians();
            let triangle = app.triangle.clone();

            let callback = egui::PaintCallback {
                rect,
                callback: std::sync::Arc::new(egui_glow::CallbackFn::new(move |_info, painter| {
                    triangle.lock().unwrap().paint(painter.gl(), angle);
                })),
            };
            ui.painter().add(callback);
        });
        ui.label("Drag to rotate!");
    });

    egui::SidePanel::right("right_panel")
        .resizable(true)
        .default_width(500.0)
        .show_inside(ui, |ui| {
            egui::ScrollArea::vertical().show(ui, |ui| {
                // Calculate angle from horizon
                let theta = app.data.euler_a.last_y().unwrap_or(0.0).to_radians() as f32;
                let phi = app.data.euler_b.last_y().unwrap_or(0.0).to_radians() as f32;
                let rocket_angle = -(phi.cos() * theta.cos()).asin();
                const ALPHA: f32 = 0.1;

                let new_rocket_angle_ema =
                    rocket_angle * ALPHA + app.rocket_angle_ema * (1.0 - ALPHA);
                app.rocket_angle_ema = new_rocket_angle_ema;

                let rocket = egui::Image::new(egui::include_image!("rocket vis.png"))
                    .rotate(new_rocket_angle_ema, Vec2::new(0.5, 0.5))
                    .max_height(100.0);

                ui.add_space(500.0);
                ui.add(rocket)
            });
        });

    // egui::Grid::new("dashboard_grid")
    //     .show(ui, |ui| {

    //     })
    //     .response
}
