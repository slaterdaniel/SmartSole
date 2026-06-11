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
    float angleVelX, angleVelY, angleVelZ;
    IMU.readGyroscope(angleVelX, angleVelY, angleVelZ);
    
    String angleAccels = String(angleVelX) + ',' + String(angleVelY) + ',' + String(angleVelZ);

    Serial.println(angleAccels);
}