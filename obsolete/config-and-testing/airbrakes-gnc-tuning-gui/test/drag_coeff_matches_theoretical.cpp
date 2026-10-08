#include "../src/util.h"

#include "rapidcsv.h"
#include "MathFunctions.h"

int main()
{
    float ground_level_temp_celcius = 25;
    float r_squared = r_squared_of_drag_coeff_func_against_theoretical(ground_level_temp_celcius);

    printf("R^2: %f\n", r_squared);

    return 0;
}