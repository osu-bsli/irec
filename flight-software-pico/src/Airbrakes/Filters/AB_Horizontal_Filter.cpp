#include "AB_Horizontal_Filter.h"

//Initializes and fills in the horizontal state and neccessary variables for future calculations
void AB_Horizontal_State_Initialization(
	AB_Horizontal_State& sN
)
{
	sN.Position_East = 0.0f; //TODO - replace with initial gps reading
	sN.Position_North = 0.0f; //TODO - replace with initial gps reading
	sN.VelocityEast_mps = 0.0f; //TODO - replace with initial gps reading
	sN.VelocityNorth_mps = 0.0f; //TODO - replace with initial gps reading
	sN.C.setZero(); // process noise accumulates into this each prediction step
}

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and 
//computes the prediction step
void AB_Horizontal_State_Prediction(
	AB_Horizontal_State& sN,
	const AB_Filter_Inputs sensor,
	const Vector<float, 3> accelerationWorld,
	const bool HG
)
{
	Matrix<float, 4, 4> F;
	Matrix<float, 4, 4> Q;
	float dt;
	float accelE;
	float accelN;
	float oldEVel;
	float oldNVel;
	F.setIdentity();
	Q.setZero();
	Q(0, 0) = 0.001f;
	Q(1, 1) = 0.001f;
	Q(2, 2) = 0.1f;
	Q(3, 3) = 0.1f;

	if (HG == true)
	{
		Q(0, 0) = 5.0f * 0.001f;
		Q(1, 1) = 5.0f * 0.001f;
		Q(2, 2) = 5.0f * 0.1f;
		Q(3, 3) = 5.0f * 0.1f;
	}

	else
	{
		Q(0, 0) = 0.001f;
		Q(1, 1) = 0.001f;
		Q(2, 2) = 0.1f;
		Q(3, 3) = 0.1f;
	}

	dt = sensor.dt; //grabbing deltaT from the sensor struct.
	accelE = accelerationWorld(0); //grabbing accelerometer E from sensor struct
	accelN = accelerationWorld(1); //grabbing accelerometer N from sensor struct
	oldEVel = sN.VelocityEast_mps; //grabbing the old velocity
	oldNVel = sN.VelocityNorth_mps; //grabbing the old velocity
	sN.Position_East += oldEVel * sensor.dt + 0.5f * (accelE)*sensor.dt * sensor.dt; //updating position, std kinematics
	sN.Position_North += oldNVel * sensor.dt + 0.5f * (accelN)*sensor.dt * sensor.dt; //updating position, std kinematics
	sN.VelocityEast_mps += (accelE)*sensor.dt; //updating velocity, std kinematics
	sN.VelocityNorth_mps += (accelN)*sensor.dt; //updating velocity, std kinematics
	//Now we have to update covariance, starting with jacobian. 
	// [dposE/dposE,     dposE/dposN,     dposE/dvelE    dposE/dvelN]  [1 0 dt 0]
	// [dposN/dposE,     dposN/dposN,     dposN/dvelE    dposN/dvelN]  [0 1 dt 0]
	// [dvelE/dposE,     dvelE/dposN,     dvelE/dvelE    dvelE/dvelN]  [0 0 1  0]
	// [dvelN/dposE,     dvelN/dposN,     dvelN/dvelE    dvelN/dvelN]  [0 0 0  1]
	F.setIdentity();
	F(0, 2) = dt; //derivative of pos wrt velocity is dt
	F(1, 3) = dt; //derivative of pos wrt velocity is dt
	sN.C = F * sN.C * F.transpose() + Q; //updating covariance (was a discarded local; now the state covariance, matching the vertical filter)
}

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Horizontal_State_Update_GPS(
	AB_Horizontal_State& sN,
	const AB_Filter_Inputs sensor
) {
	Matrix<float, 4, 1> d;
	Matrix<float, 4, 1> y;
	Matrix<float, 4, 4> H;
	Matrix<float, 4, 4> K;
	Matrix<float, 4, 4> R;
	Matrix<float, 4, 1> sE;
	Matrix<float, 4, 4> I;

	//Everthing to zero except for the GPS, for the position we trust +- 5m, 
	//and velocity +- 0.2
	d.setZero();
	y.setZero();
	H.setZero();
	K.setZero();
	R.setIdentity();
	R(0, 0) = 5.0f;
	R(1, 1) = 5.0f;
	R(2, 2) = 0.5f;
	R(3, 3) = 0.5f;
	sE.setZero();
	I.setIdentity();

	//difference between position/velocity reading in NE and gps reading
	y << (sensor.GPS_Position_m.x() - (sN.Position_East)),
		(sensor.GPS_Position_m.y() - (sN.Position_North)),
		(sensor.GPS_Velocity_mps.x() - (sN.VelocityEast_mps)),
		(sensor.GPS_Velocity_mps.y() - (sN.VelocityNorth_mps));

	//Now we find out H, or how the state effects the measurement
	//[dbaro/dAlt, dBaro/dvel, dBaro/dBaroBias] depends on altitude and the bias!
	//Depends on the position and the velocity
	// [ dGPSE/dposE,      dGPSE/dposN,      dGPSE/dvelE,     dGPSE/dvelN]  [1 0 dt 0]
	// [ dGPSN/dposE,      dGPSN/dposN,      dGPSN/dvelE,     dGPSN/dvelN]  [0 1 dt 0]
	// [dGPSVE/dposE,     dGPSVE/dposN,     dGPSVE/dvelE,    dGPSVE/dvelN]  [0 0 1  0]
	// [dGPSVN/dposE,     dGPSVN/dposN,     dGPSVN/dvelE,    dGPSVN/dvelN]  [0 0 0  1]
	H.setZero();
	H(0, 0) = 1.0f;
	H(1, 1) = 1.0f;
	H(2, 2) = 1.0f;
	H(3, 3) = 1.0f;

	//Now we find the kalman gain, K
	K = sN.C * H.transpose() * (H * sN.C * H.transpose() + R).inverse();

	//We also find the error state
	sE = K * y;

	//we add those corrections to the nominal state
	sN.Position_East += sE(0, 0);
	sN.Position_North += sE(1, 0);
	sN.VelocityEast_mps += sE(2, 0);
	sN.VelocityNorth_mps += sE(3, 0);

	//finally, we update the covariance
	sN.C = (I - K * H) * sN.C;
}