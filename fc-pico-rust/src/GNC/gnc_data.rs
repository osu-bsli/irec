//Static Data Storage File

//State storage
pub struct STATE_HISTORY {
    History: [State; 20],
}

//KF Math Storage
pub struct Predict {
    A_Predict: Predict_Attitude,
    V_Predict: Predict_Vertical,
    H_Predict: Predict_Horizontal,
}

pub struct Update {
    A_Update: Update_Attitude,
    V_Update: Update_Vertical,
    H_Update: Update_Horizontal,
}

//Templates for making the above structures
pub struct Update_Attitude {
    A_Up_GPS_V: Update_Attitude_GPS_Velocity,
    A_Up_Acc_D: Update_Attitude_Accel_Drag,
    A_Up_Acc_O: Update_Attitude_Accel_Orientation,
    A_Up_Mag: Update_Attitude_Magnetometer,
}

pub struct Update_Vertical {
    V_Up_GPS_V: Update_Vertical_GPS_Velocity,
    V_Up_GPS_P: Update_Vertical_GPS_Position,
    V_Up_Bar: Update_Vertical_Barometer,
}

pub struct Update_Horizontal {
    H_Up_GPS_P: Update_Horizontal_GPS_Velocity,
    H_Up_GPS_V: Update_Horizontal_GPS_Position,
}


pub struct State {
    A_State: AttitudeState,
    V_State: VerticalState,
    H_State: HorizontalState,
    State_Time: Instant,
}

pub struct AttitudeState {
    q_state: [f32; 4],
    g_bias: [f32; 3],
}

pub struct VerticalState {
    Down: f32,
    Down_Velocity: f32,
    North_Accel_Bias: f32,
    Barometer_Bias: f32,
}

pub struct HorizontalState {
    North: f32,
    East: f32,
    North_Velocity: f32,
    East_Velocity: f32,
    North_Accel_Bias: f32,
    East_Accel_Bias: f32,
}

pub struct Update_GPS_Velocity {
    A_Update_GPS_V: Update_Attitude_GPS_Velocity,
    V_Update_GPS_V: Update_Vertical_GPS_Velocity,
    H_Update_GPS_V: Update_Horizontal_GPS_Velocity,
}

pub struct Update_GPS_Position {
    V_Update_GPS_P: Update_Vertical_GPS_Position,
    H_Update_GPS_P: Update_Horizontal_GPS_Position,
}

pub struct Predict_Attitude {

}

pub struct Predict_Vertical {

}

pub struct Predict_Horizontal {

}

//Attitude Updates
pub struct Update_Attitude_GPS_Velocity {

}

pub struct Update_Attitude_Accel_Drag {

}

pub struct Update_Attitude_Accel_Orientation {

}

pub struct Update_Attitude_Magnetometer {

}

//Vertical Updates
pub struct Update_Vertical_GPS_Position {

}

pub struct Update_Vertical_GPS_Velocity {

}

pub struct Update_Vertical_Barometer {

}

//Horizontal Updates
pub struct Update_Horizontal_GPS_Position {

}

pub struct Update_Horizontal_GPS_Velocity {

}

