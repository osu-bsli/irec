use eframe::egui::{Color32, Stroke};
use egui::{ecolor, hex_color};
use egui_plot::{Line, PlotPoints};
use std::vec::Vec;

pub(crate) struct Data {
    pub x_acc: DataSeries, // acceleration, meters/second^2
    pub y_acc: DataSeries,
    pub z_acc: DataSeries,
    pub x_gyro: DataSeries, // angular velocity, rad/s
    pub y_gyro: DataSeries,
    pub z_gyro: DataSeries,
    pub x_mag: DataSeries, // magnetic field, gauss
    pub y_mag: DataSeries,
    pub z_mag: DataSeries,
}

impl Data {
    pub fn new() -> Self {
        Self {
            x_acc: DataSeries::new("Acceleration X", "m/s²", hex_color!("FF7777")),
            y_acc: DataSeries::new("Acceleration Y", "m/s²", hex_color!("77FF77")),
            z_acc: DataSeries::new("Acceleration Z", "m/s²", hex_color!("7777FF")),
            x_gyro: DataSeries::new("Angular Velocity X", "rad/s", hex_color!("FF7777")),
            y_gyro: DataSeries::new("Angular Velocity Y", "rad/s", hex_color!("77FF77")),
            z_gyro: DataSeries::new("Angular Velocity Z", "rad/s", hex_color!("7777FF")),
            x_mag: DataSeries::new("Magnetic Field X", "milligauss", hex_color!("FF7777")),
            y_mag: DataSeries::new("Magnetic Field Y", "milligauss", hex_color!("77FF77")),
            z_mag: DataSeries::new("Magnetic Field Z", "milligauss", hex_color!("7777FF")),
        }
    }
}

// data for a single graph, sensor, etc.
pub(crate) struct DataSeries {
    pub name: String,
    pub units: String,
    pub color: Color32,
    pub points: Vec<[f64; 2]>,
    pub max_x: f64, // highest x value seen so far
}

// convert to egui_plot data
impl From<&DataSeries> for Line {
    fn from(value: &DataSeries) -> Self {
        Line::new(PlotPoints::from(value.points.clone()))
            .name(value.name.clone())
            .color(value.color)
            .stroke(Stroke::new(1.0, value.color)) // thin lines look nice
    }
}

impl DataSeries {
    pub fn new(name: &str, units: &str, color: Color32) -> Self {
        Self {
            name: name.into(),
            units: units.into(),
            color,
            points: Vec::new(),
            max_x: 0.0,
        }
    }

    pub fn add_point(&mut self, x: f64, y: f64) {
        if x > self.max_x {
            self.points.push([x, y]);
            self.max_x = x;
        } else {
            panic!("Tried to add a data point backward in time");
        }
    }

    // returns a Line containing the last n points, where those points range
    // from xrange before the latest point to the latest point itself.
    pub fn as_line(&self, xrange: f64) -> Line {
        let minx = self.max_x - xrange;

        // get an iterator of references, filter, then clone.
        // this way, we only clone xrange worth of points.
        let pointsiter = (&self.points).into_iter().filter(|p| p[0] > minx).cloned(); // clones all elements

        Line::new(PlotPoints::from_iter(pointsiter))
            .name(self.name.clone())
            .color(self.color)
            .stroke(Stroke::new(1.0, self.color))
    }

    pub fn last_y_str(&self) -> String {
        if let Some(last) = self.points.last() {
            format!("{:.4}", last[1])
        } else {
            String::from("N/A")
        }
    }
}
