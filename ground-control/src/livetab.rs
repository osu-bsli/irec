use crate::data::Data;

use log::{debug, info, error};

use eframe::egui;
use egui_extras::{Size, StripBuilder};
use egui_plot::{Legend, Line, Plot};

pub struct LiveTab {
    plotrange: f64,
}

impl LiveTab {
    pub fn new() -> Self {
        Self {
            plotrange: 1.0,
        }
    }

    pub fn ui(&mut self, ui: &mut egui::Ui, data: &Data) {
        ui.vertical(|ui| {
            ui.horizontal(|ui| {
                ui.add(
                    egui::Slider::new(&mut self.plotrange, 0.05..=(60.0*5.0))
                        .logarithmic(true)
                );
                ui.label("Time window");
            });

            ui.separator();

            StripBuilder::new(ui)
                .size(Size::remainder().at_least(100.0)) // top cell
                .size(Size::remainder().at_least(100.0)) // bottom cell
                .vertical(|mut strip| {
                    strip.strip(|builder| {
                        builder.sizes(Size::remainder(), 2).horizontal(|mut strip| {
                            strip.cell(|ui| {
                                LiveTab::graph(ui, "graph1", vec![
                                    data.altitude.as_line(self.plotrange),
                                ]);
                            });
                            strip.cell(|ui| {
                                LiveTab::graph(ui, "graph2", vec![
                                    data.airpressure.as_line(self.plotrange),
                                ]);
                            });
                        });
                    });
                    strip.strip(|builder| {
                        builder.sizes(Size::remainder(), 2).horizontal(|mut strip| {
                            strip.cell(|ui| {
                                LiveTab::graph(ui, "graph3", vec![
                                    data.acceleration_x.as_line(self.plotrange),
                                    data.acceleration_y.as_line(self.plotrange),
                                    data.acceleration_z.as_line(self.plotrange),
                                ]);
                            });
                            strip.cell(|ui| {
                                LiveTab::graph(ui, "graph4", vec![]);
                            });
                        });
                    });
                });
        });

    }

    fn graph(ui: &mut egui::Ui, id: &str, lines: Vec<Line>) {
        let plot = Plot::new(id)
            .legend(Legend::default())
            .allow_boxed_zoom(false)
            .allow_drag(false)
            .allow_scroll(false)
            .allow_zoom(false)
            // .auto_bounds(Vec2b::new(false, false)) // manually set bounds to prevent jittering
            // .set_margin_fraction(egui::Vec2::new(0.0, 0.0)) // set remove auto_bounds padding
            .link_cursor("cursorlinkgroup-1", true, false);
        plot.show(ui, |plotui| {
            for l in lines {
                plotui.line(l);
            }
        });
    }
}
