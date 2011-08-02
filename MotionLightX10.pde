/**
 * X10 Motion/Light Sensor
 * Sends the ON command if it's dark and motion detected; OFF otherwise.
 */

#include <x10.h>
#include <x10constants.h>

// CONFIG
const int statusLed = 13;       // status LED
const int PIRPin = 5;           // motion sensor
const int photoResPin = 0;      // light sensor

const int zcPin = 9;            // X10 0-xing pin
const int dataPin = 8;          // X10 data pin
const int houseCode = HOUSE_G;  // X10 house code
const int unitCode = UNIT_3;    // X10 unit code
const int repeat = 2;           // X10 command repeat count

const int delayBy = 180000;     // lights OFF delay
const int lightThreshold = 150; // light brightness threshold

// STATE
#define NO_MOTION 0
#define MOTION 1
#define MOTION_NO_LIGHT 2

// GLOBALS
x10 house = x10(zcPin, dataPin);
unsigned long lastMotionAt;
boolean lightsOn_;


void flashLed(int pin, int times, int wait) {
  for (int i = 0; i < times; i++) {
    digitalWrite(pin, HIGH);
    delay(wait);
    digitalWrite(pin, LOW);

    if (i + 1 < times) {
      delay(wait);
    }
  }
}

int readMotion()
{
  int motion = digitalRead(PIRPin);
  if (motion == LOW) {
    lastMotionAt = millis();
  }
  return (motion == LOW? HIGH: LOW);
}

unsigned long lastMotion()
{
  return lastMotionAt;
}

int readLight()
{
  return analogRead(photoResPin);
}

int state()
{
  int motion = readMotion();
  Serial.print("Motion: "); Serial.println(motion);
  int light = readLight();
  Serial.print("Light: "); Serial.println(light);

  if (motion == LOW)
  {
    unsigned long curTime = millis();
    if ((millis() - lastMotion()) > delayBy)
    {
      return NO_MOTION;
    }
    else
    {
      return MOTION;
    }
  }
  else if ((motion == HIGH) && (light > lightThreshold))
  {
    return MOTION;
  }
  else
  {
    return MOTION_NO_LIGHT;
  }
}

void turnLights(boolean state)
{
  lightsOn_ = state;

  // Send the ON/OFF command
  house.write(houseCode, unitCode, repeat);
  house.write(houseCode, (state == true)? ON: OFF, repeat);
}

boolean lightsState()
{
  return lightsOn_;
}


void setup()
{
  Serial.begin(9600);

  // Status LED
  pinMode(statusLed, OUTPUT);

  // Initialize motion sensor
  pinMode(PIRPin, INPUT);
  // wait for PIR to initialize
  delay(5000);
  Serial.println("Motion sensor initialized.");

  // Initialize light sensor
  pinMode(photoResPin, INPUT);
  Serial.println("Light sensor initialized.");

  // Initialize X10 module
  pinMode(zcPin, INPUT);
  pinMode(dataPin, OUTPUT);
  house.write(houseCode, ALL_UNITS_OFF, repeat);
  Serial.println("X10 controller initialized.");
}

void loop()
{
  switch (state()) {
    case NO_MOTION:
      Serial.println("No motion.");
      if (lightsState()) {
        Serial.println("Turning lights OFF.");
        turnLights(false);
      }
      break;

    case MOTION:
      Serial.println("Motion detected.");
      flashLed(statusLed, 1, 100);
      break;

    case MOTION_NO_LIGHT:
      flashLed(statusLed, 1, 100);
      Serial.println("Motion detected and it's dark.");
      if (!lightsState()) {
        Serial.println("Turning lights ON.");
        turnLights(true);
      }
      break;

    default:
      flashLed(statusLed, 3, 50);
      Serial.println("How did we get here?!");
      break;
  }

  delay(5000); // wait a bit
}

