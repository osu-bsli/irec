use crate::data::DataSeries;
use std::f64::consts::TAU;

use eframe::egui::{
    self, remap, Color32, ComboBox, NumExt, Pos2, Response, ScrollArea, TextWrapMode,
};
use egui_extras::{Size, StripBuilder};
use egui_plot::{CoordinatesFormatter, Corner, Legend, Line, LineStyle, Plot, PlotPoints};


struct LineDemo {
    animate: bool,
    time: f64,
    circle_radius: f64,
    circle_center: Pos2,
    square: bool,
    proportional: bool,
    coordinates: bool,
    show_axes: bool,
    show_grid: bool,
    line_style: LineStyle,
}

impl LineDemo {
    fn circle(&self) -> Line {
        let n = 512;
        let circle_points: PlotPoints = (0..=n)
            .map(|i| {
                let t = remap(i as f64, 0.0..=(n as f64), 0.0..=TAU);
                let r = self.circle_radius;
                [
                    r * t.cos() + self.circle_center.x as f64,
                    r * t.sin() + self.circle_center.y as f64,
                ]
            })
            .collect();
        Line::new(circle_points)
            .color(Color32::from_rgb(100, 200, 100))
            .style(self.line_style)
            .name("circle")
    }

    fn sin(&self) -> Line {
        let time = self.time;
        Line::new(PlotPoints::from_explicit_callback(
            move |x| 0.5 * (2.0 * x).sin() * time.sin(),
            ..,
            512,
        ))
        .color(Color32::from_rgb(200, 100, 100))
        .style(self.line_style)
        .name("wave")
    }

    fn thingy(&self) -> Line {
        let time = self.time;
        Line::new(PlotPoints::from_parametric_callback(
            move |t| ((2.0 * t + time).sin(), (3.0 * t).sin()),
            0.0..=TAU,
            256,
        ))
        .color(Color32::from_rgb(100, 150, 250))
        .style(self.line_style)
        .name("x = sin(2t), y = sin(3t)")
    }
}

impl LineDemo {
    fn ui(&mut self, ui: &mut egui::Ui) -> Response {
        if self.animate {
            ui.ctx().request_repaint();
            self.time += ui.input(|i| i.unstable_dt).at_most(1.0 / 30.0) as f64;
        };
        let mut plot = Plot::new("lines_demo")
            .legend(Legend::default())
            .show_axes(self.show_axes)
            .show_grid(self.show_grid);
        if self.square {
            plot = plot.view_aspect(1.0);
        }
        if self.proportional {
            plot = plot.data_aspect(1.0);
        }
        if self.coordinates {
            plot = plot.coordinates_formatter(Corner::LeftBottom, CoordinatesFormatter::default());
        }
        plot.show(ui, |plot_ui| {
            //plot_ui.line(self.circle());
            plot_ui.line(Line::new(
                DataSeries::default(),
            ));
            plot_ui.line(self.sin());
            plot_ui.line(self.thingy());
        })
        .response
    }
}

impl Default for LineDemo {
    fn default() -> Self {
        Self {
            animate: true,
            time: 0.0,
            circle_radius: 1.5,
            circle_center: Pos2::new(0.0, 0.0),
            square: false,
            proportional: true,
            coordinates: true,
            show_axes: true,
            show_grid: true,
            line_style: LineStyle::Solid,
        }
    }
}

#[derive(Default)]
pub struct Graphs {
    plot1: LineDemo,
    plot2: LineDemo,
    plot3: LineDemo,
    plot4: LineDemo,
}

impl Graphs {
    pub fn ui(&mut self, ctx: &egui::Context) {
        egui::SidePanel::left("graphs_left_sidebar")
            .resizable(false)
            .default_width(160.0)
            .min_width(160.0)
            .show(ctx, |ui| {
                ui.add_space(4.0);
                ui.vertical_centered(|ui| {
                    ui.heading("Diagnostics");
                });

                ui.separator();
            });

        egui::SidePanel::right("graphs_right_sidebar")
            .resizable(false)
            .default_width(160.0)
            .min_width(160.0)
            .show(ctx, |ui| {
                ui.add_space(4.0);
                ui.vertical_centered(|ui| {
                    ui.heading("Statistics");
                });

                ui.separator();
            });

        egui::CentralPanel::default().show(ctx, |ui| {
            StripBuilder::new(ui)
                .size(Size::remainder().at_least(100.0)) // top cell
                .size(Size::remainder().at_least(100.0)) // bottom cell
                .vertical(|mut strip| {
                    strip.strip(|builder| {
                        builder.sizes(Size::remainder(), 2).horizontal(|mut strip| {
                            strip.cell(|ui| {
                                ui.label("Top Left");
                                self.plot1.ui(ui);
                            });
                            strip.cell(|ui| {
                                ui.label("Top Right");
                                self.plot2.ui(ui);
                            });
                        });
                    });
                    strip.strip(|builder| {
                        builder.sizes(Size::remainder(), 2).horizontal(|mut strip| {
                            strip.cell(|ui| {
                                ui.label("Bottom Left");
                                self.plot3.ui(ui);
                            });
                            strip.cell(|ui| {
                                ui.label("Bottom Right");
                                self.plot4.ui(ui);
                            });
                        });
                    });
                })
        });
    }
}
