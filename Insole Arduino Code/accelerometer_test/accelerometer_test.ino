#include "Arduino_BMI270_BMM150.h"
#include <string>

void setup()
{
    Serial.begin(9600);

    if (!IMU.begin()) {
        Serial.println("IMU.begin() failed");
        while (1);
    }
}

void loop()
{
    float accelX, accelY, accelZ;
    IMU.readAcceleration(accelX, accelY, accelZ);

    String accels = String(str_accelX) + ',' + String(str_accelY) + ',' + String(str_accelZ);

    Serial.println(accels);
}