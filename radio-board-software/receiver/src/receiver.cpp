/**
 ******************************************************************************
 * @file    X_NUCLEO_S2868A1_HelloWorld.ino
 * @author  SRA
 * @version V1.0.0
 * @date    12 March 2020
 * @brief   Arduino test application for the STMicrolectronics X-NUCLEO-S2868A1
 *          Sub-1 GHz 868 MHz RF expansion board based on S2-LP module.
 *          This application makes use of C++ classes obtained from the C
 *          components' drivers.
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; COPYRIGHT(c) 2020 STMicroelectronics</center></h2>
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************
 */

#include "SPI.h"
#include "S2LP.h"
#include <SoftwareSerial.h>

// pin defines for portability
#define SPI_MOSI_PIN PA7
#define SPI_MISO_PIN PA6
#define SPI_SCLK_PIN PB3
#define SPI_CSN_PIN PA1
#define INTERRUPT_PIN PA8
#define GPIO_PIN PC0

SPIClass *devSPI;
S2LP *myS2LP;
const int buttonPin = PC13; // set buttonPin to digital pin PC13 */
int pushButtonState = LOW;

static uint8_t send_buf[FIFO_SIZE] = {'S', '2', 'L', 'P', ' ', 'H', 'E', 'L', 'L', 'O', ' ', 'W', 'O', 'R', 'L', 'D', ' ', 'P', '2', 'P', ' ', 'D', 'E', 'M', 'O'};

void blink_led(void);
uint32_t get_frequency_band(uint8_t s_RfModuleBand);

/* Setup ---------------------------------------------------------------------*/

void rxCallback()
{
    uint8_t rx_buf[128];
    uint8_t num_bytes_to_read = myS2LP->getRecvPayloadLen();
    if (num_bytes_to_read > 0)
    {
        uint8_t num_bytes_received = myS2LP->read(rx_buf, num_bytes_to_read);

        Serial.write(rx_buf, num_bytes_received);
    }

    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
}

void setup()
{
    uint32_t s_frequency = 433000000;
    uint32_t s_RfXtalFrequency = 50000000;
    PAInfo_t paInfo;

    memset(&paInfo, 0, sizeof(PAInfo_t));

    // Initialize serial for output.
    Serial.begin(9600);

    // Initialize Led.
    pinMode(LED_BUILTIN, OUTPUT);

    // Initialize Button
    pinMode(buttonPin, INPUT);
    pushButtonState = (digitalRead(buttonPin)) ? LOW : HIGH;

    // Put S2-LP in Shutdown
    pinMode(D7, OUTPUT);
    digitalWrite(D7, HIGH);

    // Initialize SPI
    devSPI = new SPIClass(SPI_MOSI_PIN, SPI_MISO_PIN, SPI_SCLK_PIN);
    devSPI->begin();

    // Initialize S2-LP
    myS2LP = new S2LP(devSPI, SPI_CSN_PIN, INTERRUPT_PIN, GPIO_PIN, s_frequency, s_RfXtalFrequency, paInfo);
    myS2LP->begin();
    myS2LP->attachS2LPReceive(rxCallback);
}

/* Loop ----------------------------------------------------------------------*/

void loop()
{

    // if(digitalRead(buttonPin) == pushButtonState)
    //{
    /* Debouncing */
    // delay(50);

    /* Wait until the button is released */
    // while (digitalRead(buttonPin) == pushButtonState);

    /* Debouncing */
    // delay(50);

    // Send via uart
    // UARTSerial.print("Rcvd via UART: HELLO FRIEND! \n");

    // if(!myS2LP->send(send_buf, (strlen((char *)send_buf) + 1), 0x44, true))
    //{
    /* Blink LED */
    // blink_led();

    /* Print message */
    // SerialPort.print("Transmitted ");
    // SerialPort.print((strlen((char *)send_buf) + 1));
    // SerialPort.println(" bytes successfully");
    //} else
    //{
    // SerialPort.println("Error in transmission");
    //}
    //}

    // if (UARTSerial.available())
    // {
    //   String receivedData = UARTSerial.readString(); // Read until timeout or newline
    //   Serial.print("Received via UART: ");
    //   Serial.println(receivedData);
    //   blink_led();
    // }
}

void blink_led(void)
{
    digitalWrite(LED_BUILTIN, HIGH);
    delay(10);
    digitalWrite(LED_BUILTIN, LOW);
    delay(10);
    digitalWrite(LED_BUILTIN, HIGH);
    delay(10);
    digitalWrite(LED_BUILTIN, LOW);
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
