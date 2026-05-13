#pragma once

static inline float CHECK_NAN(float x) {
    assert(!isnan(x));
    return x;
}