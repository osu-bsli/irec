#include <Arduino.h>
#include <SPI.h>
#include <RH_RF95.h>
#include <SPI.h>

/************ Radio Setup ***************/

#define RF95_FREQ 915.0

#define RFM95_CS   5
#define RFM95_INT  0
#define RFM95_RST  6

#define BrianTag "KF8EBM "

struct __attribute__((packed)) telemetry_packet {
    char magic[9]; // 'FUCKPETER' in ASCII with no null terminator
    uint8_t size; // Total size of struct
    uint16_t crc16;

    uint8_t status_flags; // StatusFlags bitfield
    uint32_t time_boot_ms; // Timestamp (ms since system boot)
    float pitch; // Fused sensor data (unit: Euler angle deg)
    float yaw;   // Fused sensor data (unit: Euler angle deg)
    float roll;  // Fused sensor data (unit: Euler angle deg)
    float accel_magnitude; // Magnitude of acceleration (unit: G)
    float ms5607_pressure_mbar; // Pressure (unit: mbar)
};

// // Singleton instance of the radio driver
// RH_RF95 rf95(RFM95_CS, RFM95_INT);

int16_t packetnum = 0;  // packet counter, we increment per xmission

RH_RF95 rf95(RFM95_CS, RFM95_INT);

void setup() {
  delay(3000);
  Serial.begin(9600);
  //while (!Serial) delay(1); // Wait for Serial Console (comment out line if no computer)
  Serial.printf("hello");

  Serial.println("setup spi");
  SPI.setRX(4);
  SPI.setTX(3);
  SPI.setSCK(2);
  SPI.begin();
  Serial.println("done with spi");


  // Singleton instance of the radio driver

  pinMode(RFM95_RST, OUTPUT);
  digitalWrite(RFM95_RST, HIGH);

  Serial.println("Feather RFM95 TX Test!");
  Serial.println();

  // manual reset
  digitalWrite(RFM95_RST, LOW);
  delay(10);
  digitalWrite(RFM95_RST, HIGH);
  delay(10);

  if (!rf95.init()) {
    Serial.println("RFM95 radio init failed");
    while (1) {
      Serial.println("help");
      delay(1000);
    }
  }
  Serial.println("RFM95 radio init OK!");
  // // Defaults after init are 434.0MHz, modulation GFSK_Rb250Fd250, +13dbM (for low power module)
  // // No encryption
  if (!rf95.setFrequency(RF95_FREQ)) {
    Serial.println("setFrequency failed");
  }

  // If you are using a high power RF95 eg RFM95HW, you *must* set a Tx power with the
  // ishighpowermodule flag set like this:
  rf95.setTxPower(20, true);  // range from 14-20 for power, 2nd arg must be true for 95HCW

  // // The encryption key has to be the same as the one in the server
  // uint8_t key[] = { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
  //                   0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};
  // rf95.setEncryptionKey(key);

  Serial.print("RFM95 radio @");  Serial.print((int)RF95_FREQ);  Serial.println(" MHz");
}

void loop() {
  // 1. LISTEN for incoming LoRa transmissions
  if (rf95.available()) {
    uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
    uint8_t len = sizeof(buf);

    if (rf95.recv(buf, &len)) {
      Serial.print("Received [RSSI: ");
      Serial.print(rf95.lastRssi());
      Serial.print("]: ");
      Serial.println((char*)buf);
    } else {
      Serial.println("Receive failed");
    }
  }

  // 2. CHECK Serial Monitor for outgoing text
  if (Serial.available() > 0) {
    // Read the string until newline
    String input = BrianTag + Serial.readStringUntil('\n');
    input.trim(); // Remove any stray whitespace/carriage returns

    if (input.length() > 0) {
      Serial.print("Sending: ");
      Serial.println(input);
      
      // Convert String to uint8_t array and send
      rf95.send((uint8_t *)input.c_str(), input.length() + 1);
      rf95.waitPacketSent();
    }
  }
}