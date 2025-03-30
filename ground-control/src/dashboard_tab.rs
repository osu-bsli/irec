use std::f32::consts::PI;

use eframe::egui_glow;
use egui::{Label, RichText, Vec2};

use crate::GroundControlApp;

#[allow(dead_code)]
pub fn dashboard_tab(ui: &mut egui::Ui, app: &mut GroundControlApp) {
    ui.ctx().request_repaint();

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
                ui.label(RichText::new("PRESSURE ALTITUDE").size(40.0));
                ui.label(RichText::new("N/A").size(120.0).strong());
                ui.add_space(300.0);
                ui.label(RichText::new("SPEED").size(40.0));
                ui.label(RichText::new("N/A").size(120.0).strong());
            });
        });

    egui::CentralPanel::default().show_inside(ui, |ui| {
        egui::Frame::canvas(ui.style()).show(ui, |ui| {
            let (rect, response) =
                ui.allocate_exact_size(egui::Vec2::splat(300.0), egui::Sense::drag());

            app.triangle_angle += response.drag_motion().x * 0.01;

            // Clone locals so we can move them into the paint callback:
            let angle = app.triangle_angle;
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
                let pitch = app.data.pitch.last_y().unwrap_or(0.0) as f32 * (PI / 180.0);
                let yaw = app.data.yaw.last_y().unwrap_or(0.0) as f32 * (PI / 180.0);
                let x = pitch.cos() * yaw.cos();
                let y = pitch.cos() * yaw.sin();
                let z = pitch.sin();

                // angle from horizon
                let rocket_angle = z / (x.powf(2.0) + y.powf(2.0)).sqrt();

                const ALPHA: f32 = 0.02;
                let new_rocket_angle_ema =
                    rocket_angle * ALPHA + app.rocket_angle_ema * (1.0 - ALPHA);
                app.rocket_angle_ema = new_rocket_angle_ema;

                let rocket = egui::Image::new(egui::include_image!("rocket vis.png"))
                    .rotate(new_rocket_angle_ema + -PI / 2.0, Vec2::new(0.5, 0.5))
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
