#pragma once

#include <cstdlib>
#include <cstdio>
#include <cstdarg>
#include <cstdint>

#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

#ifdef STUB_SERIAL_IN_MEMORY
#include "serial_channel.h"
#include <FreeRTOS.h>
#include <task.h>
#endif

class SerialClass {
public:
    void begin();
    void begin(int baud) { begin(); }

    int available()
    {
#ifdef STUB_SERIAL_IN_MEMORY
        /* Blocks until the host feeds the next frame (see serial_channel.cpp),
         * so the firmware's `while (!Serial.available()) {}` HITL read loop
         * becomes a single deterministic rendezvous rather than a busy-wait. */
        return serial_channel_in_available();
#else
        int bytes_available = 0;

        if (ioctl(0, FIONREAD, &bytes_available) == -1) {
            return -1;
        }

        return bytes_available;
#endif
    }

    int peek()
    {
        int ch = getchar();       // Fetch the next character
        if (ch != EOF) {
            ungetc(ch, stdin);    // Push it back into the stream if it's valid
        }
        return ch;                // Returns the character or EOF
    }

    int printf(const char *fmt, ...)
    {
        va_list args;
        va_start(args, fmt);
        int ret = vprintf(fmt, args);
        va_end(args);
        return ret;
    }

    int print(const char* str)
    {
        return printf(str);
    }

    int println(int val)
    {
        return printf("%d\n", val);
    }

    int println(const char* str)
    {
        int ret = printf(str);
        ret += printf("\n");
        return ret;
    }

    int write(uint8_t val)
    {
#ifdef STUB_SERIAL_IN_MEMORY
        /* The HITL deployment-% reply byte goes back to the host. */
        serial_channel_out_write(val);
        return 1;
#else
        putc(val, stdout);
        return 1;
#endif
    }

    int read()
    {
#ifdef STUB_SERIAL_IN_MEMORY
        return serial_channel_in_read();
#else
        return getchar();
#endif
    }
};

static SerialClass Serial;