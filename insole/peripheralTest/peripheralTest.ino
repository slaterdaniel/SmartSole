/*
 * BLEProofPeripheral.cpp
 *
 * Created by Alexander Lavrushko on 25/06/2022.
 *
 * @brief BLEProof Peripheral Nano33
 * Bluetooth Low Energy Peripheral (also called Slave, Server) demo application for Arduino Nano 33 IoT
 * 1. Advertises one service with 3 characteristics:
 *    - characteristic which supports read (BLE Central can only read)
 *    - characteristic which supports write (BLE Central can only write, with response)
 *    - characteristic which supports indication (BLE Central can only subscribe and listen for indications)
 * 2. Provides command line interface for changing values of characteristics:
 *    - use Arduino Serial Monitor with 9600 baud, and option 'Newline' or 'Carriage return' or 'Both'
 */

#include <ArduinoBLE.h>
#include <string>

// --------
// Constants
// --------
#define DATA_SERVICE_UUID         "A7304340-C9C9-4FD4-B48D-052C4978B83B"
#define STARTED_CHAR_UUID         "C7304340-C9C9-4FD4-B48D-052C4978B83B"
#define ANGLES_CHAR_UUID          "C7304341-C9C9-4FD4-B48D-052C4978B83B"
#define ACCELERATION_CHAR_UUID    "2C1D"
#define FORCE_CHAR_UUID           "2C07"

#define BATTERY_SERVICE_UUID          "180F"
#define BATTERY_PERCENTAGE_CHAR_UUID  "2A19"

// --------
// Global variables
// --------

// Data Service
static BLEService data_service(DATA_SERVICE_UUID);
static BLEByteCharacteristic started_char(STARTED_CHAR_UUID, BLERead | BLENotify);

static BLEStringCharacteristic angles_charNotify(ANGLES_CHAR_UUID, BLENotify, 11);
static BLEStringCharacteristic acceleration_charNotify(ACCELERATION_CHAR_UUID, BLENotify, 11);
static BLEStringCharacteristic force_charNotify(FORCE_CHAR_UUID, BLENotify, 100);

// Battery Service
static BLEService battery_service(BATTERY_SERVICE_UUID);
static BLEFloatCharacteristic batteryLevel_charIndicate(FORCE_CHAR_UUID, BLEIndicate);

// Connection Bool
static bool centralConnected = false;

// --------
// Application lifecycle: setup & loop
// --------
void setup()
{
    pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, LOW);

    Serial.begin(9600);
    if (!BLE.begin())
    {
        stopWithError("BLE.begin() failed");
    }

    BLE.setLocalName("SmartSole Right");

    BLE.setAdvertisedService(data_service);
    data_service.addCharacteristic(started_char); // 0 = idle; 1 = watching for rep, 2 = rep started, 3 = rep ended
    data_service.addCharacteristic(angles_charNotify)
    data_service.addCharacteristic(acceleration_charNotify)
    data_service.addCharacteristic(force_charNotify)

    BLE.setAdvertisedService(battery_service);
    battery_service.addCharacteristic(batteryLevel_charIndicate)

    // Connection to Central
    BLE.setEventHandler(BLEConnected, [](BLEDevice central)
    {
        g_isCentralConnected = true;
        Serial.println("Event: central connected");
    });

    // Disconnection from Central
    BLE.setEventHandler(BLEDisconnected, [](BLEDevice central)
    {
        g_isCentralConnected = false;
        Serial.println("Event: central disconnected");
    });

    BLE.advertise();
    Serial.println("BLE setup done, advertising...");
}

void loop()
{
    BLE.poll();
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