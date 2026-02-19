#include <error.h>
#include <stdint.h>

FSError read_register(
  uint8_t i2c_base_address,
  uint8_t reg,
  uint8_t *data,
  uint8_t length
);
FSError write_register(
  uint8_t i2c_base_address,
  uint8_t reg,
  uint8_t *data,
  uint8_t length
);
