#ifndef __SENSOR_H
#define __SENSOR_H

class Sensor {
public:
  Sensor() {}
  Sensor(int pin) : sensorPin_(pin) {}

protected:
  int sensorPin_;
};

class MotionSensor : public Sensor {
public:
  MotionSensor() {}
  MotionSensor(int pin)
  {
    Serial.println("Initializing PIR sensor.");
    // Initialize PIR pin
    pinMode(sensorPin_, INPUT);
    // wait for PIR to initialize
    delay(5000);
  }

  int read()
  {
    int motion = digitalRead(sensorPin_);
    if (motion == LOW) {
      lastMotionAt_ = millis();
    }
    return (motion == LOW? HIGH: LOW);
  }

  unsigned long lastMotionAt() const
  {
    return lastMotionAt_;
  }

private:
  unsigned long lastMotionAt_;
};

class LightSensor : public Sensor {
public:
  LightSensor() {}
  LightSensor(int const& pin) {}

  int read()
  {
    lastLight_ = analogRead(sensorPin_);
    return lastLight_;
  }

private:
  int lastLight_;
};

#endif /* __SENSOR_H */

