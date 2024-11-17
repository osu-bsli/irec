use eframe::egui::{self, pos2, Color32};

use crate::GroundControlApp;

pub struct TrajectoryTab {
    size: egui::Vec2,
}

impl TrajectoryTab {
    pub fn new() -> Self {
        Self {
            size: egui::Vec2::new(256.0, 256.0),
        }
    }

    pub fn ui(&mut self, ui: &mut egui::Ui) {
        // TODO
        // if let Some(img) = textureid {
        //     let image_pos = ui.next_widget_position();
        //     let image_rect = egui::Rect {
        //         min: image_pos,
        //         max: image_pos + size,
        //     };
        //     self.size = size;

        //     ui.label(ui.cursor().to_string());
        //     ui.painter().image(
        //         img,
        //         image_rect,
        //         egui::Rect::from_min_max(pos2(0.0, 0.0), pos2(1.0, 1.0)),
        //         Color32::WHITE,
        //     );
        // } else {
        //     ui.label("Initializing...");
        // }
    }
}
