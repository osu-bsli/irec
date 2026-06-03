#pragma once

class SPIClass {
public:
    void setSCK(int pin) {}
    void setMOSI(int pin) {}
    void setMISO(int pin) {}
};

static SPIClass SPI;
static SPIClass SPI1;