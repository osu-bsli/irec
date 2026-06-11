#pragma once

#include <cstddef>
#include <cstdint>

namespace fs
{
    class File
    {
    public:
        size_t write(uint8_t *data, size_t len) { return len; }
        void flush() {}
        void close() {}
    };
}

class SDClass
{
public:
    void end() {}
};

extern SDClass SD;
