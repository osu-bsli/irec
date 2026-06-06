#pragma once

void start_arduino_tasks();

#define stub_println(...) printf("[stub " __FILE_NAME__ "] " __VA_ARGS__); printf("\r\n"); fflush(stdout)