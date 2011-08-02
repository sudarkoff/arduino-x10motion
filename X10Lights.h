#ifndef __X10LIGHTS_H
#define __X10LIGHTS_H

#define LIGHT_THRESHOLD 150
enum state_t {NO_MOTION = 0, MOTION = 1, MOTION_NO_LIGHT = 2 };

class X10Lights {
public:
  X10Lights()
  : motion_(), light_(), house_(0, 0),
    repeat_(2), delayBy_(300000), lightsOn_(false)
  {}

  X10Lights(X10Lights const& rhs)
  : motion_(rhs.motion_), light_(rhs.light_), house_(rhs.house_),
    repeat_(rhs.repeat_), delayBy_(rhs.delayBy_), lightsOn_(rhs.lightsOn_)
  {}

  X10Lights(
    MotionSensor const& motionSensor,
    LightSensor const& lightSensor,
    x10 const& house,
    int houseCode,
    int unitCode,
    int repeat,
    unsigned long delayBy)
  : motion_(motionSensor), light_(lightSensor), house_(house),
    repeat_(repeat), delayBy_(delayBy), lightsOn_(false)
  {
    // Initialize X10 module and pins
    house_.write(houseCode_, ALL_UNITS_OFF, repeat);
  }

  void turnLights(boolean state)
  {
    lightsOn_ = state;

    // Send the ON/OFF command
    house_.write(houseCode_, unitCode_, repeat_);
    house_.write(houseCode_, (state == true)? ON: OFF, repeat_);
  }

  boolean lightsState()
  {
    return lightsOn_;
  }

  state_t state()
  {
    int motion = motion_.read();
    Serial.print("Motion: "); Serial.println(motion);
    int light = light_.read();
    Serial.print("Light: "); Serial.println(light);

    if ((motion == HIGH) && (light >= LIGHT_THRESHOLD))
    {
      return MOTION;
    }
    else if ((motion == HIGH) && (light < LIGHT_THRESHOLD)) // if lights are ON, ignore light sensor
    {
      return MOTION_NO_LIGHT;
    }
    else if (motion == LOW)
    {
      unsigned long curTime = millis();
      if ((millis() - motion_.lastMotionAt()) > delayBy_)
      {
        return NO_MOTION;
      }
    }
  }

private:
  MotionSensor motion_;
  LightSensor light_;
  x10 house_;
  int houseCode_;
  int unitCode_;
  int repeat_;
  unsigned long delayBy_;
  boolean lightsOn_;

};

#endif /* __X10LIGHTS_H */

