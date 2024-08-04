import RPi.GPIO as GPIO # type: ignore
from time import sleep

FLAME_INPUT = 4
LED_INDICATOR = 17
BUZZER_INDICATOR = 18

GPIO.setmode(GPIO.BCM)

GPIO.setup(FLAME_INPUT, GPIO.IN)
GPIO.setup(LED_INDICATOR, GPIO.OUT)
GPIO.setup(BUZZER_INDICATOR, GPIO.OUT)

def main():
    try: 
        while True:
            if GPIO.input(FLAME_INPUT):
                print("Flame detected")
                GPIO.output(LED_INDICATOR, GPIO.HIGH)
                GPIO.output(BUZZER_INDICATOR, GPIO.HIGH)
            else:
                print("No flame detected")
                GPIO.output(LED_INDICATOR, GPIO.LOW)
                GPIO.output(BUZZER_INDICATOR, GPIO.LOW)

            sleep(0.1)
    except KeyboardInterrupt:
        GPIO.cleanup()

if __name__ == "__main__":
    main()