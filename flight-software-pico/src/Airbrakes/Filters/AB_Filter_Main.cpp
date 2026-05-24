#include "AB_Filter_Main.h"
#include "../../config.h"
#include <iostream>
using namespace std;


void AB_Filter_Initialize(AB_Filter &filter)
{
	filter.c1 = 0;
	filter.flight_stage = AB_Filter_Flight_Stage_PAD;
	filter.mag_calibrated = false;
	filter.time_since_launch = 0.0f;
	filter.mag_calibration_count = 0;
	filter.mag_calibration_sum << 0, 0, 0;

	filter.R0 << -0.04780f, 0.09582f, 3.70342f;
	filter.Rdot << 0.0f, 0.0f, -1.90235f;
	filter.R = filter.R0;
	filter.AccelBias << 0.0f, 0.0f, 0.0f;

	filter.PrevSensors.GPS_Position_m.setZero();
	filter.PrevSensors.GPS_Velocity_mps.setZero();
	filter.PrevSensors.Barometer = 0.0f;
	AB_Attitude_State_Initialization(
		filter.AttState,
		filter.AB_Att_Pred);
	AB_Vertical_State_Initialization(
		filter.VertState);
	AB_Horizontal_State_Initialization(
		filter.HorizState);
}

/**
 * The main process function for the airbrakes navigation filter.
 *
 * The first check that the filter makes for if it should use the low-g or high-g
 * accelerometer to obtain the rocket's acceleration value.
 *
 * Then, it checks if a state machine, with states chosen to correspond to significant
 * rocket statuses (i.e. PAD, BURNING, BURNOUT, APOGEE), should be advanced to the
 * next state based on sensed data.
 *
 * The first filtering operation that is performed is the Attitude Filter. For the
 * attitude filter, the sensors that can be used to progress the state estimate are
 * as follows: Gyroscope, Accelerometer, Magnetometer, GPS.
 *
 * For the Attitude Filter:
 * - The gyroscope is used in all flight stages.
 * - The accelerometer is used in the PAD and APOGEE stages.
 * - The magnetometer unused.
 * - GPS is used during BURNING and BURNOUT to fine tune attitude.
 *
 * To estimate a global acceleration vector (in an ENU, East-North-Up coordinate system),
 * the estimated attitude from the Attitude Filter is used to transform the rocket's
 * sensed acceleration vector into the global ENU frame. Then, this data is passed
 * into the Vertical Filter, which estimates the rocket's vertical velocity and
 * vertical position.
 *
 * For the Vertical Filter:
 * - The accelerometer is used in all flight stages.
 * - The barometer is used in all flight stages, but is sometimes inhibited during
 * 	 periods of known pressure disturbances, such as when the airbrakes are opening.
 *
 * Finally, there is a Horizontal Filter that estimates the rocket's horizontal travel.
 * The Horizontal Filter is just for creating fun visualizations so it is treated with
 * less rigor and seriousness than other parts of the code.
 */
