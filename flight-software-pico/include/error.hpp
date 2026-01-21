/*
  Standardized errors for our firmware
  Author: Diego Noria
*/
#pragma once

#include <stdint.h>

typedef enum FSError: uint8_t {
  SUCCESS,
  FAILURE,
  INSUFFICIENT_MEMORY,
} FSError;
