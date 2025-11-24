#include <WiFi.h>
#include <WebServer.h>

#include "airbrakes/airbrakes.h"

// ==================
// CONFIGURE THESE
// ==================
const char* ssid     = "BSLI-IREC-for-FC";
const char* password = "Buckeyesli1!";

// Change this pin if needed
const int LED_PIN = 2;  // Often onboard LED on ESP32 dev boards

WebServer server(80);

// ---------- HTML PAGE ----------
String getPage() {
  String html = R"rawliteral(
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>ESP32 Control Panel</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #20232a;
      color: #ffffff;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      margin: 0;
    }
    .card {
      background: #282c34;
      padding: 20px 30px;
      border-radius: 12px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.4);
      text-align: center;
      min-width: 260px;
    }
    h1 {
      margin-top: 0;
    }
    .buttons {
      display: flex;
      flex-direction: column;
      gap: 10px;
      margin-top: 15px;
    }
    button {
      padding: 10px 15px;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      cursor: pointer;
    }
    .on      { background: #4caf50; color: #fff; }
    .off     { background: #f44336; color: #fff; }
    .toggle  { background: #2196f3; color: #fff; }
    button:active {
      transform: scale(0.97);
    }
    .status {
      margin-top: 10px;
      font-size: 14px;
      opacity: 0.8;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>ESP32 Control Panel</h1>
    <p>Press a button to do something on the ESP32.</p>
    <div class="buttons">
      <form action="/fully_retract_airbrakes" method="GET">
        <button class="on" type="submit">Fully Retract Airbrakes</button>
      </form>
      <form action="/fully_deploy_airbrakes" method="GET">
        <button class="off" type="submit">Fully Deploy Airbrakes</button>
      </form>
    </div>
    <div class="status">
      <p>Page will reload after each action.</p>
    </div>
  </div>
</body>
</html>
)rawliteral";

  return html;
}

// ---------- HANDLERS ----------
void handleRoot() {
  server.send(200, "text/html", getPage());
}

volatile bool do_fully_retract_airbrakes  = false;
volatile bool do_fully_deploy_airbrakes = false;

void handle_fully_retract_airbrakes() {
  do_fully_retract_airbrakes = true;
  Serial.println("Fully retracting via web panel");
  server.sendHeader("Location", "/");
  server.send(303);                 // Redirect back to main page
}

void handle_fully_deploy_airbrakes() {
  do_fully_deploy_airbrakes = true;
  Serial.println("Fully deploying via web panel");
  server.sendHeader("Location", "/");
  server.send(303);
}

void handleToggle() {
  int state = digitalRead(LED_PIN); 
  digitalWrite(LED_PIN, !state);    // YOUR ACTION HERE
  Serial.println("LED TOGGLED");
  server.sendHeader("Location", "/");
  server.send(303);
}

void handleNotFound() {
  server.send(404, "text/plain", "404: Not Found");
}

// ---------- SETUP & LOOP ----------
void web_panel_setup() {

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  // ==============================
  // CONNECT AS WI-FI STATION
  // ==============================
  Serial.println();
  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected!");
  Serial.print("ESP32 IP address: ");
  Serial.println(WiFi.localIP());

  // If you'd rather run as an Access Point instead,
  // comment out WiFi.begin() stuff above and use:
  //
  // WiFi.softAP("ESP32-Panel", "12345678");
  // Serial.print("AP IP address: ");
  // Serial.println(WiFi.softAPIP());

  // Setup web server routes
  server.on("/", handleRoot);
  server.on("/fully_retract_airbrakes", handle_fully_retract_airbrakes);
  server.on("/fully_deploy_airbrakes", handle_fully_deploy_airbrakes);
  server.on("/toggle", handleToggle);
  server.onNotFound(handleNotFound);

  server.begin();
  Serial.println("HTTP server started");
}

void web_panel_update()
{
  server.handleClient();

  if (do_fully_retract_airbrakes)
  {
    do_fully_retract_airbrakes = false;
    fully_retract_airbrakes();
  }
  
  if (do_fully_deploy_airbrakes)
  {
    do_fully_deploy_airbrakes = false;
    fully_deploy_airbrakes();
  }
}