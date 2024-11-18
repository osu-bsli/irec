use crate::data::Data;


use eframe::egui;
use egui_plot::{Legend, Plot};

pub struct PlotTab {
}

impl PlotTab {
    pub fn new() -> Self {
        Self {}
    }

    pub fn ui(&mut self, ui: &mut egui::Ui, data: &Data) {

        let plot = Plot::new("bigplot")
            .legend(Legend::default())
            .link_axis("axislinkgroup-1", true, false)
            .link_cursor("cursorlinkgroup-1", true, false);

        plot.show(ui, |plotui| {
            plotui.line((&data.altitude).into());
            plotui.line((&data.airpressure).into());
            plotui.line((&data.acceleration_x).into());
            plotui.line((&data.acceleration_y).into());
            plotui.line((&data.acceleration_z).into());
        });
    }
}
