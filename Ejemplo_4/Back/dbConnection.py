from pymongo import MongoClient

def getDatabase():
    CONNECTION_STRING = "mongodb+srv://jorge_user_mongo:w7HeElEgYIHtjyQO@cluster0.ddcz3.mongodb.net/data_rasp"

    client = MongoClient(CONNECTION_STRING)

    return client['data_rasp']