void AB_Filter_Process(AB_Filter &filter, const AB_Filter_Inputs inputs, const AB_Settings settings)
{
	/* Compare GPS previous and current coordinates to see if anything changed.
	   This is useful because some crappy GPS receivers might report that they still have visible satellites
	   despite not having a fix. */

	bool GPS_updated = false;
	if (filter.PrevSensors.GPS_Position_m.norm() != inputs.GPS_Position_m.norm())
	{
		GPS_updated = true;
	}
	if (filter.PrevSensors.GPS_Velocity_mps.norm() != inputs.GPS_Velocity_mps.norm())
	{
		GPS_updated = true;
	}

	/* BMI323 low-g acceleration maxes out a +/-4g */
	const float HIGH_G_THRESHOLD_MPS2 = 3.5f * G_CONST;
	bool highG = fabs(inputs.Accelerometer_mps2.z()) > HIGH_G_THRESHOLD_MPS2;

	float accel_z_current;
	if (highG)
	{
		accel_z_current = inputs.AccelerometerHG_mps2.z();
	}
	else
	{
		accel_z_current = inputs.Accelerometer_mps2.z();
	}

	const float TAKEOFF_ACCEL_THRESHOLD_MPS2 = 2.0f * G_CONST;
	switch (filter.flight_stage)
	{
	case AB_Filter_Flight_Stage_PAD:
		if (accel_z_current > TAKEOFF_ACCEL_THRESHOLD_MPS2)
		{
			filter.flight_stage = AB_Filter_Flight_Stage_BURNING;
		}
		break;
	case AB_Filter_Flight_Stage_BURNING:
		filter.time_since_launch += inputs.dt;
		// filter.R = filter.R0 + (filter.Rdot * filter.time_since_launch);

		if (accel_z_current < 1.0f)
		{
			filter.flight_stage = AB_Filter_Flight_Stage_BURNOUT;
		}
		break;
	case AB_Filter_Flight_Stage_BURNOUT:
		if (filter.VertState.VelocityUp_mps < -1.0f)
		{
			filter.flight_stage = AB_Filter_Flight_Stage_APOGEE;
			filter.max_apogee = filter.VertState.Altitude_m;
		}
		break;
	}

	// TODO: redo this but without magic side effects
	// Lever_Arm(inputs.Accelerometer_mps2, inputs.Gyroscope_radps, filter.R);
	// Lever_Arm(inputs.AccelerometerHG_mps2, inputs.Gyroscope_radps, filter.R);

	/* Run attitude filter first */
	AB_Attitude_State_Prediction(filter.AttState, inputs, filter.AB_Att_Pred);

	if (filter.flight_stage == AB_Filter_Flight_Stage_PAD)
	{
		/* If we're on the pad, we can use the gravity vector to detect the attitude of the rocket. */
		/* If a gravity vector can be detected (|accel| > 8 m/s && |accel| < 11 m/s), use it to update the Attitude Filter */
		if (!highG && inputs.Accelerometer_mps2.norm() > 8.0f && inputs.Accelerometer_mps2.norm() < 11.0f && inputs.Accelerometer_mps2.z() < 2.1f * G_CONST)
		{
			if (filter.VertState.VelocityUp_mps < 0.3f)
			{
				AB_Attitude_State_Update_Accel(filter.AttState, inputs, filter.AB_Att_Pred, highG);
			}
		}
	}

	/* Once main parachute is deployed (at around 450m), we have a very defined gravity vector we can use. */
	/* Not that it matters too much anyways because after apogee, the airbrakes' work is done. :) */
	if (filter.flight_stage == AB_Filter_Flight_Stage_APOGEE && filter.VertState.Altitude_m < 400.0f)
	{
		AB_Attitude_State_Update_Accel(filter.AttState, inputs, filter.AB_Att_Pred, highG);
	}

	if (GPS_updated == true)
	{
		/* Use GPS for attitude filter when GPS reports velocity greater than 10 m/s */
		if (inputs.GPS_Velocity_mps.norm() > 10.0f)
		{
			AB_Attitude_State_Update_GPS(filter.AttState, inputs, filter.AB_Att_Pred);
		}
	}

	/* TODO: Magnetometer stuff. Dead code for now but we could use later if we wanted to.
	if (filter.mag_calibrated == false)
	{
		filter.mag_calibration_sum += inputs.Magnetometer;
		filter.mag_calibration_count++;
	}
	else
	{
		if (filter.flight_stage != AB_Filter_Flight_Stage_BURNING)
		{
			// AB_Attitude_State_Update_Mag(filter.AttState, inputs, filter.AB_Att_Pred);
		}
	}
	*/

	/* TODO: The idea for PseudoDrag is to be able to use a drag model to allow
			 attitude observability using velocity and altitude. In reality, we can't
			 even sense altitude accurately enough (without extensive corrections for
			 Venturi effect on static ports & other modeling) to make this work.

	if (filter.flight_stage == AB_Filter_Flight_Stage_BURNOUT && filter.VertState.VelocityUp_mps > 15.0f)
	{
		// Pass the state, sensors, vertical data, and prediction variables
		// AB_Attitude_Update_PseudoDrag(filter.AttState, inputs, filter.VertState, filter.HorizState, filter.AB_Att_Pred);
	}
	*/

	// Transform sensed acceleration vector to ENU frame to prepare it for Vertical Filter and Horizontal Filter
	Matrix<float, 3, 1> accelerationWorld = RotateAccelToWorldFrame(filter.AttState, inputs, highG);
	filter.AccelerationWorld = accelerationWorld;

	// Next, run Vertical Filter
	AB_Vertical_State_Prediction(filter.VertState, inputs, settings, accelerationWorld, highG);

	// TODO HIGH: Use better logic to determine when the barometer cannot be trusted. Perhaps we can sense
	// TODO HIGH: current the airbrakes are using, and use that to determine if the airbrakes are creating
	// TODO HIGH: a piston effect that will disturb barometer readings?
	if (abs(filter.PrevSensors.Barometer - inputs.Barometer_m) > 0.5)
	{
		// we constantly check if the barometer update is valid by ensuring the difference between
		//  barometer readings is nominal for an altitude increase, ie < 0.1mb
		filter.c1 = 0;
	}
	else
	{
		filter.c1 += 1;
		if (filter.c1 > 4)
		{
			if (!inputs.IgnoreBaro)
			{
				AB_Vertical_State_Update_Baro(filter.VertState, inputs, settings);
			}
		}
	}

	if (GPS_updated == true)
	{
		/* Only trust GPS if vertical GPS velocity is greater than 10 m/s */
		if (inputs.GPS_Velocity_mps.z() > 10.0f)
		{
			AB_Vertical_State_Update_GPS(filter.VertState, inputs, settings);
		}
	}

	if (filter.flight_stage == AB_Filter_Flight_Stage_APOGEE)
	{
		// If we have landed, then also force velocity to zero
		if (filter.VertState.Altitude_m < 1.0f)
		{
			filter.VertState.VelocityUp_mps = 0.0f;
		}
	}

	/*
	 * Horizontal filter stuff. Horizontal filter is just for creating fun visualizations so
	 * it is treated with less rigor and seriousness than other parts of the code.
	 */

	if (filter.flight_stage == AB_Filter_Flight_Stage_PAD || filter.flight_stage == AB_Filter_Flight_Stage_APOGEE)
	{
		// If the vertical velocity is very small, we can be sure the rocket is on the ground, so
		// force velocity north and velocity east to zero.
		if (abs(filter.VertState.VelocityUp_mps) < 0.2)
		{
			filter.HorizState.VelocityNorth_mps = 0.0f;
			filter.HorizState.VelocityEast_mps = 0.0f;
		}
	}

	if (GPS_updated == false && abs(filter.VertState.VelocityUp_mps) > 10.0f)
	{
		float velN, velE;
		Estimate_Horizontal_Velocity(filter.AttState, filter.VertState, filter.HorizState, velN, velE);
		float residN = filter.HorizState.VelocityNorth_mps - velN;
		float residE = filter.HorizState.VelocityEast_mps - velE;

		float alpha;
		if (filter.flight_stage != AB_Filter_Flight_Stage_APOGEE)
		{
			alpha = 0.0008f;
		}

		else
		{
			alpha = 0.002f;
		}

		if (abs(residN) > 5.0f)
		{
			filter.HorizState.VelocityNorth_mps = (1 - alpha) * filter.HorizState.VelocityNorth_mps + alpha * velN;
		}

		if (abs(residE) > 5.0f)
		{
			filter.HorizState.VelocityEast_mps = (1 - alpha) * filter.HorizState.VelocityEast_mps + alpha * velE;
		}
	}

	// Finally, run the horizontal filter itself
	AB_Horizontal_State_Prediction(filter.HorizState, inputs, accelerationWorld, highG);

	if (GPS_updated == true)
	{
		AB_Horizontal_State_Update_GPS(filter.HorizState, inputs);
	}

	// Here we save old sensor data
	filter.PrevSensors.GPS_Position_m = inputs.GPS_Position_m;
	filter.PrevSensors.GPS_Velocity_mps = inputs.GPS_Velocity_mps;
	filter.PrevSensors.Barometer = inputs.Barometer_m;
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
	s.VertBaroR(0, 0) = 5.0f;

	s.VertGpsR.setIdentity();
	s.VertGpsR(0, 0) = 5.0f;
	// TODO: set this to 0.5 in a real flight to represent the better accuracy of GPS velocity data in real flight,
	// TODO: compared to the velocity we are currently obtaining by naively differentiating GPS position.
	s.VertGpsR(1, 1) = 5.0f;

	s.Mass_kg = CONFIG_ROCKET_MASS_KG;
	s.GroundTemp_C = 35.0f;
	s.DeploymentRate_pctPerS = 100.0f / 1.28333333f;
	s.TargetApogee_m = CONFIG_AIRBRAKES_TARGET_APOGEE_METERS;

	return s;
}
