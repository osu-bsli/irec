#include "AB_Vertical_Filter.h"

//Initializes and fills in the vertical state and neccessary variables for future calculations
void AB_Vertical_State_Initialization(
	AB_Vertical_State& sN
)
{
	//everything starts at 0
	sN.Altitude_m = 0.0f; //TODO - replace with initial gps reading
	sN.VelocityUp_mps = 0.0f;
	sN.Baro_Bias = 0.0f;
}

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and 
//computes the prediction step
void AB_Vertical_State_Prediction(
	AB_Vertical_State& sN,
	const AB_Filter_Inputs inputs,
	const AB_Settings settings,
    const Matrix<float, 3, 1> accelerationWorld,
	const bool highG
)
{
	const Matrix<float, 3, 3> *selectedQ;
	if (highG == true)
	{
		selectedQ = &settings.VertHighGQ;
	}

	else
	{
		selectedQ = &settings.VertLowGQ;
	}

	float accelZ = accelerationWorld(2); //grabing accelerometer Z from sensor struct
	float accelUp = accelZ - gravity(sN.Altitude_m); //correcting Z acceleration for gravity
	float oldVel = sN.VelocityUp_mps; //grabbing the old velocity
	sN.Altitude_m += oldVel * inputs.dt + 0.5f * accelUp * inputs.dt * inputs.dt; //updating altitude, std kinematics
	sN.VelocityUp_mps += accelUp * inputs.dt; //updating velocity, std kinematics
	//we dont change baro bias, as it is modeled as random walk
	//Now we have to update covariance, starting with jacobian. 
	// [    dalt/dalt,     dalt/dvel,     dalt/dbarbias]   
	// [    dvel/dalt,     dvel/dvel,     dvel/dbarbias]
	// [dbarbias/dalt, dbarbias/dvel, dbarbias/dbarbias]
	Matrix<float, 3, 3> F;
    F.setIdentity();
	F(0, 1) = inputs.dt; //only weird one is the deivative of altitude wrt vel is dt.
	sN.C = F * sN.C * F.transpose() + *selectedQ; //updating covariance
}

//Takes the calculation variables, current state, and new barometer data from the sensor struct and computes 
//the update step
void AB_Vertical_State_Update_Baro(
	AB_Vertical_State& sN,
	const AB_Filter_Inputs inputs,
	const AB_Settings settings
)
{
	//difference between baro reading and altitude + bias of the barometer
    float y = (inputs.Barometer_m - (sN.Altitude_m + sN.Baro_Bias));

	//Now we find out H, or how the state affects the measurement
	//[dbaro/dAlt, dBaro/dvel, dBaro/dBaroBias] depends on altitude and the bias!
    Matrix<float, 1, 3> H;
	H << 1.0f, 0.0f, 1.0f;

	//Now we find the kalman gain, K
    Matrix<float, 3, 1> K = sN.C * H.transpose() * (H * sN.C * H.transpose() + settings.VertBaroR).inverse();

	//We also find the error state
    Matrix<float, 3, 1> sE = K * y;

	//we add those corrections to the nominal state
	sN.Altitude_m += sE(0, 0);
	sN.VelocityUp_mps += sE(1, 0);
	sN.Baro_Bias += sE(2, 0);

	//finally, we update the covariance
    Matrix<float, 3, 3> I;
    I.setIdentity();
	sN.C = (I - K * H) * sN.C;
}

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes
//the update step.
//
//Position-only GPS update: the NMEA receiver provides no vertical velocity
//(main.cpp forces GPS_Velocity_mps.z() to 0), so we fuse ONLY the GPS altitude
//and let the EKF infer the velocity (and baro-bias) corrections through the
//altitude/velocity/bias covariance coupling. This anchors the altitude estimate
//to GPS even when the barometer is corrupted (e.g. by the airbrakes' aerodynamic
//pressure drop), which a baro-only filter cannot recover from.
void AB_Vertical_State_Update_GPS(
	AB_Vertical_State& sN,
	const AB_Filter_Inputs inputs,
	const AB_Settings settings
)
{
	//difference between GPS altitude and altitude in the state
	float y = inputs.GPS_Position_m.z() - sN.Altitude_m;

	//Now we find out H, or how the state affects the measurement
	//[dGPS/dAlt, dGPS/dvel, dGPS/dBaroBias] depends on altitude only
	Matrix<float, 1, 3> H;
	H << 1.0f, 0.0f, 0.0f;

	//GPS altitude measurement variance (reuse the position entry of VertGpsR)
	Matrix<float, 1, 1> R;
	R(0, 0) = settings.VertGpsR(0, 0);

	//Now we find the kalman gain, K (scalar innovation covariance)
	Matrix<float, 3, 1> K = sN.C * H.transpose() * (H * sN.C * H.transpose() + R).inverse();

	//We also find the error state. The covariance cross-terms let a pure
	//altitude residual also correct velocity and baro bias.
	Matrix<float, 3, 1> sE = K * y;

	//we add those corrections to the nominal state
	sN.Altitude_m += sE(0, 0);
	sN.VelocityUp_mps += sE(1, 0);
	sN.Baro_Bias += sE(2, 0);

	//finally, we update the covariance
	Matrix<float, 3, 3> I;
	I.setIdentity();
	sN.C = (I - K * H) * sN.C;
}