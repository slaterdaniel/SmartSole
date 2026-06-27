#include <Arduino.h>
#include <MPR121.h>
#include <Streaming.h>

#include "Constants.h"

MPR121 mpr121;
void setup()
{
  Serial.begin(constants::baud);

  mpr121.setupSingleDevice(*constants::wire_ptr,
    constants::device_address,
    constants::fast_mode);

  mpr121.setAllChannelsThresholds(constants::touch_threshold,
    constants::release_threshold);
  mpr121.setDebounce(constants::device_address,
    constants::touch_debounce,
    constants::release_debounce);
  mpr121.setBaselineTracking(constants::device_address,
    constants::baseline_tracking);
  mpr121.setChargeDischargeCurrent(constants::device_address,
    constants::charge_discharge_current);
  mpr121.setChargeDischargeTime(constants::device_address,
    constants::charge_discharge_time);
  mpr121.setFirstFilterIterations(constants::device_address,
    constants::first_filter_iterations);
  mpr121.setSecondFilterIterations(constants::device_address,
    constants::second_filter_iterations);
  mpr121.setSamplePeriod(constants::device_address,
    constants::sample_period);

  mpr121.startAllChannels(constants::proximity_mode);

  // int8_t baselines[constants::physical_channel_count];
  // for (uint8_t i=0; i<constants::physical_channel_count; i++) {
  //   if (!mpr121.communicating(constants::device_address)) {
  //     Serial << "mpr121 device not commmunicating!\n\n";
  //     while(1);
  //   }
  //   baselines[i] = mpr121.getChannelFilteredData(i);
  // }

  // find when the rep starts
  float pattern_start;    
  bool pattern_active = false;

  while (1) {
    // BLE.poll();
    if (1) {
        // listen for force distribution
        // BREAK when start sequence is found:
        // - front foot fully down (2sec)
        // - back foot on toe (2sec)

        // delay(constants::loop_delay);

        // String forces;
        int8_t forces_list[constants::physical_channel_count];
        for (uint8_t i=0; i < constants::physical_channel_count; i++) {
            int8_t difference = mpr121.getChannelBaselineData(i) - mpr121.getChannelFilteredData(i);
            // forces += String(difference) + ',';
            forces_list[i] = difference;
            Serial.print(forces_list[i]);
            Serial.print("  ");
        }
        Serial.println();      
        if ( // if pattern is recognized
            forces_list[0]  < -constants::touch_threshold && // heel off the ground
            forces_list[1]  < -constants::touch_threshold &&
            forces_list[2]  < -constants::touch_threshold &&
            forces_list[3]  < -constants::touch_threshold && 

            forces_list[8]  >  constants::touch_threshold && // toe on the ground
            forces_list[9]  >  constants::touch_threshold &&
            forces_list[10] >  constants::touch_threshold &&
            forces_list[11] >  constants::touch_threshold
        ) {
            if (!pattern_active) { // if pattern just started -> mark starting time
                pattern_active = true;
                pattern_start = millis();
            }
            else if (millis() - pattern_start >= 2000) { // 2000 = 2 seconds
                break; // if pattern found and time > 2sec -> start loop()
                // Serial.println("BREAKING");
            }
        }
        else { // if pattern is not recognized -> reset
            pattern_active = false;
        }
    }
  }  
}

void loop()
{
  delay(constants::loop_delay);
  if (!mpr121.communicating(constants::device_address))
  {
    Serial << "mpr121 device not commmunicating!\n\n";
    return;
  }

  int16_t touch_status = mpr121.getTouchStatus(constants::device_address);
  if (mpr121.overCurrentDetected(touch_status))
  {
    Serial << "Over current detected!\n\n";
    mpr121.startChannels(constants::physical_channel_count,
      constants::proximity_mode);
    return;
  }

  String line;
  for (uint8_t i=0; i < constants::physical_channel_count; i++) {
    int8_t difference = mpr121.getChannelBaselineData(i) - mpr121.getChannelFilteredData(i);
    line += String(difference) + ",";
  }
  Serial.println(line);
  // Serial.print(channel_filtered_data);
  // Serial.print("  ");
  // Serial.println(channel_baseline_data);

  // int8_t reading = channel_filtered_data - channel_baseline_data;
  // if (reading < -constants::deadzone || reading > constants::deadzone) {
    // Serial.println(-reading);
  // }
}
