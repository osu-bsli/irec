#pragma once

#include <cstdlib>
#include <cstdio>
#include <cstdarg>
#include <cstdint>

#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

class SerialClass {
public:
    void begin();
    void begin(int baud) { begin(); }

    int available()
    {
        int bytes_available = 0;

        if (ioctl(0, FIONREAD, &bytes_available) == -1) {
            return -1;
        }

        return bytes_available;
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
        putc(val, stdout);
        return 1;
    }

    int read()
    {
        return getchar(); 
    }
};

static SerialClass Serial;