#include <ArduinoBLE.h>
#include "Arduino_BMI270_BMM150.h"
#include <MadgwickAHRS.h>
// #include <Arduino.h>
#include <MPR121.h>
// #include <Streaming.h>
#include "Constants.h"

Madgwick filter;
MPR121 mpr121;

// UUIDs
// --------
#define DATA_SERVICE_UUID       "A7304340-C9C9-4FD4-B48D-052C4978B83B"
#define STARTED_CHAR_UUID       "C7304341-C9C9-4FD4-B48D-052C4978B83B"
#define RUN_DATA_UUID           "C7304342-C9C9-4FD4-B48D-052C4978B83B"

#define BATTERY_SERVICE_UUID          "180F"
#define BATTERY_PERCENTAGE_CHAR_UUID  "2A19"

// Services and Characteristics
// ----------------------------

// Data Service
static BLEService data_service(DATA_SERVICE_UUID);
static BLEByteCharacteristic started_char(STARTED_CHAR_UUID, BLEWrite);
static BLEStringCharacteristic run_data_char(RUN_DATA_UUID, BLENotify, 100);

// Battery Service
static BLEService battery_service(BATTERY_SERVICE_UUID);
static BLEFloatCharacteristic batteryLevel_charIndicate(BATTERY_PERCENTAGE_CHAR_UUID, BLEIndicate);

// Connection Bool
static bool centralConnected = false;

static uint32_t count = 0;
static uint32_t start = millis();

float accelX, accelY, accelZ, angleVelX, angleVelY, angleVelZ, magX, magY, magZ;
String current_vals;

void setup() {
    Serial.begin(constants::baud);
    filter.begin(30);
    if (!BLE.begin()) {
        Serial.println("BLE.begin() failed");
        while (1);
    }

    if (!IMU.begin()) {
        Serial.println("IMU.begin() failed");
        while (1);
    }

    BLE.setLocalName("SmartSole Right");

    // Data Service
    data_service.addCharacteristic(started_char);
    data_service.addCharacteristic(run_data_char);
    BLE.addService(data_service);

    // Battery Service
    battery_service.addCharacteristic(batteryLevel_charIndicate);
    BLE.addService(battery_service);

    // Connection to Central
    BLE.setEventHandler(BLEConnected, [](BLEDevice central)
    {
        centralConnected = true;
        Serial.println("Event: central connected");
    });

    // Disconnection from Central
    BLE.setEventHandler(BLEDisconnected, [](BLEDevice central)
    {
        centralConnected = false;
        Serial.println("Event: central disconnected");
    });

    BLE.advertise();
    Serial.println("BLE setup done, advertising...");

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

    Serial.println("MPR121 setup done.");
    
    // find when the rep starts
    float pattern_start;    
    bool pattern_active = false;

    while (1) {
        BLE.poll();
        if (centralConnected) {
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

void loop() {
    BLE.poll();

    // accelerations
    IMU.readAcceleration(accelX, accelY, accelZ);

    String accels = String(accelX) + ',' + String(accelY) + ',' + String(accelZ);

    // angle acceleration
    IMU.readGyroscope(angleVelX, angleVelY, angleVelZ);

    String angleVelos = String(angleVelX) + ',' + String(angleVelY) + ',' + String(angleVelZ);

    // angles
    // IMU.readMagneticField(magX, magY, magZ);

    filter.updateIMU(
        angleVelX, angleVelY, angleVelZ,
        accelX, accelY, accelZ//,
        // magX, magY, magZ
    );

    String angles = String(filter.getQ0()) + ',' + String(filter.getQ1()) + ',' + String(filter.getQ2()) + ',' + String(filter.getQ3());

    // Force 
    String forces;
    for (uint8_t i=0; i < constants::physical_channel_count; i++) {
        int8_t difference = mpr121.getChannelBaselineData(i) - mpr121.getChannelFilteredData(i);
        forces += String(difference) + ",";
    }
    Serial.println(forces);
    
    
    current_vals = accels + ';' + angles + ';' + angleVelos + ';' + forces;
    run_data_char.writeValue(current_vals);

    // TEST LOOP SPEED
    count++;
    if (millis() - start >= 1000) {
        Serial.println(count);
        count = 0;
        start = millis();
    }
}
