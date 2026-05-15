#include "AB_Filter_Main.h"
#include <iostream>
using namespace std;

void AB_Filter_Initialize(AB_Filter& filter)
{
	filter.flight_stage = AB_Filter_Flight_Stage_PAD;
	filter.mag_calibrated = false;
	filter.time_since_launch = 0.0f;
	filter.mag_calibration_count = 0;
	filter.mag_calibration_sum << 0, 0, 0;

	filter.R0 << -0.04780f, 0.09582f, 3.70342f;
	filter.Rdot << 0.0f, 0.0f, -1.90235f;
	filter.R = filter.R0;
	filter.AccelBias << 0.0f, 0.0f, 0.0f;

	filter.PrevSensors.GPS.setZero();
	filter.Flags.GPS = false;
	AB_Attitude_State_Initialization(
		filter.AttState,
		filter.AB_Att_Pred,
		filter.AB_Att_UP_Accel,
		filter.AB_Att_UP_GPS,
		filter.AB_Att_UP_Mag,
		filter.AB_Att_UP_Drag);
	AB_Vertical_State_Initialization(
		filter.VertState);
	AB_Horizontal_State_Initialization(
		filter.HorizState);
}

/*
 * (1) Compares norm of previous sensor data to current sensor data
 */
void AB_Filter_Process(AB_Filter& filter, const AB_Filter_Inputs inputs, const AB_Settings settings)
{
	// Then we see if new data has come in, and if it did, let the filter know.
	/* Compare GPS previous and current coordinates to see if anything changed.
	   This is useful because some crappy GPS receivers might report that they still have visible satellites
	   despite not having a fix. */
	if (filter.PrevSensors.GPS.norm() != inputs.GPS.norm())
	{
		filter.Flags.GPS = true;
	}

	bool highG;
	if (inputs.Accelerometer_mps2.norm() > 1.2f * 9.81f)
	{
		highG = true;
	}

	else
	{
		highG = false;
	}

	if (highG)
	{
		filter.accel_z_current = inputs.AccelerometerHG_mps2.z();
	}

	else
	{
		filter.accel_z_current = inputs.Accelerometer_mps2.z();
	}

	switch (filter.flight_stage)
	{
	case AB_Filter_Flight_Stage_PAD:
		if (filter.accel_z_current > 2.0 * 9.802f)
		{
			filter.flight_stage = AB_Filter_Flight_Stage_BURNING;
		}
		break;
	case AB_Filter_Flight_Stage_BURNING:
		filter.time_since_launch += inputs.dt;
		// filter.R = filter.R0 + (filter.Rdot * filter.time_since_launch);

		if (filter.accel_z_current < 1.0f)
		{
			filter.flight_stage = AB_Filter_Flight_Stage_BURNOUT;
		}
		break;
	case AB_Filter_Flight_Stage_BURNOUT:
		if (filter.VertState.Velocity_Up < -1.0f)
		{
			filter.flight_stage = AB_Filter_Flight_Stage_APOGEE;
			filter.max_apogee = filter.VertState.Altitude;
		}
		break;
	}

	// TODO: redo this but without magic side effects
	// Lever_Arm(inputs.Accelerometer_mps2, inputs.Gyroscope_radps, filter.R);
	// Lever_Arm(inputs.AccelerometerHG_mps2, inputs.Gyroscope_radps, filter.R);

	// Main filter loop. Start with attitude filter
	AB_Attitude_State_Prediction(filter.AttState, inputs, filter.AB_Att_Pred);

	if (highG)
	{
		if (inputs.AccelerometerHG_mps2.norm() > 8.0f && inputs.AccelerometerHG_mps2.norm() < 11.0f && inputs.AccelerometerHG_mps2.z() < 2.1f * 9.802f)
		{
			if (filter.VertState.Velocity_Up < 0.3f)
			{
				AB_Attitude_State_Update_Accel(filter.AttState, inputs, filter.AB_Att_UP_Accel, filter.AB_Att_Pred, highG);
			}
		}
	}

	else if (filter.flight_stage == AB_Filter_Flight_Stage_APOGEE && filter.VertState.Altitude < 400.0f)
	{
		AB_Attitude_State_Update_Accel(filter.AttState, inputs, filter.AB_Att_UP_Accel, filter.AB_Att_Pred, highG);
	}

	else
	{
		if (inputs.Accelerometer_mps2.norm() > 8.0f && inputs.Accelerometer_mps2.norm() < 11.0f && inputs.Accelerometer_mps2.z() < 1.01f * 9.802f)
		{
			if (filter.VertState.Velocity_Up > 0.3f)
			{
				if (highG)
				{
					AB_Attitude_State_Update_Accel(filter.AttState, inputs, filter.AB_Att_UP_Accel, filter.AB_Att_Pred, highG);
				}
			}
		}
	}

	if (filter.Flags.GPS == true)
	{
		/* Don't use GPS while we're sitting still */
		if (inputs.GPS.block<3, 1>(3, 0).norm() > 20.0f)
		{
			AB_Attitude_State_Update_GPS(filter.AttState, inputs, filter.AB_Att_UP_GPS, filter.AB_Att_Pred);
		}
	}

	if (filter.mag_calibrated == false)
	{
		filter.mag_calibration_sum += inputs.Magnetometer;
		filter.mag_calibration_count++;
	}

	else
	{
		if (filter.flight_stage != AB_Filter_Flight_Stage_BURNING)
		{
			// AB_Attitude_State_Update_Mag(filter.AttState, filter.Sensors, filter.AB_Att_UP_Mag, filter.AB_Att_Pred);
		}
	}

	// Inside AB_loop()
	if (filter.flight_stage == AB_Filter_Flight_Stage_BURNOUT && filter.VertState.Velocity_Up > 15.0f)
	{
		// Pass the state, sensors, vertical data, and prediction variables
		// AB_Attitude_Update_PseudoDrag(filter.AttState, filter.Sensors, filter.VertState, filter.HorizState, filter.AB_Att_UP_Drag, filter.AB_Att_Pred);
	}

	// transform the acceleration vector to ENU frame and prepare it for vert and horizontal filter
	auto accelerationWorld = RotateAccelToWorldFrame(filter.AttState, inputs, highG);

	// Next, process vertical filter
	AB_Vertical_State_Prediction(filter.VertState, inputs, settings, accelerationWorld, highG);
	AB_Vertical_State_Update_Baro(filter.VertState, inputs, settings);

	if (filter.Flags.GPS == true)
	{
		// AB_Vertical_State_Update_GPS(filter.VertState, filter.Sensors, filter.AB_Vert_UP_GPS, filter.AB_Vert_Pred);
	}

	if (abs(filter.VertState.Velocity_Up) < 0.2)
	{
		filter.HorizState.Velocity_North = 0.0f;
		filter.HorizState.Velocity_East = 0.0f;
	}

	if (filter.flight_stage == AB_Filter_Flight_Stage_APOGEE)
	{
		if (filter.VertState.Altitude < 1.0f)
		{
			filter.VertState.Velocity_Up = 0.0f;
		}
	}

	if (filter.Flags.GPS == false && abs(filter.VertState.Velocity_Up) > 10.0f)
	{
		Estimate_Horizontal_Velocity(filter.AttState, filter.VertState, filter.HorizState, filter.velN, filter.velE);
		filter.residN = filter.HorizState.Velocity_North - filter.velN;
		filter.residE = filter.HorizState.Velocity_East - filter.velE;

		if (filter.flight_stage != AB_Filter_Flight_Stage_APOGEE)
		{
			filter.alpha = 0.0008f;
		}

		else
		{
			filter.alpha = 0.002f;
		}

		if (abs(filter.residN) > 5.0f)
		{
			filter.HorizState.Velocity_North = (1 - filter.alpha) * filter.HorizState.Velocity_North + filter.alpha * filter.velN;
		}

		if (abs(filter.residE) > 5.0f)
		{
			filter.HorizState.Velocity_East = (1 - filter.alpha) * filter.HorizState.Velocity_East + filter.alpha * filter.velE;
		}
	}

	// finally the horizontal filter.
	AB_Horizontal_State_Prediction(filter.HorizState, inputs, accelerationWorld, highG);

	if (filter.Flags.GPS == true)
	{
		// AB_Horizontal_State_Update_GPS(filter.HorizState, filter.Sensors, filter.AB_Horiz_UP_GPS, filter.AB_Horiz_Pred);
	}

	filter.Flags.GPS = false;

	// Here we save old sensor data
	filter.PrevSensors.GPS = inputs.GPS;
}

const AB_Settings AB_Default_Settings()
{
	AB_Settings s;
	
	s.VertHighGQ.setZero();
	s.VertHighGQ(0, 0) = 5.0f * 0.001f;
	s.VertHighGQ(1, 1) = 5.0f * 0.1f;
	s.VertHighGQ(2, 2) = 5.0f * 0.0001f;

	s.VertLowGQ.setZero();
	s.VertLowGQ(0, 0) = 0.001f;
	s.VertLowGQ(1, 1) = 0.1f;
	s.VertLowGQ(2, 2) = 0.0001f;

	s.VertBaroR.setZero();
	s.VertBaroR(0, 0) = 6.6049f;

	s.VertGpsR.setIdentity();
	s.VertGpsR(0, 0) = 5.0f;
	s.VertGpsR(1, 1) = 0.5f;

	return s;
}