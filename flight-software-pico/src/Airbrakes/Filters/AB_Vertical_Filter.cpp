#include "AB_Vertical_Filter.h"

//Initializes and fills in the vertical state and neccessary variables for future calculations
void AB_Vertical_State_Initialization(
	AB_Vertical_State& sN
)
{
	//everything starts at 0
	sN.Altitude = 0.0f; //TODO - replace with initial gps reading
	sN.Velocity_Up = 0.0f;
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
	printf("accelZ: %f\n", accelZ);
	float accelUp = accelZ - gravity(sN.Altitude); //correcting Z acceleration for gravity
	float oldVel = sN.Velocity_Up; //grabbing the old velocity
	sN.Altitude += oldVel * inputs.dt + 0.5f * accelUp * inputs.dt * inputs.dt; //updating altitude, std kinematics
	sN.Velocity_Up += accelUp * inputs.dt; //updating velocity, std kinematics
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
    float y = (inputs.Barometer_m - (sN.Altitude + sN.Baro_Bias));

	//Now we find out H, or how the state affects the measurement
	//[dbaro/dAlt, dBaro/dvel, dBaro/dBaroBias] depends on altitude and the bias!
    Matrix<float, 1, 3> H;
	H << 1.0f, 0.0f, 1.0f;

	//Now we find the kalman gain, K
    Matrix<float, 3, 1> K = sN.C * H.transpose() * (H * sN.C * H.transpose() + settings.VertBaroR).inverse();

	//We also find the error state
    Matrix<float, 3, 1> sE = K * y;

	//we add those corrections to the nominal state
	sN.Altitude += sE(0, 0);
	sN.Velocity_Up += sE(1, 0);
	sN.Baro_Bias += sE(2, 0);

	//finally, we update the covariance
    Matrix<float, 3, 3> I;
    I.setIdentity();
	sN.C = (I - K * H) * sN.C;
}

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Vertical_State_Update_GPS(
	AB_Vertical_State& sN,
	const AB_Filter_Inputs inputs,
	const AB_Settings settings
)
{
	Matrix<float, 2, 1> d;
	Matrix<float, 2, 1> y;
	Matrix<float, 2, 3> H;
	Matrix<float, 3, 2> K;
	Matrix<float, 3, 1> sE;
	Matrix<float, 3, 3> I;

	//Same here, everthing to zero except for the GPS, for the position we trust +- 5m, 
	//and velocity +- 0.2
	d.setZero();
	y.setZero();
	H.setZero();
	K.setZero();
	sE.setZero();
	I.setIdentity();

	//difference between GPS altitude and altitude in the state
	y << (inputs.GPS(2) - sN.Altitude), (inputs.GPS(5) - sN.Velocity_Up);

	//Now we find out H, or how the state effects the measurement
	//[dGPS/dAlt, dGPS/dvel, dGPS/dBaroBias] depends on altitude only
	H.setZero();
	H(0, 0) = 1.0f;
	H(1, 1) = 1.0f;

	//Now we find the kalman gain, K
	K = sN.C * H.transpose() * (H * sN.C * H.transpose() + settings.VertGpsR).inverse();

	//We also find the error state
	sE = K * y;

	//we add those corrections to the nominal state
	sN.Altitude += sE(0, 0);
	sN.Velocity_Up += sE(1, 0);
	sN.Baro_Bias += sE(2, 0);

	//finally, we update the covariance
	sN.C = (I - K * H) * sN.C;
}