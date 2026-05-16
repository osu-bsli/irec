// Main loop
#include "rapidcsv.h"
#include <SDL3/SDL.h>
#include <implot.h>
#include <imgui_impl_sdl3.h>
#include <ranges>
#include <tuple>
#include <string>

#define _USE_MATH_DEFINES // needed on MSVC for math.h to include M_PI
#include <math.h>

#include "MathFunctions.h"
#include "util.h"
#include "utility.h"
#include "AB_Deployment.h"
#include "AB_Filter_Main.h"

#include "testing/nomad_test_flight_2026-4-11_cropped.logv3.h"
#include "telemetry.h"
#include "config.h"

#include <float.h>

#define G 9.80665


// check that length of log evenly divides by log packet size
static_assert(log_cropped_logv3_len / sizeof(log_packet_v3) * sizeof(log_packet_v3) == log_cropped_logv3_len);
const int log_len = log_cropped_logv3_len / sizeof(log_packet_v3);

class OutDataSeries
{
public:
	std::vector<float> v_data;
	std::string label;
	std::function<float(float)> data_source_func;
};

class SingleInMultiOutData
{
public:
	std::string in_data_label;
	std::vector<float> v_in_data;
	std::vector<OutDataSeries> out_data_series;

	SingleInMultiOutData(std::string in_data_label)
	{
		this->in_data_label = in_data_label;
	}

	void AddOutDataSource(std::string label, std::function<float(float)> data_source_func)
	{
		OutDataSeries e = {
			.v_data = std::vector<float>(),
			.label = label,
			.data_source_func = data_source_func,
		};
		out_data_series.push_back(e);
	}

	void PushBackInDataPoint(float val)
	{
		this->v_in_data.push_back(val);
	}

	void ClearOutDataPoints()
	{
		for (auto& e : out_data_series)
		{
			e.v_data.clear();
		}
	}

	void GenerateOutDataPoints()
	{
		for (auto& e : out_data_series)
		{
			for (float in_val : v_in_data)
			{
				e.v_data.push_back(e.data_source_func(in_val));
			}
		}
	}

	int GetDataSeriesLength()
	{
		return v_in_data.size();
	}

	int GetNumOutDataSeries()
	{
		return out_data_series.size();
	}
};

SingleInMultiOutData altitude_m("Altitude (m)");

bool graphOutOfDate = true;
const int maxAltitude_m = 9144; // 30000 ft
const float GROUND_LEVEL_TEMP_CELCIUS = 25;

float airbrakeDeployment_pct;
float velocity_mps;

float data_source_func_Cd(float altitude_m)
{
	return drag_coeff(airbrakeDeployment_pct, velocity_mps, altitude_m, GROUND_LEVEL_TEMP_CELCIUS);
}

float data_source_func_air_density(float altitude_m)
{
	return rho_kg_per_m3(altitude_m);
}

void SetupVisualizer()
{
	ImPlot::CreateContext();

	for (int i = 0; i < maxAltitude_m + 1; i++)
	{
		altitude_m.PushBackInDataPoint(i);
	}

	altitude_m.AddOutDataSource("Drag coefficient (Cd)", data_source_func_Cd);
	altitude_m.AddOutDataSource("Air density (kg/m^3)", data_source_func_air_density);
}

void RunFilter()
{
	altitude_m.ClearOutDataPoints();
	altitude_m.GenerateOutDataPoints();
}

void plotTooltip(const OutDataSeries& e)
{
	// Show tooltip with value of graph at cursor location
	if (ImPlot::IsPlotHovered())
	{
		ImPlotPoint mouse = ImPlot::GetPlotMousePos();
		// x values are integers 0..maxAltitude_m, so mouse.x == index into v_data
		int idx = (int)mouse.x;
		if (idx >= 0 && idx < (int)e.v_data.size())
		{
			float xVal = (float)idx;
			float yVal = e.v_data[idx];

			// Convert the data-space intersection point to screen pixels
			ImVec2 dotPos = ImPlot::PlotToPixels(xVal, yVal);
			// Get the plot area bounds in screen pixels for drawing full-length crosshair lines
			ImVec2 plotTL = ImPlot::GetPlotPos();
			ImVec2 plotBR = ImVec2(plotTL.x + ImPlot::GetPlotSize().x, plotTL.y + ImPlot::GetPlotSize().y);

			// GetPlotDrawList() clips drawing to the plot area automatically
			ImDrawList* drawList = ImPlot::GetPlotDrawList();
			ImU32 lineColor = IM_COL32(255, 255, 255, 80);
			drawList->AddLine(ImVec2(dotPos.x, plotTL.y), ImVec2(dotPos.x, plotBR.y), lineColor); // vertical
			drawList->AddLine(ImVec2(plotTL.x, dotPos.y), ImVec2(plotBR.x, dotPos.y), lineColor); // horizontal
			drawList->AddCircleFilled(dotPos, 5.0f, IM_COL32(255, 255, 255, 220));

			ImGui::BeginTooltip();
			ImGui::Text("%s: %.2f\n%s: %g", altitude_m.in_data_label.c_str(), xVal, e.label.c_str(), yVal);
			ImGui::EndTooltip();
		}
	}
}

