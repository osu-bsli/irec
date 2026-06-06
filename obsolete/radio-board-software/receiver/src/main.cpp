// The Game of Life, also known simply as Life, is a cellular automaton
// devised by the British mathematician John Horton Conway in 1970.
//  https://en.wikipedia.org/wiki/Conway's_Game_of_Life

#include <SPI.h>
#include <LoRa.h>
#include <TFT_eSPI.h> // Hardware-specific library

#define PIN_LED 13

TFT_eSPI tft = TFT_eSPI(); // Invoke custom library

void setup()
{

  // Set up the display
  tft.init();
  tft.setRotation(3);
  tft.fillScreen(TFT_BLACK);
  tft.setTextSize(1);
  tft.setTextColor(TFT_WHITE);
  tft.setCursor(0, 0);

  // Display a simple splash screen
  tft.fillScreen(TFT_BLACK);
  tft.setTextSize(2);

  tft.println("LoRa Receiver");

  SPI.begin(32, 33, 25);
  LoRa.setPins(16, 15, 4);
  while (!LoRa.begin(433E6))
  {
    pinMode(PIN_LED, OUTPUT);
    digitalWrite(PIN_LED, !digitalRead(PIN_LED));
    // tft.print(".");
    delay(500);
  }

  LoRa.setSignalBandwidth(125E3);
  LoRa.setSpreadingFactor(12);
  LoRa.setPreambleLength(8);

  digitalWrite(13, 1);

  tft.println("LoRa Receiver started!");
}

void loop()
{
  int packetSize = LoRa.parsePacket(11);
  if (packetSize)
  {
    tft.fillScreen(TFT_BLACK);
    tft.setCursor(0, 0);
    tft.setTextSize(4);
    // tft.println("Packet recv'd");
    tft.print("SF: ");
    tft.println(LoRa.getSpreadingFactor());
    tft.print("BW: ");
    tft.println(LoRa.getSignalBandwidth());
    tft.println("Message:");
    tft.println(LoRa.readString());
    tft.println("RSSI:");
    tft.setTextSize(10);
    tft.println(LoRa.packetRssi());

    pinMode(PIN_LED, OUTPUT);
    digitalWrite(PIN_LED, !digitalRead(PIN_LED));
  }
}
