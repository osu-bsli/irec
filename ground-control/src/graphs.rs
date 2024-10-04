use crate::data::Data;

use log::{debug, info, error};

use eframe::egui;
use egui_extras::{Size, StripBuilder};
use egui_plot::{Legend, Line, Plot};

pub struct Graphs {
    ui_selectedtab: GraphTab,
}

#[derive(PartialEq)]
enum GraphTab {
    MainGraph,
    AllGraphs,
}

impl Graphs {
    pub fn new() -> Self {
        Self {
            ui_selectedtab: GraphTab::MainGraph,
        }
    }

    pub fn ui(&mut self, ctx: &egui::Context, data: &Data) {
        egui::CentralPanel::default().show(ctx, |ui| {

            ui.horizontal(|ui| {
                // graph tabs
                ui.selectable_value(&mut self.ui_selectedtab, GraphTab::MainGraph, "Main graph");
                ui.selectable_value(&mut self.ui_selectedtab, GraphTab::AllGraphs, "All graphs");
            });

            match self.ui_selectedtab {
                GraphTab::MainGraph => {
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
                },
                GraphTab::AllGraphs => {
                    StripBuilder::new(ui)
                        .size(Size::remainder().at_least(100.0)) // top cell
                        .size(Size::remainder().at_least(100.0)) // bottom cell
                        .vertical(|mut strip| {
                            strip.strip(|builder| {
                                builder.sizes(Size::remainder(), 2).horizontal(|mut strip| {
                                    strip.cell(|ui| {
                                        Graphs::graph(ui, "graph1", vec![
                                            (&data.altitude).into(),
                                        ]);
                                    });
                                    strip.cell(|ui| {
                                        Graphs::graph(ui, "graph2", vec![
                                            (&data.airpressure).into(),
                                        ]);
                                    });
                                });
                            });
                            strip.strip(|builder| {
                                builder.sizes(Size::remainder(), 2).horizontal(|mut strip| {
                                    strip.cell(|ui| {
                                        Graphs::graph(ui, "graph3", vec![
                                            (&data.acceleration_x).into(),
                                            (&data.acceleration_y).into(),
                                            (&data.acceleration_z).into(),
                                        ]);
                                    });
                                    strip.cell(|ui| {
                                        Graphs::graph(ui, "graph4", vec![]);
                                    });
                                });
                            });
                        });
                },
            };
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
