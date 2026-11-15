//Filter Architecture:
//Attitude filter finds quaternion -> transforms accelerometer from body to NED -> Vertical filter and horizontal filter use transformed accelerometer.
//UDU/Bierman-Thornton filtering methods
//Chi squared outlier rejection

//Magnetomter assumes biases are pre-calibrated
//Uses pre-computed WMM data as magnetic truth vector
//Gravity vector is calculated at grav_rate using a 10 term approximation

//Filter States:
//Attitude Filter(7): quaternion, gyro_bias
//Vertical Filter(4): D pos, D vel, D accel bias, barometer bias
//Horizontal Filter(6): E & N pos, E & N vel, E & N accel bias

//Filter Rates:
//Prediction:
//Attitude filter propogates its state at imu_rate, and its covariance at covariance_rate. 
//Vertical filter propogates its state at imu rate, and its covariance at covariance_rate. 
//Horizontal filter propogates its state at imu_rate, and its covariance at covariance_rate. 
//Update:
//Full update sensor rate

//IMU_rate is 800hz
//Cov_rate is 200hz
//mag_rate is 200hz
//baro_rate is 200hz
//GPS_rate is 10hz

//Prediction:
//Attitude filter predicts using gyro reading
//Vertical filter predicts with accel in the down frame
//Horizontal filter predicts with accel in the East and North frame

//Update
//*Clarification:
//When an update from an external sensor is recieved, the filter calculates 
//the gain update at the time it was recieved, but applies that update to the latest stored state

//Attitude filter can use:
// GPS_velocity vector DURING: Burn1, Burnout1, Burn2, Burnout2, Apogee, Drouge, Main, Vel_mag > 10m/s
// magnetometer DURING: Burn1, Burnout1, Burn2, Burnout2, Apogee, Drouge, Main
// free-fall drag from the accelerometer DURING: Burnout1, Burnout2, Acc > 0.25g(~2degree heading accuracy)
// accelerometer orientation DURING: PAD
//Vertical filter can use:
// barometer DURING: All stages of flight(except when airbrakes create disturbance, and pressure difference is > nominal)
// GPS altitude DURING: All stages of flight
// GPS velocity DURING: Burn1, Burnout1, Burn2, Burnout2, Apogee, Drouge, Main, velocity magnitude > 10m/s
//Horizontal filter can use:
// GPS longitude and latitude DURING: All stages of flight
// GPS longitude and latitude DURING: Burn1, Burnout1, Burn2, Burnout2, Apogee, Drouge, Main, velocity magnitude > 10m/s

