#include <Wire.h>
#include <Servo.h>

Servo myservo;

#define LED1 2
#define LED2 3
#define LED3 4

bool LED1state = LOW;
bool LED2state = LOW;
bool LED3state = LOW;

void setup() {
  Wire.begin(0x20);              // Configura la dirección I2C del Arduino (0x08)
  Wire.onReceive(receiveEvent);  // Se llama cuando el maestro envía datos

  Serial.begin(9600);

  myservo.attach(6);
  myservo.write(0);

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);

  digitalWrite(LED1, LOW);
  digitalWrite(LED2, LOW);
  digitalWrite(LED3, LOW);
}

void loop() {
  delay(100);
}

void receiveEvent() {
  Wire.read();
  if (Wire.available()) {
    char c = Wire.read();  // Lee los datos enviados desde el maestro

    // Incluir codigo para controlar servomotor
    if (c == 'S') {
      int pos = Wire.read();
      for (int i = 0; i <= pos; i++) {
        myservo.write(i);
        delay(15);
      }

      myservo.write(0);

    } else if (c == 'L') {
      int pin = Wire.read();
      if (pin == LED1) {
        digitalWrite(LED1, !LED1state);
        LED1state = !LED1state;
      } else if (pin == LED2) {
        digitalWrite(LED2, !LED2state);
        LED2state = !LED2state;
      } else if (pin == LED3) {
        digitalWrite(LED3, !LED3state);
        LED3state = !LED3state;
      }
    } else if (c == 'M') {
      while (Wire.available()) {
        char c = Wire.read();
        Serial.print(c);
      }
      Serial.println();
    }
  }
}
