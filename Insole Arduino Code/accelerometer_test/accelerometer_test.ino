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

    float angleX, angleY, angleZ;
    angleX = atan2(accelX, sqrt((accelY * accelY) + (accelZ * accelZ))) * 180 / PI;
    angleY = atan2(accelY, sqrt((accelX * accelX) + (accelZ * accelZ))) * 180 / PI;
    angleZ = atan2(accelZ, sqrt((accelX * accelX) + (accelY * accelY))) * 180 / PI;

    String accels = String(accelX) + ',' + String(accelY) + ',' + String(accelZ);
    String angles = String(angleX) + ',' + String(angleY) + ',' + String(angleZ);

    Serial.println(accels);
    Serial.println(angles);
}