void enable_exception_on_NaN()
{
	// Disable exceptions to avoid premature exits, then enable specific ones
	_controlfp_s(nullptr, 0, _MCW_EM);
	_controlfp_s(nullptr, ~(_EM_INVALID | _EM_ZERODIVIDE | _EM_DENORMAL), _MCW_EM);
}

template<int N>
bool MatrixEditor(const char* name, Eigen::Matrix<float, N, N>& matrix, const char** columnLabels) {
	bool modified = false;
	ImGui::PushID(name);
	ImGui::Text(name);
	if (ImGui::BeginTable(name, N, ImGuiTableFlags_Borders | ImGuiTableFlags_RowBg)) {
		for (int row = 0; row < N; row++) {
			ImGui::TableNextRow();
			for (int col = 0; col < N; col++) {
				ImGui::TableSetColumnIndex(col);

				if (row == 0)
				{
					ImGui::Text(columnLabels[col]);
				}

				// Create a unique identifier for each cell
				ImGui::PushID(row * N + col);

				// Edit cell value directly
				ImGui::SetNextItemWidth(-FLT_MIN); // Fit column width
				modified |= ImGui::InputFloat("##cell", &matrix.data()[row + col * N], 0.1f, 1.0f);

				ImGui::PopID();
			}
		}
		ImGui::EndTable();
	}
	ImGui::PopID();

	return modified;
}

static ImVec2 Project3D(float x, float y, float z, ImVec2 center, float scale)
{
	// Isometric projection: E→lower-right, N→lower-left, U→up
	float sx = (x - y) * 0.7071f;
	float sy = (-x - y + 2.0f * z) * 0.4082f;
	return ImVec2(center.x + sx * scale, center.y - sy * scale);
}

