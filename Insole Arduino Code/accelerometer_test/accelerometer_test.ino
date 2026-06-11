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

    String str_accelX = String(accelX);
    String str_accelY = String(accelY);
    String str_accelZ = String(accelZ);

    String accels = str_accelX + ',' + str_accelY + ',' + str_accelZ;

    Serial.println(accels);
}