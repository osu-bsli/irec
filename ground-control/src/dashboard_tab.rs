use std::f32::consts::PI;

use egui::Vec2;

use crate::GroundControlApp;

#[allow(dead_code)]
pub fn dashboard_tab(ui: &mut egui::Ui, app: &mut GroundControlApp) -> egui::Response {
    ui.ctx().request_repaint();

    ui.with_layout(egui::Layout::from_main_dir_and_cross_align(egui::Direction::TopDown, egui::Align::BOTTOM), |ui| {
        let rocket_angle = app.data.pitch.last_y().unwrap_or(0.0) as f32 * (PI / 180.0);
        
        const ALPHA: f32 = 0.02;
        let new_rocket_angle_ema = rocket_angle * ALPHA + app.rocket_angle_ema * (1.0 - ALPHA);
        app.rocket_angle_ema = new_rocket_angle_ema;

        ui.add_space(500.0);
        let rocket =
            egui::Image::new(egui::include_image!("rocket vis.png"))
            .rotate(new_rocket_angle_ema + -PI / 2.0, Vec2::new(0.5, 0.5))
            .max_height(100.0);
        ui.add(rocket)
    }).response
}
