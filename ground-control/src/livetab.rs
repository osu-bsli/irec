use crate::data::Data;

use log::{debug, info, error};

use eframe::egui;
use egui_extras::{Size, StripBuilder};
use egui_plot::{Legend, Line, Plot};

pub struct LiveTab {
}

impl LiveTab {
    pub fn new() -> Self {
        Self {}
    }

    pub fn ui(&mut self, ui: &mut egui::Ui, data: &Data) {
        StripBuilder::new(ui)
            .size(Size::remainder().at_least(100.0)) // top cell
            .size(Size::remainder().at_least(100.0)) // bottom cell
            .vertical(|mut strip| {
                strip.strip(|builder| {
                    builder.sizes(Size::remainder(), 2).horizontal(|mut strip| {
                        strip.cell(|ui| {
                            LiveTab::graph(ui, "graph1", vec![
                                (&data.altitude).into(),
                            ]);
                        });
                        strip.cell(|ui| {
                            LiveTab::graph(ui, "graph2", vec![
                                (&data.airpressure).into(),
                            ]);
                        });
                    });
                });
                strip.strip(|builder| {
                    builder.sizes(Size::remainder(), 2).horizontal(|mut strip| {
                        strip.cell(|ui| {
                            LiveTab::graph(ui, "graph3", vec![
                                (&data.acceleration_x).into(),
                                (&data.acceleration_y).into(),
                                (&data.acceleration_z).into(),
                            ]);
                        });
                        strip.cell(|ui| {
                            LiveTab::graph(ui, "graph4", vec![]);
                        });
                    });
                });
            });
    }

    fn graph(ui: &mut egui::Ui, id: &str, lines: Vec<Line>) {
        let plot = Plot::new(id)
            .legend(Legend::default())
            .link_axis("axislinkgroup-1", true, false)
            .link_cursor("cursorlinkgroup-1", true, false);
        plot.show(ui, |plotui| {
            for l in lines {
                plotui.line(l);
            }
        });
    }
}
