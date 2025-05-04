// The Game of Life, also known simply as Life, is a cellular automaton
// devised by the British mathematician John Horton Conway in 1970.
//  https://en.wikipedia.org/wiki/Conway's_Game_of_Life

#include <SPI.h>
#include <LoRa.h>
#include <TFT_eSPI.h> // Hardware-specific library

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
    pinMode(13, OUTPUT);
    digitalWrite(13, !digitalRead(13));
    // tft.print(".");
    delay(500);
  }

  digitalWrite(13, 1);

  tft.println("LoRa Receiver started!");
}

void loop()
{
}
