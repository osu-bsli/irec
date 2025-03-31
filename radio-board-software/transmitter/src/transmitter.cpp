
#include "SPI.h"
#include "S2LP.h"
#include "S2LP_PacketHandler.h"
#include <SoftwareSerial.h>

// pin defines for portability
#define SPI_MOSI_PIN PA7
#define SPI_MISO_PIN PA6
#define SPI_SCLK_PIN PB3
#define S2LP_CSN_PIN PA1
#define INTERRUPT_PIN PA8
#define GPIO_PIN PC0

#define FC_UART_RX PB7
#define FC_UART_TX PA9

HardwareSerial FCSerial(FC_UART_RX, FC_UART_TX); // RX on Pin PA10, TX on Pin PA9

SPIClass *devSPI;
S2LP *myS2LP;
const int buttonPin = PC13; // set buttonPin to digital pin PC13 */
int pushButtonState = LOW;

uint32_t get_frequency_band(uint8_t s_RfModuleBand);

/* Setup ---------------------------------------------------------------------*/

void setup()
{
    /*
     * PLEASE FUCKING TIE THE GROUNDS TOGETHER BETWEEN THE FC AND THE DEV BOARD OR YOU WILL REGRET IT
     */

    // Initialize serial for debugging.
    Serial.begin(9600);
    Serial.println("Hello world!");

    // Initialize USART1 for FC communication
    FCSerial.begin(9600);

    uint32_t s_frequency = 433000000;
    uint32_t s_RfXtalFrequency = 50000000;
    PAInfo_t paInfo;

    memset(&paInfo, 0, sizeof(PAInfo_t));

    // Initialize Led.
    pinMode(LED_BUILTIN, OUTPUT);

    // // Initialize Button
    pinMode(buttonPin, INPUT);
    pushButtonState = (digitalRead(buttonPin)) ? LOW : HIGH;

    // Put S2-LP in Shutdown
    pinMode(D7, OUTPUT);
    digitalWrite(D7, HIGH);

    // Initialize SPI
    devSPI = new SPIClass(SPI_MOSI_PIN, SPI_MISO_PIN, SPI_SCLK_PIN);
    devSPI->begin();
    Serial.println("SPI initialized");

    // Initialize S2-LP
    Serial.println("Initializing S2LP");
    myS2LP = new S2LP(devSPI, S2LP_CSN_PIN, INTERRUPT_PIN, GPIO_PIN, s_frequency, s_RfXtalFrequency, paInfo);
    myS2LP->begin();
    // myS2LP->attachS2LPReceive(callback_func);
}

/* Loop ----------------------------------------------------------------------*/

void loop()
{
    const int TX_BUF_SIZE = 128; // this is maximum allowed by S2LP 
    const int MICROS_TO_WAIT = 1000;
    uint8_t tx_buf[TX_BUF_SIZE];
    uint32_t tx_buf_head = 0;
    uint32_t microsWaiting = 0;

    while (tx_buf_head < TX_BUF_SIZE && microsWaiting < MICROS_TO_WAIT)
    {
        while (FCSerial.available() > 0 && tx_buf_head < TX_BUF_SIZE)
        {
            tx_buf[tx_buf_head] = FCSerial.read();
            tx_buf_head++;
            microsWaiting = 0;
        }
        delayMicroseconds(1);
        microsWaiting++;
    }

    if (tx_buf_head > 0)
    {
        if (0 == myS2LP->send(tx_buf, tx_buf_head, 0x44, true))
        {
            /* Toggle LED if successful */
            digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
        }
    }
}

uint32_t get_frequency_band(uint8_t s_RfModuleBand)
{
    uint32_t frequency = 0;
    const uint32_t band_frequencies[] = {
        169000000,
        315000000,
        433000000,
        868000000,
        915000000,
        450000000};

    if (s_RfModuleBand < (sizeof(band_frequencies) / sizeof(uint32_t)))
    {
        frequency = band_frequencies[s_RfModuleBand];
    }

    return frequency;
}
