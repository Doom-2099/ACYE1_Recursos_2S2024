import RPi.GPIO as GPIO # type: ignore
from time import sleep

GPIO.setmode(GPIO.BOARD)

#pins para leds
GPIO.setup(29, GPIO.OUT)
GPIO.setup(31, GPIO.OUT)
GPIO.setup(32, GPIO.OUT)
GPIO.setup(33, GPIO.OUT)
GPIO.setup(35, GPIO.OUT)
GPIO.setup(36, GPIO.OUT)
GPIO.setup(37, GPIO.OUT)
GPIO.setup(38, GPIO.OUT)


#pins para botones
GPIO.setup(27, GPIO.IN)
GPIO.setup(28, GPIO.IN)
GPIO.setup(40, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

# pins para motor
GPIO.setup(16, GPIO.OUT)
GPIO.setup(18, GPIO.OUT)

def main():
    leds = [29, 31, 32, 33, 35, 36, 37, 38]
    index = 0;
    flag = False
    GPIO.output(leds[index], GPIO.HIGH)

    while not GPIO.input(40):
        if GPIO.input(27):
            print("Button 27 was pushed!")
            GPIO.output(leds[index], GPIO.LOW)

            if not flag:
                index += 1
            else:
                index -= 1

            if index == len(leds):
                flag = True
                index -= 1
            elif index == 0:
                flag = False

            GPIO.output(leds[index], GPIO.HIGH)
            sleep(0.5)

        if GPIO.input(28):
            for led in leds:
                GPIO.output(led, GPIO.LOW)

            print("Button 28 was pushed!")

            GPIO.output(16, GPIO.HIGH)
            GPIO.output(18, GPIO.LOW)
            sleep(2)
            GPIO.output(16, GPIO.LOW)
            GPIO.output(18, GPIO.HIGH)
            sleep(2)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
    finally:
        GPIO.cleanup()
        print("GPIO cleanup done!")