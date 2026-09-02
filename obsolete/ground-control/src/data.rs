use eframe::egui::{Color32, Stroke};
use egui::{ecolor, hex_color};
use egui_plot::{Line, PlotPoint, PlotPoints};
use std::vec::Vec;

pub(crate) struct Data {
    pub euler_a: DataSeries,
    pub euler_b: DataSeries,
    pub euler_y: DataSeries,
    pub fused_accel_magnitude: DataSeries,
    pub fused_accel_x: DataSeries,
    pub fused_accel_y: DataSeries,
    pub fused_accel_z: DataSeries,

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
            // in NWU axes
            euler_a: DataSeries::new("Euler α", "deg", hex_color!("FF7777")),
            euler_b: DataSeries::new("Euler β", "deg", hex_color!("77FF77")),
            euler_y: DataSeries::new("Euler γ", "deg", hex_color!("7777FF")),
            fused_accel_magnitude: DataSeries::new(
                "Fused Acceleration Magnitude",
                "m/s²",
                hex_color!("FF7777"),
            ),
            fused_accel_x: DataSeries::new("Fused Acceleration X", "m/s²", hex_color!("FF7777")),
            fused_accel_y: DataSeries::new("Fused Acceleration Y", "m/s²", hex_color!("FF7777")),
            fused_accel_z: DataSeries::new("Fused Acceleration Z", "m/s²", hex_color!("FF7777")),

            ms5607_pressure_mbar: DataSeries::new(
                "MS5607 Pressure",
                "milliBar",
                hex_color!("FF7777"),
            ),
            ms5607_temperature_c: DataSeries::new(
                "MS5607 Temperature",
                "degC",
                hex_color!("FF7777"),
            ),
            bmi323_accel_x: DataSeries::new("BMI323 Acceleration X", "m/s²", hex_color!("FF7777")),
            bmi323_accel_y: DataSeries::new("BMI323 Acceleration Y", "m/s²", hex_color!("77FF77")),
            bmi323_accel_z: DataSeries::new("BMI323 Acceleration Z", "m/s²", hex_color!("7777FF")),
            bmi323_gyro_x: DataSeries::new(
                "BMI323 Angular Velocity X",
                "deg/s",
                hex_color!("FF7777"),
            ),
            bmi323_gyro_y: DataSeries::new(
                "BMI323 Angular Velocity Y",
                "deg/s",
                hex_color!("77FF77"),
            ),
            bmi323_gyro_z: DataSeries::new(
                "BMI323 Angular Velocity Z",
                "deg/s",
                hex_color!("7777FF"),
            ),
            adxl375_accel_x: DataSeries::new(
                "ADXL375 Acceleration X",
                "m/s²",
                hex_color!("FF7777"),
            ),
            adxl375_accel_y: DataSeries::new(
                "ADXL375 Acceleration Y",
                "m/s²",
                hex_color!("77FF77"),
            ),
            adxl375_accel_z: DataSeries::new(
                "ADXL375 Acceleration Z",
                "m/s²",
                hex_color!("7777FF"),
            ),

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
    pub points: Vec<PlotPoint>,
    pub max_x: f64, // highest x value seen so far
    pub max_y: Option<f64>,
    pub min_y: Option<f64>,
}

impl DataSeries {
    pub fn new(name: &str, units: &str, color: Color32) -> Self {
        Self {
            name: name.into(),
            units: units.into(),
            color,
            points: Vec::new(),
            max_x: 0.0,
            min_y: None,
            max_y: None,
        }
    }

    pub fn add_point(&mut self, x: f64, y: f64) {
        if x >= self.max_x {
            self.points.push(PlotPoint { x, y });
            self.max_x = x;
        } else {
            panic!("Tried to add a data point backward in time");
        }

        if let Some(min_y) = self.min_y {
            if y < min_y {
                self.min_y = Some(y);
            }
        } else {
            self.min_y = Some(y)
        }

        if let Some(max_y) = self.max_y {
            if y > max_y {
                self.max_y = Some(y);
            }
        } else {
            self.max_y = Some(y)
        }
    }

    // returns a Line containing the last n points, where those points range
    // from xrange before the latest point to the latest point itself.
    pub fn as_line(&self) -> Line {
        Line::new(PlotPoints::Borrowed(&self.points))
            .name(self.name.clone())
            .color(self.color)
            .stroke(Stroke::new(1.0, self.color))
    }

    pub fn last_y_str(&self) -> String {
        if let Some(last) = self.points.last() {
            format!("{:.4}", last.y)
        } else {
            String::from("N/A")
        }
    }

    pub fn last_y(&self) -> Option<f64> {
        if let Some(last) = self.points.last() {
            Some(last.y)
        } else {
            None
        }
    }

    pub fn min_y(&self) -> Option<f64> {
        self.min_y
    }

    pub fn max_y(&self) -> Option<f64> {
        self.max_y
    }
}
