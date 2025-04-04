use eframe::egui::{Color32, Stroke};
use egui::{ecolor, hex_color};
use egui_plot::{Line, PlotPoints};
use std::vec::Vec;

pub(crate) struct Data {
    pub pitch: DataSeries, 
    pub yaw: DataSeries, 
    pub roll: DataSeries, 
    pub accel_magnitude: DataSeries,
    
    pub ms5607_pressure_mbar: DataSeries,
    pub ms5607_temperature_c: DataSeries,
    pub bmi323_accel_x: DataSeries,
    pub bmi323_accel_y: DataSeries,
    pub bmi323_accel_z: DataSeries,
    pub bmi323_gyro_x: DataSeries,
    pub bmi323_gyro_y: DataSeries,
    pub bmi323_gyro_z: DataSeries,
    pub adxl375_accel_x: DataSeries,
    pub adxl375_accel_y: DataSeries,
    pub adxl375_accel_z: DataSeries,

    pub status_flag_recovery_armed: bool,
    pub status_flag_ematch_drogue_deployed: bool,
    pub status_flag_ematch_main_deployed: bool,
    pub status_flag_sd_card_degraded: bool,
    pub status_flag_adxl375_degraded: bool,
    pub status_flag_bm1422_degraded: bool,
    pub status_flag_bmi323_degraded: bool,
    pub status_flag_ms5607_degraded: bool,
}

impl Data {
    pub fn new() -> Self {
        Self {
            pitch: DataSeries::new("Pitch", "deg", hex_color!("FF7777")),
            yaw: DataSeries::new("Yaw", "deg", hex_color!("77FF77")),
            roll: DataSeries::new("Roll", "deg", hex_color!("7777FF")),
            accel_magnitude: DataSeries::new("Acceleration Magnitude", "m/s²", hex_color!("FF7777")),

            ms5607_pressure_mbar: DataSeries::new("MS5607 Pressure", "milliBar", hex_color!("FF7777")),
            ms5607_temperature_c: DataSeries::new("MS5607 Temperature", "degC", hex_color!("FF7777")),
            bmi323_accel_x: DataSeries::new("BMI323 Acceleration X", "m/s²", hex_color!("FF7777")),
            bmi323_accel_y: DataSeries::new("BMI323 Acceleration Y", "m/s²", hex_color!("77FF77")),
            bmi323_accel_z: DataSeries::new("BMI323 Acceleration Z", "m/s²", hex_color!("7777FF")),
            bmi323_gyro_x: DataSeries::new("BMI323 Angular Velocity X", "deg/s", hex_color!("FF7777")),
            bmi323_gyro_y: DataSeries::new("BMI323 Angular Velocity Y", "deg/s", hex_color!("77FF77")),
            bmi323_gyro_z: DataSeries::new("BMI323 Angular Velocity Z", "deg/s", hex_color!("7777FF")),
            adxl375_accel_x: DataSeries::new("ADXL375 Acceleration X", "m/s²", hex_color!("FF7777")),
            adxl375_accel_y: DataSeries::new("ADXL375 Acceleration Y", "m/s²", hex_color!("77FF77")),
            adxl375_accel_z: DataSeries::new("ADXL375 Acceleration Z", "m/s²", hex_color!("7777FF")),

            status_flag_recovery_armed: false,
            status_flag_ematch_drogue_deployed: false,
            status_flag_ematch_main_deployed: false,
            status_flag_sd_card_degraded: false,
            status_flag_adxl375_degraded: false,
            status_flag_bm1422_degraded: false,
            status_flag_bmi323_degraded: false,
            status_flag_ms5607_degraded: false,
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
impl From<&DataSeries> for Line<'_> {
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

    pub fn last_y(&self) -> Option<f64> {
        if let Some(last) = self.points.last() {
            Some(last[1])
        } else {
            None
        }
    }
}
