use eframe::egui::{Color32, Stroke};
use egui_plot::{Line, PlotPoints};
use std::vec::Vec;

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
    pub maxx: f64, // highest x value seen so far
}

// convert to egui_plot data
impl From<&DataSeries> for Line {
    fn from(value: &DataSeries) -> Self {
        Line::new(PlotPoints::from(value.points.clone()))
            .name(value.displayname.clone())
            .color(value.displaycolor)
            .stroke(Stroke::new(1.0, value.displaycolor)) // thin lines look nice
    }
}

impl DataSeries {
    pub fn new(displayname: String, displaycolor: Color32) -> Self {
        Self {
            displayname: displayname,
            displaycolor: displaycolor,
            points: Vec::new(),
            maxx: 0.0,
        }
    }

    pub fn add_point(&mut self, x: f64, y: f64) {
        self.points.push([x, y]);
        if x > self.maxx {
            self.maxx = x;
        }
    }

    // returns a Line containing the last n points, where those points range
    // from xrange before the latest point to the latest point itself.
    pub fn as_line(&self, xrange: f64) -> Line {
        let minx = self.maxx - xrange;

        // get an iterator of references, filter, then clone.
        // this way, we only clone xrange worth of points.
        let pointsiter = (&self.points).into_iter()
            .filter(|p| p[0] > minx)
            .cloned(); // clones all elements

        Line::new(PlotPoints::from_iter(pointsiter))
            .name(self.displayname.clone())
            .color(self.displaycolor)
            .stroke(Stroke::new(1.0, self.displaycolor))
    }
}
