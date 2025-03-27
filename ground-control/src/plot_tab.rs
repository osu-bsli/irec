use crate::data::Data;

use eframe::egui;
use egui::Vec2b;
use egui_plot::{Legend, Plot};

pub struct PlotTab {}

impl PlotTab {
    pub fn new() -> Self {
        Self {}
    }

    pub fn ui(&mut self, ui: &mut egui::Ui, data: &Data) {
        let plot = Plot::new("bigplot")
            .legend(Legend::default())
            .link_axis("axislinkgroup-1", Vec2b::new(true, false))
            .link_cursor("cursorlinkgroup-1", Vec2b::new(true, false));

        plot.show(ui, |plotui| {
            plotui.line((&data.pitch).into());
            plotui.line((&data.yaw).into());
            plotui.line((&data.roll).into());
        });
    }
}
