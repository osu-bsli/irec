use crate::{data::Data, GroundControlApp};

use eframe::egui;
use egui::Vec2b;
use egui_plot::{Legend, Plot};

impl GroundControlApp {
    pub fn plot_tab(&mut self, ui: &mut egui::Ui) {
        let plot = Plot::new("bigplot")
            .legend(Legend::default())
            .link_axis("axislinkgroup-1", Vec2b::new(true, false))
            .link_cursor("cursorlinkgroup-1", Vec2b::new(true, false));

        plot.show(ui, |plotui| {
            plotui.line((&self.data.euler_a).into());
            plotui.line((&self.data.euler_b).into());
            plotui.line((&self.data.euler_y).into());
        });
    }
}
