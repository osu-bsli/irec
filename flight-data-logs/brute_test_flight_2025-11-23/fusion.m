clear;

options = insOptions(SensorNamesSource="Property", ...
    SensorNames={'ADXL375, BMI323, BM1422'});

accSensor = insAccelerometer;
gyroSensor = insGyroscope;
magnSensor = insMagnetometer;
baroSensor = insBaroSensor;
motionModel = insMotionPose;

filter = insEKF(accSensor, magnSensor, baroSensor, insMotionPose);

T = readtable('brute_test_flight_2025-11-23_SRAD_flight-only.csv');

% this is for ADXL375 on peter's original flight computer
adxl375_z_bias_g = 0.8277;
acc =  [T.bmi323_accel_x, T.bmi323_accel_y, T.adxl375_accel_z - adxl375_z_bias_g] * 9.81;
gyro = deg2rad([T.bmi323_gyro_x,   T.bmi323_gyro_y,   T.bmi323_gyro_z  ]);
magn = [T.bm1422_magn_x,   T.bm1422_magn_y,   T.bm1422_magn_z  ];
pos_z_baro = 145366.45 * (1.0 - (T.ms5607_pressure_mbar / 1013.25) .^ 0.190284) * 0.3048;

N = size(T, 1);
dt = 0.01;

filter.AdditiveProcessNoise = eye(25);

estPos = zeros(N, 3);
estAcc = zeros(N, 3);
estVel = zeros(N, 3);
estOrientation = zeros(N, 4);
estAccBias = zeros(N, 3);
    
for ii = 1:N
    if ii ~= 1
        predict(filter, dt);
    end

    fuse(filter, accSensor, acc(ii,:), 1);
    fuse(filter, magnSensor, magn(ii,:), 1);
    fuse(filter, baroSensor, pos_z_baro(ii), 1);

    estPos(ii,:) = stateparts(filter, "Position");
    estAcc(ii,:) = stateparts(filter, "Acceleration");
    estVel(ii,:) = stateparts(filter, "Velocity");
    estOrientation(ii,:) = stateparts(filter, "Orientation");
    estAccBias(ii,:) = stateparts(filter, "Accelerometer_Bias");
end

plot(T.time_boot_ms,estVel(:,3));