use egui_plot::PlotPoints;
use std::convert::Into;
use std::vec::Vec;

// data for a single graph, sensor, etc.
pub(crate) struct DataSeries {
    points: Vec<[f64; 2]>,
}

impl Default for DataSeries {
    fn default() -> Self {
        Self { points: Vec::new() }
    }
}

// convert to egui_plot data
impl Into<PlotPoints> for DataSeries {
    fn into(self) -> PlotPoints {
        PlotPoints::from(self.points)
    }
}

impl DataSeries {
    fn append_point(&mut self, x: f64, y: f64) {
        self.points.push([x, y]);
    }
}

// all the DataSeries
#[derive(Default)]
struct Data {
    altitude: DataSeries,       // meters above sea level (TODO: or above ground?)
    air_pressure: DataSeries,   // TODO: unit?
    acceleration_x: DataSeries, // meters/second^2
    acceleration_y: DataSeries,
    acceleration_z: DataSeries, // TODO: struct DataSeries3D ?
}

impl Data {
    fn new() -> Self {
        Self {
            altitude: DataSeries::default(),
            air_pressure: DataSeries::default(),
            acceleration_x: DataSeries::default(),
            acceleration_y: DataSeries::default(),
            acceleration_z: DataSeries::default(),
        }
    }
}
