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

bool test = 0;

void setup() {
    Serial.begin(9600);
    filter.begin(45);
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
    
    // find when the rep starts
    // float pattern_start = millis();
    // while (1) {
    //     BLE.poll();

    //     // testing
    //     // if (test) {
    //     //     force_charNotify.writeValue("1");
    //     //     test = false;
    //     // }
    //     // else {
    //     //     force_charNotify.writeValue("0");
    //     //     test = true;
    //     // }
    //     //

    //     if (started_char.value()) {
    //         // listen for force distribution
    //         // BREAK when start sequence is found:
    //         // - front foot fully down (2sec)
    //         // - back foot on toe (2sec)
            
    //         if (0) {
    //             if (millis() - pattern_start <= 2000) { // 2000 = 2 seconds
    //                 break; // if pattern found and time > 2sec -> start loop()
    //             }
    //             continue; // if pattern found but time < 2sec -> keep polling
    //         } 
    //         pattern_start = millis(); // if pattern not found -> reset time
    //     }
    // }
}

void loop() {
    BLE.poll();

    // accelerations
    float accelX, accelY, accelZ;
    IMU.readAcceleration(accelX, accelY, accelZ);

    String accels = String(accelX) + ',' + String(accelY) + ',' + String(accelZ);
    Serial.println(accels);

    // angle acceleration
    float angleVelX, angleVelY, angleVelZ;
    IMU.readGyroscope(angleVelX, angleVelY, angleVelZ);

    String angleAccels = String(angleVelX) + ',' + String(angleVelY) + ',' + String(angleVelZ);
    Serial.println(angleAccels);

    // angles
    float MagX, MagY, MagZ;
    IMU.readMagneticField(MagX, MagY, MagZ);

    filter.update(
        angleVelX, angleVelY, angleVelZ,
        accelX, accelY, accelZ,
        MagX, MagY, MagZ
    );

    float yaw = filter.getYaw();
    float roll = filter.getRoll();
    float pitch = filter.getPitch();

    String angles = String(yaw) + ',' + String(roll) + ',' + String(pitch);
    Serial.println(angles);

    // Force 



    //
    
    String final_vals = accels + ';' + angles + ';' + angleAccels;
    run_data_char.writeValue(final_vals);
    Serial.println();

    // TEST LOOP SPEED
    // count++;
    // if (millis() - start >= 1000) {
    //     Serial.println(count);
    //     count = 0;
    //     start = millis();
    // }
}

    // characteristic for read
    // {
    //     g_service.addCharacteristic(g_charRead);
    //     g_charRead.writeValue("NANO33 for read");
    //     g_charRead.setEventHandler(BLERead, [](BLEDevice central, BLECharacteristic characteristic)
    //     {
    //         Serial.print("Event: characteristic read, value='");
    //         Serial.print(g_charRead.value());
    //         Serial.println("'");
    //     });
    // }
    // characteristic for write
    // {
    //     g_service.addCharacteristic(g_charWrite);
    //     g_charWrite.setEventHandler(BLEWritten, [](BLEDevice central, BLECharacteristic characteristic)
    //     {
    //         Serial.print("Event: characteristic write, value='");
    //         Serial.print(g_charWrite.value());
    //         Serial.println("'");
    //     });
    // }
    // characteristic for indicate
    // {
    //     g_service.addCharacteristic(g_charIndicate);
    //     g_charIndicate.setEventHandler(BLESubscribed, [](BLEDevice central, BLECharacteristic characteristic)
    //     {
    //         Serial.println("Event: central subscribed to characteristic");
    //     });
    //     g_charIndicate.setEventHandler(BLEUnsubscribed, [](BLEDevice central, BLECharacteristic characteristic)
    //     {
    //         Serial.println("Event: central unsubscribed from characteristic");
    //     });
    // }
