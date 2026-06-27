#include <ArduinoBLE.h>
#include "Arduino_BMI270_BMM150.h"
#include <MadgwickAHRS.h>
#include <string>

Madgwick filter;

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
    Serial.begin(115200);
    filter.begin(55);
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
    
    current_vals = accels + ';' + angles + ';' + angleVelos;

    run_data_char.writeValue(current_vals);

    // TEST LOOP SPEED
    // count++;
    // if (millis() - start >= 1000) {
    //     Serial.println(count);
    //     count = 0;
    //     start = millis();
    // }
}
