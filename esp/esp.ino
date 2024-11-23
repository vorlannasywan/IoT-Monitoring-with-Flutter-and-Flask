#include <WiFi.h>
#include <HTTPClient.h>

// Ganti dengan kredensial Wi-Fi Anda
const char* ssid = "Femiliz";
const char* password = "tertibkost";

// URL API Flask
const char* serverName = "http://192.168.18.193:5000/data";

void setup() {
  Serial.begin(115200);

  // Koneksi ke Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

void loop() {
  // Data dummy
  String temperature = "29.5";
  String humidity = "60.3";
  String gas = "50.5";

  // Mempersiapkan data JSON dummy untuk dikirim
  String jsonData = "{\"temperature\":\"" + temperature + 
                    "\",\"humidity\":\"" + humidity + 
                    "\",\"gas\":\"" + gas + "\"}";

  // Mengirim data ke Flask server
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverName);
    http.addHeader("Content-Type", "application/json");

    // Kirim POST request dengan data JSON dummy
    int httpResponseCode = http.POST(jsonData);

    if (httpResponseCode > 0) {
      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);
    } else {
      Serial.print("Error on sending POST request: ");
      Serial.println(httpResponseCode);
    }

    http.end();  // Menutup koneksi HTTP
  }

  // Delay sebelum pembacaan berikutnya
  delay(60000);  // Tunggu 60 detik sebelum mengirimkan data lagi
}
