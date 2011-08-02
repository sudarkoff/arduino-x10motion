/**
 * X10 Motion/Light Sensor
 * Sends the ON command if it's dark and motion detected; OFF otherwise.
 */

#include <x10.h>
#include <x10constants.h>

int lightPin = 0;      // light sensor
int alarmPin = 5;      // motion sensor
int alarmState = HIGH;
int motionLed = 13;    // motion status LED
int lightsLed = 12;    // lights status LED

boolean lightsOn = false;
unsigned long curTime;
unsigned long lastMotion;
// delay turning the lights off by 5 minutes after motion stops
unsigned long delayBy = (unsigned long)300000;

// X10 Control unit variables
int zcPin = 9;         // 0-xing pin
int dataPin = 8;       // data pin
int repeat = 2;        // how many times to repeat each X10 command

// Declare and instance of an X10 control module
x10 myHouse = x10(zcPin, dataPin);

void blinkLed(int pin)
{
  digitalWrite(pin, HIGH);
  delay(50);
  digitalWrite(pin, LOW);
}

void turnLed(int pin, boolean state)
{
  digitalWrite(pin, (state == true)?HIGH:LOW);
}

void turnLights(boolean state)
{
  // turn the lights status LED ON/OFF
  turnLed(lightsLed, state);

  // turn the lights ON/OFF
  myHouse.write(HOUSE_G, UNIT_3, repeat);
  myHouse.write(HOUSE_G, (state == true)?ON:OFF, repeat);
}

void setup()
{
  Serial.begin(9600);

  // Initialize status LEDs pins
  pinMode(lightsLed,OUTPUT);
  pinMode(motionLed,OUTPUT);

  // Initialize PIR pin
  pinMode(alarmPin, INPUT);
  // wait for PIR to initialize
  delay(5000);
  Serial.println("Motion sensor initialized.");

  // Initialize X10 module and pins
  myHouse.write(HOUSE_G, ALL_UNITS_OFF, repeat);
  pinMode(zcPin,INPUT);
  pinMode(dataPin,OUTPUT);
  Serial.println("X10 initialized.");
}

void loop()
{
  int light = analogRead(lightPin);
  alarmState = digitalRead(alarmPin);

  // motion detected and it's dark...
  if ((alarmState == LOW) &&
       ((light < 100) || (lightsOn == true))) // if lights are ON, ignore light sensor
  {
    // blink LED to indicate that we detected motion
    blinkLed(motionLed);

    // if lights are currently OFF ...
    if (lightsOn == false) {
      // ... turn the lights ON
      lightsOn = true;
      turnLights(lightsOn);
      Serial.println("Lights ON.");
    }

    // store the time of last motion
    lastMotion = millis();
  }
  else { // no motion detected
    curTime = millis();

    // if lights are ON, and there was no motion for delayBy usec ...
    if ((lightsOn == true) && ((curTime - lastMotion) > delayBy)) {
      // ... turn the lights OFF
      lightsOn = false;
      turnLights(lightsOn);
      Serial.println("Lights OFF.");
    }
  }
}

