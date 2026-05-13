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

class OutDataEntry
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
    std::vector<OutDataEntry> out_data_entries;

    SingleInMultiOutData(std::string in_data_label)
    {
        this->in_data_label = in_data_label;
    }

    void AddOutDataSource(std::string label, std::function<float(float)> data_source_func)
    {
        OutDataEntry e = {
            .v_data = std::vector<float>(),
            .label = label,
            .data_source_func = data_source_func,
        };
        out_data_entries.push_back(e);
    }

    void PushBackInDataPoint(float val)
    {
        this->v_in_data.push_back(val);
    }

    void ClearOutDataPoints()
    {
        for (auto &e : out_data_entries)
        {
            e.v_data.clear();
        }
    }

    void GenerateOutDataPoints()
    {
        for (auto &e : out_data_entries)
        {
            for (float in_val : v_in_data)
            {
                e.v_data.push_back(e.data_source_func(in_val));
            }
        }
    }

    int NumEntries()
    {
        return v_in_data.size();
    }
};

SingleInMultiOutData altitude_m("Altitude (m)");

bool graphOutOfDate = true;
const int maxAltitude_m = 9144; // 30000 ft

float azimuthElevation_deg;
float velocity_mps;

float data_source_func_Cd(float altitude_m)
{
    return drag_coeff(azimuthElevation_deg, velocity_mps, altitude_m);
}

void SetupVisualizer()
{
    ImPlot::CreateContext();

    for (int i = 0; i < maxAltitude_m + 1; i++)
    {
        altitude_m.PushBackInDataPoint(i);
    }

    altitude_m.AddOutDataSource("Drag coefficient (Cd)", data_source_func_Cd);
}

void RunFilter()
{
    altitude_m.ClearOutDataPoints();
    altitude_m.GenerateOutDataPoints();
}

void ShowVisualizer()
{
    if (graphOutOfDate)
    {
        graphOutOfDate = false;
        RunFilter();
    }

    if (ImGui::Begin("Plots"))
    {
        ImVec2 size = ImGui::GetContentRegionAvail();
        size.y /= 1;
        size.y -= ImGuiStyleVar_ItemSpacing;

        // static ImPlotRect lims(0, 100, 0, maxAltitude_m);

        if (ImPlot::BeginAlignedPlots("AlignedGroup"))
        {
            for (const auto &e : altitude_m.out_data_entries)
            {
                if (ImPlot::BeginPlot("Plot", size))
                {
                    ImPlot::SetupAxes(altitude_m.in_data_label.c_str(), e.label.c_str());
                    // ImPlot::SetupAxisLinks(ImAxis_X1, &lims.X.Min, &lims.X.Max);
                    ImPlot::SetupAxisLimits(ImAxis_X1, 0, maxAltitude_m, ImPlotCond_Once);
                    ImPlot::SetupAxisLimits(ImAxis_Y1, 0, 1, ImPlotCond_Once);
                    ImPlot::PlotLine(e.label.c_str(), altitude_m.v_in_data.data(), e.v_data.data(), altitude_m.NumEntries(), ImPlotLineFlags_None);
                    ImPlot::EndPlot();
                }
            }

            ImPlot::EndAlignedPlots();
        }

        ImGui::End();
    }

    if (ImGui::Begin("Options"))
    {
        ImGui::Text("Drag options");
        graphOutOfDate |= ImGui::SliderFloat("Azimuth elevation (deg)", &azimuthElevation_deg, 0, 90);
        graphOutOfDate |= ImGui::SliderFloat("Velocity (m/s)", &velocity_mps, 0, 1000);
        ImGui::End();
    }
}