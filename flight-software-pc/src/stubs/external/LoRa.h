#pragma once

#include <cstdint>
#include <cstddef>

#include <SPI.h>

class LoRaClass
{
private:
    uint32_t _frf = 0;

public:
    bool has_begun = 0;

    int begin(long frequency)
    {
        has_begun = 1;
        return 1;
    }

    long getFrequency() {
        // return (_frf * 32000000) >> 19;
        return 123456789;
    }
    void setFrequency(long frequency) {
        _frf = ((uint64_t)frequency << 19) / 32000000;
    }
    void setSignalBandwidth(long sbw) {}

    int packetRssi()
    {
        return -123456789;
    }

    int beginPacket(int implicitHeader = false) { return 1; }
    int endPacket(bool async = false) { return 1; }

    size_t write(uint8_t byte) { return 1; }
    size_t write(const uint8_t *buffer, size_t size) { return size; }

    void receive(int size = 0) {}

    void setGain(uint8_t gain) {};

    void setPins(int ss = 0, int reset = 0, int dio0 = 0) {}
    void setSPI(SPIClass &spi) {}

    int read() { return 0xFF; }

    void onReceive(void (*callback)(int)) {}
};

extern LoRaClass LoRa;