import RPi.GPIO as GPIO
import  random
from time import sleep

leds = [5, 6, 12, 13, 16, 19, 20, 26] # Pines En Modo BCM
# leds = [29, 31, 32, 33, 36, 35, 38, 37] # Pines En Modo BOARD

# Mapeo De Pines Para La LCD
LCD_RS = 18
LCD_E  = 27
LCD_D4 = 22
LCD_D5 = 23
LCD_D6 = 24
LCD_D7 = 25


LCD_WIDTH = 16  # Caracteres Por Linea 
LCD_CHR = True	# Modo "Caracter"
LCD_CMD = False # Modo "Comando"

LCD_LINE_1 = 0x80 # LCD RAM para la primera linea 80 - 8F
LCD_LINE_2 = 0xC0 # LCD RAM para la segunda linea C0 - CF

# Temporizadores
E_PULSE = 0.0005
E_DELAY = 0.0005

GPIO.setmode(GPIO.BCM)
# GPIO.setmode(GPIO.BOARD)

def init_leds():
    # Control de leds
    for led in leds:
        GPIO.setup(led, GPIO.OUT)

    # Control del motor
    GPIO.setup(4, GPIO.OUT)
    GPIO.setup(17, GPIO.OUT)

    # Control de secuencia de leds
    GPIO.setup(21, GPIO.IN)

    # Control LCD
    GPIO.setup(LCD_E, GPIO.OUT)  # E
    GPIO.setup(LCD_RS, GPIO.OUT) # RS
    GPIO.setup(LCD_D4, GPIO.OUT) # DB4
    GPIO.setup(LCD_D5, GPIO.OUT) # DB5
    GPIO.setup(LCD_D6, GPIO.OUT) # DB6
    GPIO.setup(LCD_D7, GPIO.OUT) # DB7    

def lcd_init():
	# Initialise display
	lcd_byte(0x33,LCD_CMD)
	lcd_byte(0x32,LCD_CMD)
	lcd_byte(0x06,LCD_CMD)
	lcd_byte(0x0C,LCD_CMD)
	lcd_byte(0x28,LCD_CMD)
	lcd_byte(0x01,LCD_CMD)
	sleep(E_DELAY)

def lcd_byte(bits, mode):
	GPIO.output(LCD_RS, mode)

	# Bits Altos
	GPIO.output(LCD_D4, False)
	GPIO.output(LCD_D5, False)
	GPIO.output(LCD_D6, False)
	GPIO.output(LCD_D7, False)
	if bits&0x10==0x10:
		GPIO.output(LCD_D4, True)
	if bits&0x20==0x20:
		GPIO.output(LCD_D5, True)
	if bits&0x40==0x40:
		GPIO.output(LCD_D6, True)
	if bits&0x80==0x80:
		GPIO.output(LCD_D7, True)

	# Toggle 'Enable' pin
	lcd_toggle_enable()

	# Bits Bajos
	GPIO.output(LCD_D4, False)
	GPIO.output(LCD_D5, False)
	GPIO.output(LCD_D6, False)
	GPIO.output(LCD_D7, False)
	if bits&0x01==0x01:
		GPIO.output(LCD_D4, True)
	if bits&0x02==0x02:
		GPIO.output(LCD_D5, True)
	if bits&0x04==0x04:
		GPIO.output(LCD_D6, True)
	if bits&0x08==0x08:
		GPIO.output(LCD_D7, True)

	# Toggle 'Enable' pin
	lcd_toggle_enable()

def lcd_toggle_enable():
	# Toggle enable
	sleep(E_DELAY)
	GPIO.output(LCD_E, True)
	sleep(E_PULSE)
	GPIO.output(LCD_E, False)
	sleep(E_DELAY)

def lcd_string(message,line):
	# Enviar String A La Pantalla
	message = message.ljust(LCD_WIDTH," ")

	lcd_byte(line, LCD_CMD)

	for i in range(LCD_WIDTH):
		lcd_byte(ord(message[i]),LCD_CHR)

def main():
	# Inicializar componentes
    init_leds()
    lcd_init()
    
	# Mensaje De Bienvenida
    lcd_string("Hello World!",LCD_LINE_1)
    sleep(0.5)
    
	# Secuencia aleatoria de leds
    while True:
        index = random.randint(0, 7)
        
        GPIO.output(leds[index], GPIO.HIGH)
        
        sleep(0.02)
        
        GPIO.output(leds[index], GPIO.LOW)
        
        if GPIO.input(21):
            break
    
	# Iniciar movimiento del motor en un sentido
    GPIO.output(4, GPIO.HIGH)
    GPIO.output(17, GPIO.LOW)
    sleep(0.5)

	# Iniciar movimiento del motor en sentido contrario
    GPIO.output(4, GPIO.LOW)
    GPIO.output(17, GPIO.HIGH)
    sleep(0.5)

	# Limpiar LCD
    lcd_byte(0x01, LCD_CMD)

	# Mensaje de despedida
    lcd_string("Goodbye!", LCD_LINE_1)
    lcd_string("Clase 1", LCD_LINE_2)

	# Limpiar GPIO
    GPIO.cleanup()
