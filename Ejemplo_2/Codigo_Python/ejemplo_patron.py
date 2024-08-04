import RPi.GPIO as GPIO
from time import sleep

GPIO.setmode(GPIO.BOARD)

GPIO.setup(7, GPIO.IN)  # SECCION B
GPIO.setup(11, GPIO.IN) # CARACTER %
GPIO.setup(12, GPIO.IN) # GRUPO 1
GPIO.setup(13, GPIO.IN) # TECLA ENTER

def main():
    try:
        patron = 'B%1'
        patron_guardado = ''

        while True:
            if GPIO.input(7):
                print("Boton 1 presionado")
                patron_guardado += 'B'
                sleep(0.001)

            if GPIO.input(11):
                print("Boton 2 presionado")
                patron_guardado += '%'
                sleep(0.001)

            if GPIO.input(12):
                print("Boton 3 presionado")
                patron_guardado += '1'
                sleep(0.001)

            if GPIO.input(13):
                print("Boton 4 presionado")
                print(patron_guardado)
                if patron_guardado == patron:
                    print("Patron correcto")
                    break;
                else:
                    print("Patron incorrecto")

                # patron_guardado = ''
                sleep(0.001)

        print("Bienvenido")

    except KeyboardInterrupt:
        GPIO.cleanup()

if __name__ == '__main__':
    main()