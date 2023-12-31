# INO Sketches

## Pre Configuration

Configure your Arduino IDE to work with the NodeMCU ESP8266. Follow the instructions in the [Arduino Core for ESP8266](https://www.instructables.com/Steps-to-Setup-Arduino-IDE-for-NODEMCU-ESP8266-WiF/)

Recommended Board Manager URL:
`http://arduino.esp8266.com/stable/package_esp8266com_index.json`

In case your host OS does not recognize the NodeMCU ESP8266, you may need to install the [CP210x USB to UART Bridge VCP Drivers](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers).

- [Windows Drivers](https://www.silabs.com/documents/public/software/CP210x_Universal_Windows_Driver.zip)
- [Mac OS X Drivers](https://www.silabs.com/documents/public/software/Mac_OSX_VCP_Driver.zip)

Ensure driver installation on MacOSX via terminal (only in case the driver is not loaded automatically):

```bash
# Load the driver
sudo kextload /Applications/CP210xVCPDriver.app/Contents/Library/SystemExtensions/com.silabs.cp210x.dext/

# List serial devices
ls /dev/cu.*
```

In case you need to do an initial firmware update, follow the instructions in the [Device Firmware Update via USB](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s2/api-guides/dfu.html#:~:text=The%20ESP32%2DS2%20chip%20needs,a%20moment%20and%20releasing%20GPIO0) documentation.

## Preparing the Sketches

Before you can use the sketches, you need to configure them with your AWS IoT credentials. To do so, open the sketch you want to use and edit the following lines:

```c
// AWS IoT Endpoint

#define AWS_IOT_ENDPOINT "xxxxxxxxxxxxxx-ats.iot.us-east-1.amazonaws.com"

// AWS IoT Thing Name

#define AWS_IOT_THING_NAME "xxxxxxxxxxxxxx"

// AWS IoT Root CA Certificate

const char AWS_CERT_CA[] PROGMEM = R"EOF(
-----BEGIN CERTIFICATE-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END CERTIFICATE-----
)EOF";

// AWS IoT Device Certificate

const char AWS_CERT_CRT[] PROGMEM = R"KEY(
-----BEGIN CERTIFICATE-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END CERTIFICATE-----
)KEY";

// AWS IoT Device Private Key

const char AWS_CERT_PRIVATE[] PROGMEM = R"KEY(
-----BEGIN RSA PRIVATE KEY-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END RSA PRIVATE KEY -----

)KEY";
```

## Dependencies

- [Arduino Core for ESP8266](https://github.com/esp8266/Arduino) (>= 2.7.4): is required for the sketches to work. You can install it from the Arduino IDE Board Manager.

- [ArduinoJson](https://arduinojson.org/?utm_source=meta&utm_medium=library.properties): is required for the sketches to work. You can install it from the Arduino IDE Library Manager.

- [PubSubClient](https://pubsubclient.knolleary.net/): is required for the sketches to work. You can install it from the Arduino IDE Library Manager.
