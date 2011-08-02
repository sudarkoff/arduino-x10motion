/**
 * X10 Motion/Light Sensor
 * Sends the ON command if it's dark and motion detected; OFF otherwise.
 */

#include <x10.h>
#include <x10constants.h>

#include "Sensor.h"
#include "X10Lights.h"

const int statusLed = 13;  // status LED
MotionSensor motion;
//X10Lights lights;          // X10 Motion/Light sensor instance

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

void setup()
{
  Serial.begin(9600);

  // Status LED
  pinMode(statusLed, OUTPUT);

  // Initialize the sensors
  int PIRPin = 5;
  /*MotionSensor*/ motion = MotionSensor(PIRPin);
  Serial.println("Motion sensor initialized.");
/*

  int photoResPin = 0;
  LightSensor light = LightSensor(photoResPin);
  Serial.println("Light sensor initialized.");

  int zcPin = 9;
  int dataPin = 8;
  pinMode(zcPin, INPUT);
  pinMode(dataPin, OUTPUT);
  x10 house = x10(zcPin, dataPin);
  Serial.println("X10 controller initialized.");

  lights = X10Lights(
    motion,   // motion sensor
    light,    // light sensor
    house,    // X10 controller
    HOUSE_G,  // X10 house code
    UNIT_3,   // X10 unit code
    2,        // X10 command repeat count
    300000    // lights OFF delay
  );  
*/
}

void loop()
{
  int state = motion.read();
  if (state == HIGH) {
    flashLed(statusLed, 1, 100);
  }
/*
  state_t state = lights.state();
  Serial.print("Controller state: "); Serial.println(state);
  switch (state) {
    case NO_MOTION:
      Serial.println("No motion - turning lights OFF.");
      if (lights.lightsState()) {
        lights.turnLights(false);
      }
      break;

    case MOTION:
      Serial.println("Motion detected.");
      flashLed(statusLed, 1, 100);
      break;

    case MOTION_NO_LIGHT:
      flashLed(statusLed, 1, 100);
      Serial.println("Motion detected and it's dark - turning lights ON.");
      if (lights.lightsState()) {
        lights.turnLights(true);
      
      break;

    default:
      Serial.println("How did we get here?!");
      break;
  }

  delay(3000); // wait a second
*/
}

