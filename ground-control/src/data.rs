use eframe::egui::{Color32, Stroke};
use egui::{ecolor, hex_color};
use egui_plot::{Line, PlotPoints};
use std::vec::Vec;

pub(crate) struct Data {
    pub ms5607_pressure: DataSeries,    // mbar
    pub ms5607_temperature: DataSeries, // degrees C
    pub bmi323_accel_x: DataSeries,     // acceleration, meters/second^2
    pub bmi323_accel_y: DataSeries,
    pub bmi323_accel_z: DataSeries,
    pub bmi323_gyro_x: DataSeries, // angular velocity, deg/s
    pub bmi323_gyro_y: DataSeries,
    pub bmi323_gyro_z: DataSeries,
    pub adxl375_accel_x: DataSeries,
    pub adxl375_accel_y: DataSeries,
    pub adxl375_accel_z: DataSeries,
}

impl Data {
    pub fn new() -> Self {
        Self {
            ms5607_pressure: DataSeries::new("MS5607 Pressure", "milliGauss", hex_color!("FF7777")),
            ms5607_temperature: DataSeries::new("MS5607 Temperature", "degC", hex_color!("FF7777")),
            bmi323_accel_x: DataSeries::new("BMI323 Acceleration X", "m/s²", hex_color!("FF7777")),
            bmi323_accel_y: DataSeries::new("BMI323 Acceleration Y", "m/s²", hex_color!("77FF77")),
            bmi323_accel_z: DataSeries::new("BMI323 Acceleration Z", "m/s²", hex_color!("7777FF")),
            bmi323_gyro_x: DataSeries::new("BMI323 Angular Velocity X", "deg/s", hex_color!("FF7777")),
            bmi323_gyro_y: DataSeries::new("BMI323 Angular Velocity Y", "deg/s", hex_color!("77FF77")),
            bmi323_gyro_z: DataSeries::new("BMI323 Angular Velocity Z", "deg/s", hex_color!("7777FF")),
            adxl375_accel_x: DataSeries::new("ADXL375 Acceleration X", "m/s²", hex_color!("FF7777")),
            adxl375_accel_y: DataSeries::new("ADXL375 Acceleration Y", "m/s²", hex_color!("77FF77")),
            adxl375_accel_z: DataSeries::new("ADXL375 Acceleration Z", "m/s²", hex_color!("7777FF")),
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