void ShowVisualizer()
{
	//enable_exception_on_NaN();

	static int g_nav_hovered_idx = -1;
	static float g_nav_hovered_time = 0.0f;
	static float g_nav_quat_w[log_len] = { 0 };
	static float g_nav_quat_x[log_len] = { 0 };
	static float g_nav_quat_y[log_len] = { 0 };
	static float g_nav_quat_z[log_len] = { 0 };

	if (graphOutOfDate)
	{
		graphOutOfDate = false;
		RunFilter();
	}

	if (ImGui::Begin("Plots"))
	{
		ImGui::Text("Drag options");
		graphOutOfDate |= ImGui::SliderFloat("Airbrake deployment (%)", &airbrakeDeployment_pct, 0, 100);
		graphOutOfDate |= ImGui::SliderFloat("Velocity (m/s)", &velocity_mps, 0, 343);

		ImVec2 size = ImGui::GetContentRegionAvail();
		size.y /= altitude_m.GetNumOutDataSeries();
		size.y -= ImGuiStyleVar_ItemSpacing;

		static ImPlotRect lims(0, 100, 0, maxAltitude_m);

		if (ImPlot::BeginAlignedPlots("AlignedGroup"))
		{
			for (const auto& e : altitude_m.out_data_series)
			{
				char plotName[128];
				snprintf(plotName, sizeof(plotName), "%s vs. %s", altitude_m.in_data_label.c_str(), e.label.c_str());
				if (ImPlot::BeginPlot(plotName, size))
				{
					ImPlot::SetupAxes(altitude_m.in_data_label.c_str(), e.label.c_str());
					ImPlot::SetupAxisLinks(ImAxis_X1, &lims.X.Min, &lims.X.Max);
					ImPlot::SetupAxisLimits(ImAxis_X1, 0, maxAltitude_m, ImPlotCond_Once);
					ImPlot::SetupAxisLimits(ImAxis_Y1, 0, 1, ImPlotCond_Once);
					ImPlot::PlotLine(e.label.c_str(), altitude_m.v_in_data.data(), e.v_data.data(), altitude_m.GetDataSeriesLength(), ImPlotLineFlags_None);

					plotTooltip(e);

					ImPlot::EndPlot();
				}
			}

			ImPlot::EndAlignedPlots();
		}

		ImGui::End();
	}

	if (ImGui::Begin("Theoretical drag vs. CFD simulated (data from aero team)"))
	{
		const float machMin = 0;
		const float machMax = 0.8;
		const int numPoints = 500;
		const float step = (machMax - machMin) / numPoints;

		static float groundLevelTempCelcius = 25;
		static bool outOfDate = true;
		static float rSquared = 0;
		outOfDate |= ImGui::SliderFloat("Ground level temperature (degC)", &groundLevelTempCelcius, 0, 50);

		if (outOfDate)
		{
			outOfDate = false;
			rSquared = r_squared_of_drag_coeff_func_against_theoretical(groundLevelTempCelcius);
		}

		ImGui::Text("R^2: %f", rSquared);

		ImGui::End();
	}

	if (ImGui::Begin("Apogee prediction"))
	{
		static bool outOfDate = true;
		static float apogeePrediction_m = 0;

		static apogeeIC ic = {
			.altitude_m = 0,
			.velocityZ_mps = 0,
			.thetaZ_rad = 0,
			.airbrakeDeployment_pct = 0,
		};

		ImGui::Text("Initial conditions:");

		outOfDate |= ImGui::SliderFloat("Altitude (m)", &ic.altitude_m, 0, 10000);
		outOfDate |= ImGui::SliderFloat("Velocity (m/s)", &ic.velocityZ_mps, 0, 1000);
		outOfDate |= ImGui::SliderFloat("Theta Z (rad)", &ic.thetaZ_rad, 0, 1.57);
		outOfDate |= ImGui::SliderFloat("Airbrake deployment (%)", &ic.airbrakeDeployment_pct, 0, 100);

		if (outOfDate)
		{
			outOfDate = false;
			apogeePrediction_m = PredictApogee(ic);
		}

		ImGui::Text("Apogee prediction: %f meters", apogeePrediction_m);
		ImGui::End();
	}

	if (ImGui::Begin("Navigation filter"))
	{
		static bool outOfDate = true;

		static AB_Settings s = AB_Default_Settings();

		AB_Filter f;
		AB_Filter_Initialize(f);

		AB_Filter_Inputs inputs;

		inputs.dt = CONFIG_RUNTIME_INTERVAL_MS / 1000.0;
		const float BASE_ALTITUDE = 0; // TODO figure out significance of this

		static float
			time_s[log_len] = { 0 },
			velocityHoriz_mps[log_len] = { 0 },
			zenith_deg[log_len] = { 0 },
			altitude_m[log_len] = { 0 },
			altitudeMeasured_m[log_len] = { 0 },
			velocityZ_mps[log_len] = { 0 },
			thetaZ_rad[log_len] = { 0 },
			lowGAccelZMeasured_mps2[log_len] = { 0 },
			highGAccelZMeasured_mps2[log_len] = { 0 },
			gyroXMeasured_degps[log_len] = { 0 },
			gyroYMeasured_degps[log_len] = { 0 },
			gyroZMeasured_degps[log_len] = { 0 },
			accelerationZWorld_mps2[log_len] = { 0 },
			velocityZWorld_mps[log_len] = { 0 };

		static float altitudeMax_m = FLT_MIN;
		static float altitudeMin_m = FLT_MAX;
		static float timeMax_s = 0, timeMin_s = 0;

		const char* qColumnLabels[] = {
			"Altitude",
			"Velocity",
			"Barometer"
		};

		outOfDate |= MatrixEditor("Q, Vertical Filter High G Accel", s.VertHighGQ, qColumnLabels);
		outOfDate |= MatrixEditor("Q, Vertical Filter Low G Accel", s.VertLowGQ, qColumnLabels);

		const char* rBaroColumnLabels[] = {
			"Baro",
		};

		outOfDate |= MatrixEditor("R, Vertical Filter Barometer", s.VertBaroR, rBaroColumnLabels);

		if (outOfDate)
		{
			outOfDate = false;
			
			for (int i = 0; i < log_len; i++)
			{
				log_packet_v3 log_p = ((log_packet_v3*)log_cropped_logv3)[i];

				// Update sensor data in Master Struct
				inputs.Accelerometer_mps2 << log_p.bmi323_accel_y * G, log_p.bmi323_accel_x * G, log_p.bmi323_accel_z * G;
				inputs.AccelerometerHG_mps2 << -log_p.adxl375_accel_x * G, -log_p.adxl375_accel_y * G, log_p.adxl375_accel_z * G;
				inputs.Gyroscope_radps << log_p.bmi323_gyro_x * (M_PI / 180.0f),
					log_p.bmi323_gyro_y * (M_PI / 180.0f),
					log_p.bmi323_gyro_z * (M_PI / 180.0f);
				inputs.Barometer_m = get_altitude_from_pressure(log_p.ms5607_pressure_mbar * 100);
				inputs.GPS.setZero();

				AB_Filter_Process(f, inputs, s);

				altitudeMeasured_m[i] = get_altitude_from_pressure(log_p.ms5607_pressure_mbar * 100);
				lowGAccelZMeasured_mps2[i] = log_p.bmi323_accel_z * G;
				highGAccelZMeasured_mps2[i] = log_p.adxl375_accel_z * G;
				gyroXMeasured_degps[i] = log_p.bmi323_gyro_x;
				gyroYMeasured_degps[i] = log_p.bmi323_gyro_y;
				gyroZMeasured_degps[i] = log_p.bmi323_gyro_z;

				accelerationZWorld_mps2[i] = f.AccelerationWorld.z();
				velocityZWorld_mps[i] = f.VertState.Velocity_Up;

				g_nav_quat_w[i] = f.AttState.Quaternion_Body_To_ENU.w();
				g_nav_quat_x[i] = f.AttState.Quaternion_Body_To_ENU.x();
				g_nav_quat_y[i] = f.AttState.Quaternion_Body_To_ENU.y();
				g_nav_quat_z[i] = f.AttState.Quaternion_Body_To_ENU.z();

				time_s[i] = log_p.time_boot_ms / 1000.0;
				velocityHoriz_mps[i] = sqrt(f.HorizState.Velocity_North * f.HorizState.Velocity_North +
					f.HorizState.Velocity_East * f.HorizState.Velocity_East);
				zenith_deg[i] = atan2(velocityHoriz_mps[i], f.VertState.Velocity_Up) * RAD_TO_DEG;
				altitude_m[i] = f.VertState.Altitude;
				velocityZ_mps[i] = f.VertState.Velocity_Up;
				thetaZ_rad[i] = zenith_deg[i];

				if (altitude_m[i] > altitudeMax_m) altitudeMax_m = altitude_m[i];
				if (altitude_m[i] < altitudeMin_m) altitudeMin_m = altitude_m[i];
			}

			timeMax_s = time_s[log_len - 1];
			timeMin_s = time_s[0];
		}

		static ImPlotRect lims(timeMin_s, timeMax_s, 0, maxAltitude_m);

		if (ImGui::CollapsingHeader("Altitude") && ImPlot::BeginPlot("##Altitude"))
		{
			ImPlot::SetupAxes("Time (s)", "Altitude (m)");
			ImPlot::SetupAxisLinks(ImAxis_X1, &lims.X.Min, &lims.X.Max);
			ImPlot::SetupAxisLimits(ImAxis_Y1, altitudeMin_m, altitudeMax_m, ImPlotCond_Once);
			ImPlot::PlotLine("Altitude (filtered)", time_s, altitude_m, log_len, ImPlotLineFlags_None);
			ImPlot::PlotLine("Altitude (measured, barometric)", time_s, altitudeMeasured_m, log_len, ImPlotLineFlags_None);

			ImPlot::EndPlot();
		}

		if (ImGui::CollapsingHeader("Velocity Z") && ImPlot::BeginPlot("##Velocity Z"))
		{
			ImPlot::SetupAxes("Time (s)", "Velocity Z (m/s)");
			ImPlot::SetupAxisLinks(ImAxis_X1, &lims.X.Min, &lims.X.Max);
			ImPlot::SetupAxisLimits(ImAxis_Y1, 0, 400, ImPlotCond_Once);
			ImPlot::PlotLine("Velocity Z (filtered, world frame)", time_s, velocityZWorld_mps, log_len, ImPlotLineFlags_None);

			ImPlot::EndPlot();
		}

		if (ImGui::CollapsingHeader("Acceleration Z") && ImPlot::BeginPlot("##Acceleration Z"))
		{
			ImPlot::SetupAxes("Time (s)", "Acceleration Z (m/s^2)");
			ImPlot::SetupAxisLinks(ImAxis_X1, &lims.X.Min, &lims.X.Max);
			ImPlot::SetupAxisLimits(ImAxis_Y1, 0, 15 * G, ImPlotCond_Once);
			ImPlot::PlotLine("Acceleration Z (measured, low G sensor)", time_s, lowGAccelZMeasured_mps2, log_len, ImPlotLineFlags_None);
			ImPlot::PlotLine("Acceleration Z (measured, high G sensor)", time_s, highGAccelZMeasured_mps2, log_len, ImPlotLineFlags_None);
			ImPlot::PlotLine("Acceleration Z (filtered, world frame)", time_s, accelerationZWorld_mps2, log_len, ImPlotLineFlags_None);

			ImPlot::EndPlot();
		}

		if (ImGui::CollapsingHeader("Gyroscope") && ImPlot::BeginPlot("##Gyroscope"))
		{
			ImPlot::SetupAxes("Time (s)", "Angular Vel (deg/s)");
			ImPlot::SetupAxisLinks(ImAxis_X1, &lims.X.Min, &lims.X.Max);
			ImPlot::SetupAxisLimits(ImAxis_Y1, -1000, 1000, ImPlotCond_Once);
			ImPlot::PlotLine("Gyroscope X (measured)", time_s, gyroXMeasured_degps, log_len, ImPlotLineFlags_None);
			ImPlot::PlotLine("Gyroscope Y (measured)", time_s, gyroYMeasured_degps, log_len, ImPlotLineFlags_None);
			ImPlot::PlotLine("Gyroscope Z (measured)", time_s, gyroZMeasured_degps, log_len, ImPlotLineFlags_None);
			
			if (ImPlot::IsPlotHovered())
			{
				float t = (float)ImPlot::GetPlotMousePos().x;
				g_nav_hovered_time = t;
				int lo = 0, hi = log_len - 1;
				while (lo < hi) { int mid = (lo + hi) / 2; if (time_s[mid] < t) lo = mid + 1; else hi = mid; }
				g_nav_hovered_idx = lo;
			}
			if (g_nav_hovered_idx >= 0)
			{
				ImPlotRect limits = ImPlot::GetPlotLimits();
				ImVec2 top = ImPlot::PlotToPixels(g_nav_hovered_time, limits.Y.Max);
				ImVec2 bot = ImPlot::PlotToPixels(g_nav_hovered_time, limits.Y.Min);
				ImPlot::GetPlotDrawList()->AddLine(top, bot, IM_COL32(255, 200, 0, 120), 1.5f);
			}
			ImPlot::EndPlot();
		}

		ImGui::End();
	}

	if (ImGui::Begin("Attitude (Quaternion Body-to-ENU)"))
	{
		if (g_nav_hovered_idx < 0)
		{
			ImGui::TextDisabled("Hover over a graph in the Navigation filter window to see orientation.");
		}
		else
		{
			int idx = g_nav_hovered_idx;
			float w  = g_nav_quat_w[idx], qx = g_nav_quat_x[idx],
			      qy = g_nav_quat_y[idx], qz = g_nav_quat_z[idx];

			ImGui::Text("t = %.3f s", g_nav_hovered_time);
			ImGui::Text("q: w=%.3f  x=%.3f  y=%.3f  z=%.3f", w, qx, qy, qz);

			Quaternionf q(w, qx, qy, qz);
			q.normalize();
			Matrix3f R = q.toRotationMatrix();

			ImVec2 canvasPos = ImGui::GetCursorScreenPos();
			ImVec2 available = ImGui::GetContentRegionAvail();
			float size = available.x < available.y ? available.x : available.y;
			if (size < 50.0f) size = 200.0f;

			ImGui::InvisibleButton("##att3d", ImVec2(size, size));
			ImVec2 center = ImVec2(canvasPos.x + size * 0.5f, canvasPos.y + size * 0.5f);
			float scale = size * 0.35f;

			ImDrawList* dl = ImGui::GetWindowDrawList();

			dl->AddRectFilled(canvasPos, ImVec2(canvasPos.x + size, canvasPos.y + size),
			                  IM_COL32(20, 20, 25, 255));
			dl->AddRect(canvasPos, ImVec2(canvasPos.x + size, canvasPos.y + size),
			            IM_COL32(80, 80, 80, 255));

			// Reference sphere circles
			const int segs = 48;
			float r = 0.75f;
			for (int i = 0; i < segs; i++)
			{
				float a0 = (float)i / segs * 2.0f * (float)M_PI;
				float a1 = (float)(i + 1) / segs * 2.0f * (float)M_PI;
				dl->AddLine(Project3D(r * cosf(a0), r * sinf(a0), 0, center, scale),
				            Project3D(r * cosf(a1), r * sinf(a1), 0, center, scale),
				            IM_COL32(50, 50, 60, 200));
				dl->AddLine(Project3D(r * cosf(a0), 0, r * sinf(a0), center, scale),
				            Project3D(r * cosf(a1), 0, r * sinf(a1), center, scale),
				            IM_COL32(50, 50, 60, 200));
			}

			auto drawArrow = [&](float ax, float ay, float az, ImU32 color, const char* label)
			{
				ImVec2 origin = Project3D(0, 0, 0, center, scale);
				ImVec2 tip    = Project3D(ax, ay, az, center, scale);
				dl->AddLine(origin, tip, color, 2.0f);
				dl->AddCircleFilled(tip, 4.5f, color);
				dl->AddText(ImVec2(tip.x + 5, tip.y - 5), color, label);
			};

			// ENU reference axes (dim)
			drawArrow(r, 0, 0, IM_COL32(120, 50, 50, 200), "E");
			drawArrow(0, r, 0, IM_COL32(50, 120, 50, 200), "N");
			drawArrow(0, 0, r, IM_COL32(50, 50, 120, 200), "U");

			// Body frame axes expressed in ENU (bright)
			drawArrow(R(0,0), R(1,0), R(2,0), IM_COL32(255, 80, 80, 255), "Bx");
			drawArrow(R(0,1), R(1,1), R(2,1), IM_COL32(80, 255, 80, 255), "By");
			drawArrow(R(0,2), R(1,2), R(2,2), IM_COL32(80, 80, 255, 255), "Bz");

			dl->AddCircleFilled(Project3D(0, 0, 0, center, scale), 5.0f, IM_COL32(220, 220, 220, 255));

			ImGui::Spacing();
			ImGui::TextColored(ImVec4(0.47f, 0.20f, 0.20f, 1.0f), "dim  = ENU frame  (E / N / U)");
			ImGui::TextColored(ImVec4(1.00f, 0.31f, 0.31f, 1.0f), "bright = Body frame (Bx / By / Bz)");
		}
		ImGui::End();
	}

	if (ImGui::Begin("Calculated airbrake deployment angle"))
	{
		static bool outOfDate = true;
		static float calculatedAirbrakeDeployment_pct = 0;
		static int itersReqd = 0;

		static float targetApogee_m = 9144;
		static apogeeIC ic = {
			.altitude_m = 0,
			.velocityZ_mps = 0,
			.thetaZ_rad = 0,
			.airbrakeDeployment_pct = 0,
		};

		ImGui::Text("Initial conditions:");
		outOfDate |= ImGui::SliderFloat("Altitude (m)", &ic.altitude_m, 0, 10000);
		outOfDate |= ImGui::SliderFloat("Velocity (m/s)", &ic.velocityZ_mps, 0, 1000);
		outOfDate |= ImGui::SliderFloat("Theta Z (rad)", &ic.thetaZ_rad, 0, 1.57);
		outOfDate |= ImGui::SliderFloat("Airbrake deployment (%)", &ic.airbrakeDeployment_pct, 0, 100);

		ImGui::Text("Configuration:");
		outOfDate |= ImGui::SliderFloat("Target apogee (m)", &targetApogee_m, 0, 10000);

		if (outOfDate)
		{
			outOfDate = false;
			calculatedAirbrakeDeployment_pct = PredictDeploymentPct(ic, targetApogee_m, &itersReqd);
		}

		ImGui::Text("Calculated airbrake deployment: %f percent", calculatedAirbrakeDeployment_pct);
		ImGui::End();
	}
}