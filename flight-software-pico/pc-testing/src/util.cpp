#include "util.h"

#include "rapidcsv.h"
#include "MathFunctions.h"

rapidcsv::Document doc(
    "test/cd-by-airbrake-deployment-pct-and-mach.csv",
    rapidcsv::LabelParams(0, 0) // row 0 = col headers, col 0 = row labels (Mach)
);

float r_squared_of_drag_coeff_func_against_theoretical(float ground_level_temp_celcius)
{
    /* Determine R^2 of the regression fit */

    // Column order in CSV: 100%, 90%, 80%, ..., 0%
    const float ab_deployment_pcts[] = {100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 0};

    const float speed_of_sound_sl = 343; // m/s

    int nRows = doc.GetRowCount();
    int nCols = doc.GetColumnCount();

    float sse = 0; // sum of squared errors (SSE)
    float sst = 0; // sum of squared totals (SST)

    for (int i = 0; i < nRows; i++)
    {
        float mach = std::stof(doc.GetRowName(i));
        float velocity = mach * speed_of_sound_sl;

        for (int j = 0; j < nCols && j < 11; j++)
        {
            float actual = doc.GetCell<float>(j, i);
            float predicted = drag_coeff(ab_deployment_pcts[j], velocity, 0.0f, ground_level_temp_celcius);
            float error = actual - predicted;
            sse += error * error;
            sst += actual * actual;
        }
    }

    float r_squared = 1 - sse / sst;
    return r_squared;
}