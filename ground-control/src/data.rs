use eframe::egui::Color32;
use egui_plot::{Line, PlotPoints};
use std::vec::Vec;
use rand; // only used for placeholder demo graph functionality (see randpoints())

pub(crate) struct Data {
    pub altitude:       DataSeries, // meters above sea level (TODO: or above ground?)
    pub airpressure:    DataSeries, // TODO: unit?
    pub acceleration_x: DataSeries, // meters/second^2
    pub acceleration_y: DataSeries,
    pub acceleration_z: DataSeries, // TODO: struct DataSeries3D ?
}

impl Data {
    pub fn new() -> Self {
        Self {
            altitude:       DataSeries::new("Altitude (m)".to_string(),          Color32::from_hex("#F00").unwrap()),
            airpressure:    DataSeries::new("Air pressure (Pa)".to_string(),     Color32::from_hex("#00F").unwrap()),
            acceleration_x: DataSeries::new("Acceleration x (m/s²)".to_string(), Color32::from_hex("#F77").unwrap()),
            acceleration_y: DataSeries::new("Acceleration y (m/s²)".to_string(), Color32::from_hex("#7F7").unwrap()),
            acceleration_z: DataSeries::new("Acceleration z (m/s²)".to_string(), Color32::from_hex("#77F").unwrap()),
        }
    }
}

// data for a single graph, sensor, etc.
pub(crate) struct DataSeries {
    pub displayname: String,
    pub displaycolor: Color32,
    pub points: Vec<[f64; 2]>,
}

// convert to egui_plot data
impl From<&DataSeries> for Line {
    fn from(value: &DataSeries) -> Self {
        Line::new(PlotPoints::from(value.points.clone()))
            .name(value.displayname.clone())
            .color(value.displaycolor)
    }
}

impl DataSeries {
    pub fn new(displayname: String, displaycolor: Color32) -> Self {
        Self {
            displayname: displayname,
            displaycolor: displaycolor,
            points: randpoints(),
        }
    }

    pub fn add_point(&mut self, x: f64, y: f64) {
        self.points.push([x, y]);
    }
}

// only used for placeholder demo graph functionality
fn randpoints() -> Vec<[f64; 2]> {
    let mut range = rand::random::<f64>() * 100.0;
    range *= range * range; // cube it to get big variance of scales between data sets

    let mut result = Vec::new();
    let mut x = 0.0;
    while x < 100.0 {
        let y = rand::random::<f64>() * range;
        result.push([x, y]);
        x += rand::random::<f64>() * 10.0;
    }

    result
}
