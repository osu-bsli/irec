#include <Arduino.h>
#include <SPI.h>
#include <RH_RF95.h>
#include <SPI.h>
#include <SD.h>

/************ Radio Setup ***************/

#define RF95_FREQ 915.0

#define RFM95_CS   5
#define RFM95_INT  0
#define RFM95_RST  6
#define BrianTag "[KF8EBM] "

// splitting a string and return the part nr index split by separator
String getStringPartByNr(String data, char separator, int index) {
    int stringData = 0;        //variable to count data part nr 
    String dataPart = "";      //variable to hole the return text

    for(int i = 0; i<data.length()-1; i++) {    //Walk through the text one letter at a time
        if(data[i]==separator) {
            //Count the number of times separator character appears in the text
            stringData++;
        } else if(stringData==index) {
            //get the text when separator is the rignt one
            dataPart.concat(data[i]);
        } else if(stringData>index) {
            //return text and stop if the next separator appears - to save CPU-time
            return dataPart;
            break;
        }
    }
    //return text if this is the last part
    return dataPart;
}

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

int16_t packetnum = 0;  // packet counter, we increment per xmission

File FlightData;

RH_RF95 rf95(RFM95_CS, RFM95_INT);

void setup() {
  delay(3000);
  Serial.begin(9600);
  //while (!Serial) delay(1); // Wait for Serial Console (comment out line if no computer)
  
  SPI.setRX(4);
  SPI.setTX(3);
  SPI.setSCK(2);
  SPI.begin();

  SPI1.setRX(12);
  SPI1.setTX(11);
  SPI1.setSCK(10);
  SPI1.begin();

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
      Serial.println("RFM95 radio init failed - power cycle please");
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

  Serial.println("Connecting to SD card via SPI...");
  if(!SD.begin(9,SPI_HALF_SPEED,SPI1)) {
    Serial.println("Failed to connect to SD card");
  }
  else {
    Serial.println("Successfully connected to SD card");
    Serial.println("SD initialized.");
    SD.mkdir("");
  }
}

void loop() {

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

}
