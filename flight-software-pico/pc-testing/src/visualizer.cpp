// Main loop
#include "rapidcsv.h"
#include <SDL3/SDL.h>
#include <implot.h>
#include <imgui_impl_sdl3.h>
#include <ranges>
#include <tuple>

#define _USE_MATH_DEFINES // needed on MSVC for math.h to include M_PI
#include <math.h>
#include "MathFunctions.h"

float azimuthElevation_rad;
float velocity_mps;

std::vector<float> v_altitude_m;
std::vector<float> v_Cd;

bool graphOutOfDate = true;
const int maxAltitude_m = 9144; // 30000 ft

void SetupVisualizer()
{
    ImPlot::CreateContext();

    v_altitude_m.reserve(maxAltitude_m + 1);
    v_Cd.reserve(maxAltitude_m + 1);

    for (int i = 0; i < maxAltitude_m + 1; i++)
    {
        v_altitude_m.push_back(i);
    }
}


void RunFilter()
{
    v_Cd.clear();

    for (int i = 0; i < v_altitude_m.size(); i++)
    {
        float altitude_m = v_altitude_m[i];
        
        v_Cd.push_back(drag_coeff(azimuthElevation_rad, velocity_mps, altitude_m));
    }
}

void ShowVisualizer()
{
    if (graphOutOfDate)
    {
        graphOutOfDate = false;
        RunFilter();
    }

    ImVec2 size = ImGui::GetContentRegionAvail();
    size.y /= 1;
    size.y -= ImGuiStyleVar_ItemSpacing;

    if (ImGui::Begin("Plots"))
    {
        // static ImPlotRect lims(0, 100, 0, maxAltitude_m);

        if (ImPlot::BeginAlignedPlots("AlignedGroup"))
        {
            if (ImPlot::BeginPlot("Cd vs. Altitude", size))
            {
                ImPlot::SetupAxes("Altitude (m)", "Drag coefficient (Cd)");
                // ImPlot::SetupAxisLinks(ImAxis_X1, &lims.X.Min, &lims.X.Max);
                ImPlot::SetupAxisLimits(ImAxis_X1, 0, maxAltitude_m, ImPlotCond_Once); 
                ImPlot::SetupAxisLimits(ImAxis_Y1, 0, 1, ImPlotCond_Once); 
                ImPlot::PlotLine("Drag coefficient (Cd)", v_altitude_m.data(), v_Cd.data(), v_altitude_m.size(), ImPlotLineFlags_None);
                ImPlot::EndPlot();
            }

            ImPlot::EndAlignedPlots();
        }

        ImGui::End();
    }

    if (ImGui::Begin("Options"))
    {
        ImGui::Text("Drag options");
        graphOutOfDate |= ImGui::SliderFloat("Azimuth elevation (rad)", &azimuthElevation_rad, 0, M_PI);
        graphOutOfDate |= ImGui::SliderFloat("Velocity (m/s)", &velocity_mps, 0, 1000);

        ImGui::End();
    }
}