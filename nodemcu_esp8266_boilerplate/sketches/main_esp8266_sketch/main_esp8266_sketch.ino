#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <time.h>
#include "secrets.h"

#include <cstdlib>
#include <ctime>

// #include "DHT.h"

/* WIFI Config */
WiFiClientSecure net;

/* Certificate configurations */
BearSSL::X509List cert(cacert);
BearSSL::X509List client_crt(client_cert);
BearSSL::PrivateKey key(private_key);


/* PubSub configurations */
PubSubClient client(net);

time_t now;
time_t nowish = 1510592825;

/* Intervals/Sensors Config */
float h;
float t;
unsigned long lastMillis = 0;
unsigned long previousMillis = 0;

/* DHT Config */

// #define DHTPIN 4
// #define DHTTYPE DHT11   
// DHT dht(DHTPIN, DHTTYPE);

// Interval to publish sensor readings
const long interval = 5000;


void setup_wifi(){
  delay(10);

  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

/*  Simple Network Time Protocol (SNTP).
    ------------------------------------

    This sketch uses the ESP8266WiFi library to connect 
    to a router and sync time from NTP. */
void NTPConnect(void)
{
  Serial.print("Setting time using SNTP");
  configTime(TIME_ZONE * 3600, 0 * 3600, "pool.ntp.org", "time.nist.gov");
  now = time(nullptr);
  while (now < nowish)
  {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
  }
  Serial.println("done!");
  struct tm timeinfo;
  gmtime_r(&now, &timeinfo);
  Serial.print("Current time: ");
  Serial.print(asctime(&timeinfo));
}

/*  MQTT client setup function.
    ---------------------------

    Define the callback function to receive MQTT broker
    messages. */
void messageReceived(char *topic, byte *payload, unsigned int length)
{
  Serial.print("Received [");
  Serial.print(topic);
  Serial.print("]: ");
  for (int i = 0; i < length; i++)
  {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}

/*  MQTT client setup function.
    ---------------------------

    This function connects the ESP8266 to the AWS Cloud 
    and stablishes connection with the MQTT broker 
    and sets the callback function. */
void connectAWS()
{
  delay(3000);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
 
  
  Serial.println(String("Attempting to connect to SSID: ") + String(WIFI_SSID));
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(1000);
  }
 
  NTPConnect();
 
  net.setTrustAnchors(&cert);
  net.setClientRSACert(&client_crt, &key);
 
  client.setServer(MQTT_HOST, 8883);
  client.setCallback(messageReceived);
 
 
  Serial.println("Connecting to AWS IOT");
 
  while (!client.connect(THINGNAME))
  {
    Serial.print(".");
    delay(1000);
  }
 
  if (!client.connected()) {
    Serial.println("AWS IoT Timeout!");
    return;
  }
  // Subscribe to a topic
  client.subscribe(AWS_IOT_SUBSCRIBE_TOPIC);
 
  Serial.println("AWS IoT Connected!");
}

/* MQTT client publish function.
    -----------------------------

    This function publishes a message to the MQTT broker. 
*/
void publishMessage()
{
  StaticJsonDocument<200> doc;
  doc["time"] = millis();
  doc["humidity"] = h;
  doc["temperature"] = t;
  char jsonBuffer[512];
  serializeJson(doc, jsonBuffer); // print to client
 
  client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer);
}

void setup()
{
  Serial.begin(115200);
  
  // Serial.begin(9600);
  connectAWS();

  // Uncomment this once you have the DHT11 sensor hooked up
  // dht.begin();

  // Comment this once you have the DHT11 sensor hooked up
  // srand(time(NULL));

}

void loop() {
  // put your main code here, to run repeatedly:

  // Uncomment this once you have the DHT11 sensor hooked up
  // h = dht.readHumidity();
  // t = dht.readTemperature();


  // Comment this once you have the DHT11 sensor hooked up
  h = 1.0 + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / 99.0));
  t = 1.0 + static_cast<float>(rand()) / (static_cast<float>(RAND_MAX / 31.0));
 
  // Uncomment this once you have the DHT11 sensor hooked up
  // if (isnan(h) || isnan(t) )  // Check if any reads failed and exit early (to try again).
  // {
  //   Serial.println(F("Failed to read from DHT sensor!"));
  //   return;
  // }
 
  Serial.print(F("Humidity: "));
  Serial.print(h);
  Serial.print(F("%  Temperature: "));
  Serial.print(t);
  Serial.println(F("°C "));
  delay(2000);
 
  now = time(nullptr);
 
  if (!client.connected())
  {
    connectAWS();
  }
  else
  {
    client.loop();
    if (millis() - lastMillis > 5000)
    {
      lastMillis = millis();
      Serial.println("Atttempting to send event");
      publishMessage();
    }
  }
}