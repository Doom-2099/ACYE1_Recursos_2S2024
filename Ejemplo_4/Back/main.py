from flask import Flask, request, jsonify
from flask_cors import CORS
from RPi.GPIO import GPIO # type: ignore
from time import sleep
from dbConnection import getDatabase
import drivers # type: ignore

app = Flask(__name__)
cors = CORS(app, resources={r"/api/*": {"origins": "*"}})

display = drivers.Lcd()

@app.route('/api/', methods=['GET'])
def index():
    return jsonify({'message': 'Hello, World!'})

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    print(data)
    if username == 'admin' and password == 'admin':
        return jsonify({'message': 'Login success!'})
    return jsonify({'message': 'Login failed!'})

@app.route('/api/mensaje', methods=['POST'])
def mensajeLCD():
    data = request.get_json()
    mensaje = data.get('mensaje')
    print(data)
    display.lcd_display_string(mensaje, 1)
    return jsonify({'mensaje': mensaje})

@app.route('/api/open-door', methods=['POST'])
def openDoor():
    data = request.get_json()
    print(data)
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(18, GPIO.OUT)
    GPIO.output(18, GPIO.HIGH)
    # make connection with database
    db = getDatabase()
    collection = db['door']
    collection.insert_one({'fecha': '2021-07-14', 'status': 'open'})
    return jsonify({'message': 'Door opened!'})

@app.route('/api/close-door', methods=['POST'])
def closeDoor():
    data = request.get_json()
    print(data)
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(18, GPIO.OUT)
    GPIO.output(18, GPIO.LOW)
    # make connection with database
    db = getDatabase()
    collection = db['door']
    collection.insert_one({'fecha': '2021-07-14', 'status': 'close'})
    return jsonify({'message': 'Door closed!'})

@app.route('/api/read-temperatura', methods=['POST'])
def readTemperatura():
    data = request.get_json()
    print(data)
    # make read temperature to DHT11
    # make connection with database
    register = {
        'temperatura': 25,
        'fecha': '2021-07-14'
    }
    db = getDatabase()
    collection = db['temperatura']
    collection.insert_one(register)
    return jsonify({'message': 'Temperatura read!'})

if __name__ == '__main__':
    try:
        app.run(debug=True)
    except KeyboardInterrupt:
        print("Cleaning Up")
        display.lcd_clear()
    finally:
        GPIO.cleanup()