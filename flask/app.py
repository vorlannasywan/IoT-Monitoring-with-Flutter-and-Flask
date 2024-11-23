from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS untuk mengizinkan akses lintas asal
from pymongo import MongoClient
from datetime import datetime

# Inisialisasi aplikasi Flask
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # Mengaktifkan CORS untuk semua endpoint

# Koneksi ke MongoDB
client = MongoClient("mongodb://localhost:27017/")  # Pastikan MongoDB berjalan di localhost
db = client['tugas6iot']
collection = db['data']

# Endpoint untuk menerima data dari perangkat IoT
@app.route('/data', methods=['POST'])
def receive_data():
    if request.is_json:
        # Ambil data dari request JSON
        data = request.get_json()

        # Periksa apakah semua data yang diperlukan tersedia
        required_fields = ['temperature', 'humidity', 'gas']
        if all(field in data for field in required_fields):
            # Simpan data ke MongoDB
            reading = {
                'temperature': data['temperature'],
                'humidity': data['humidity'],
                'gas': data['gas'],
                'timestamp': datetime.now()
            }
            collection.insert_one(reading)

            return jsonify({"message": "Data received successfully", "status": "success"}), 200
        else:
            return jsonify({"message": "Invalid data received", "status": "error"}), 400
    else:
        return jsonify({"message": "Request must be JSON", "status": "error"}), 400

# Endpoint untuk mengambil data dari MongoDB
@app.route('/get_data', methods=['GET'])
def get_data():
    # Ambil semua data dari koleksi MongoDB, kecuali _id
    data = list(collection.find({}, {'_id': 0}))
    
    # Ubah format timestamp menjadi ISO 8601
    for record in data:
        record['timestamp'] = record['timestamp'].isoformat()

    if data:
        return jsonify(data), 200
    else:
        return jsonify({"message": "No data found", "status": "error"}), 404

# Jalankan aplikasi
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)  # Jalankan server Flask
