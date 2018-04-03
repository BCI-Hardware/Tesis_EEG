/*********************************************************
                    TESIS DE GRADO
                       EEG v1.0
            Instituto de Ingenieria Biomedica
    Facultad de Ingenieria, Universidad de Buenos Aires

        Brian Daniel Santillan, Florencia Grosso.
           Tutors: Sergio Lew. Ariel Burman.

  Code description:
  This code controls the IC ADS1299 through an Arduino NANO
*********************************************************/

// Libraries
#include <SPI.h>

// Clock
#define tCLK 0.0005 //clock de 2MHz, 500ns

// Commands
// System commands
#define WAKEUP 0x02
#define STANDBY 0x04
#define RESET 0x06
#define START 0x08
#define STOP 0x0A

// Data Read Commands
#define RRDATAC 0x10
#define SSDATAC 0x11
#define RRDATA 0x12

// Register Read Commands
#define RREG 0x20
#define WREG 0x40

// Registers
#define ID 0x00
#define CONFIG1 0x01
#define CONFIG2 0x02
#define CONFIG3 0x03
//#define LOFF 0x04
#define CH1SET 0x05
#define CH2SET 0x06
#define CH3SET 0x07
#define CH4SET 0x08
#define CH5SET 0x09
#define CH6SET 0x0A
#define CH7SET 0x0B
#define CH8SET 0x0C
//#define BIAS_SENSP 0x0D
//#define BIAS_SENSN 0x0E
//#define LOFF_SENSP 0x0F
//#define LOFF_SENSN 0x10
//#define LOFF_FLIP 0x11
//#define LOFF_STATP 0x12
//#define LOFF_STATN 0x13
//#define GPIO 0x14
//#define MISC1 0x15
//#define MISC2 0x16
#define CONFIG4 0x17

// Pins for the arduino board
const int PIN_DRDY = 2;
const int PIN_START = 5;
const int PIN_SS = 10;
const int PIN_MOSI = 11; // DIN
const int PIN_MISO = 12; // DOUT
const int PIN_SCK = 13;
const int PIN_RESET = 4;

// Prototypes of used functions
void wake_up();
void send_command(uint8_t command);
void send_command_and_wait(uint8_t command, float time_to_wait);
byte fRREG(byte address);
void fWREG(byte address, byte data);
void getDeviceID();
void reset_communication(void);
byte read_spi( void) ;

// Global variables
boolean power_up = true;
boolean verbose = false;
byte deviceID = 0;

byte a = 0;
byte b = 0;
byte c = 0;

unsigned long aaa = 0;
unsigned long bbb = 0;
unsigned long ccc = 0;

long aux_ch = 0;

void setup() {
  /* Initialization routine for SPI bus */

  // Initalize communication with computer.
  // Open serial port (USB), max rate 115bps
  Serial.begin(115200, SERIAL_8N1);
  // Wait until data transmission through serial port is completed (in case there's a transmission going on)
  Serial.flush();
  // Serial.println("ConexiÃ³n con PC establecida");
  delay(2000);

  // Set SPI communication. 2 MHz clock, MSB first, Mode 0.
  // MODE 0 = Output Edge: Falling - Data Capture: Rising (pag. 38)
  // MODE 1 = Output Edge: Rising - Data Capture: Falling (pag. 38)
  //  SPI.setClockDivider(SPI_CLOCK_DIV16);
  //  SPI.setDataMode(SPI_MODE1);
  //  SPI.setBitOrder(MSBFIRST);

  SPI.beginTransaction(SPISettings(2000000, MSBFIRST, SPI_MODE1));
  // Initialize SPI.
  SPI.begin();

  // Set Pin modes
  pinMode(PIN_START, OUTPUT);
  pinMode(PIN_DRDY, INPUT);
  pinMode(PIN_SS, OUTPUT);
  pinMode(PIN_MOSI, OUTPUT);
  pinMode(PIN_MISO, INPUT);
  pinMode(PIN_SCK, OUTPUT);

  //reset_communication;

  // Set pin initial value
  digitalWrite(PIN_START, LOW);
  digitalWrite(PIN_SS, HIGH);

  /* Follow initial flow at power-up (page 62) */

  // Delay>tPOR in ms (make sure thatVCAP1 1.1v = ok)
  delay(300);
  // Reset the device
  send_command_and_wait(RESET, 18 * tCLK); // (Datasheet, p.35)
  delay(500);
  send_command_and_wait(SSDATAC, 4 * tCLK);
  delay(300);

  /* TEST 1 */
  // Read ADS1299 ID to check that it receives data and there's communication
  while (deviceID == 0) {
    getDeviceID();
  }
  // Switch internal reference on (p.48)
  fWREG(CONFIG3, 0xE0); // 0x60 -> enable internal ref, 0xE0 -> power down internal ref

  // Define the Data rate (p.46)
  // [it is set at minimum always, then changed by the desired value]
  fWREG(CONFIG1, 0x96); // 16kSPS -> 0x90, 8kSPS -> 0x91, ..., 250SPS -> 0x96

  // Define test signals (p.47)
  fWREG(CONFIG2, 0xD0); // external test signal -> 0xC0, internal test signal -> 0xD0
  // 0 always ; 0  1*-(VREFP-VREFN)/2400) 1 2*-(VREFP-VREFN)/2400) - 00 fclk/2^21  01 fclk/2^20  11 at dc

  /* TEST 2 */
  // Read the written registers and print data
  if (verbose) {
    Serial.println("Check config regs:");
    Serial.print("CONFIG1: ");
    Serial.println(fRREG(CONFIG1), HEX);
    Serial.print("CONFIG2: ");
    Serial.println(fRREG(CONFIG2), HEX);
    Serial.print("CONFIG3: ");
    Serial.println(fRREG(CONFIG3), HEX);
  }

  // Set all channels (p.50)
  //0x01 normal operation, unity gain & input shorted
  //0x81 power-down, unity gain & input shorted
  //0x05 normal operation, unity gain & test signal
  fWREG(CH1SET, 0x05);
  fWREG(CH2SET, 0x81);
  fWREG(CH3SET, 0x81);
  fWREG(CH4SET, 0x81);
  fWREG(CH5SET, 0x81);
  fWREG(CH6SET, 0x81);
  fWREG(CH7SET, 0x81);
  fWREG(CH8SET, 0x81);

  //while (digitalRead(PIN_DRDY) == HIGH);

  /* TEST 3 */
  // Read written channels
  // read the written registers and print data
  if (verbose) {
    Serial.println("Check channels:");
    Serial.print("CH1SET: ");
    Serial.println(fRREG(CH1SET), HEX);
    Serial.print("CH4SET: ");
    Serial.println(fRREG(CH4SET), HEX);// we may have trouble here since it has to print a binary, if not use print(xxx, BIN)
  }

  digitalWrite(PIN_START, LOW);
  delay(150);
  send_command(START);
  delay(150);
  send_command(RRDATAC);
}

// Operation loop for the Arduino.
void loop() {

  // Wait until there is data available
  while (digitalRead(PIN_DRDY) == HIGH);
  if (verbose) {
    Serial.print("There is Data Ready ");
  }
  delay(1);

  // Discard header first
  digitalWrite(SS, LOW);
  delayMicroseconds(1);
  SPI.transfer(0x00);
  SPI.transfer(0x00);
  SPI.transfer(0x00);

  a = SPI.transfer(0x00);
  //Serial.println(a);
  b = SPI.transfer(0x00);
//  Serial.println(b);
  c = SPI.transfer(0x00);
//  Serial.println(c);

  if (a>0x7F) {
    aaa=((unsigned long)a)<<16;
    bbb=((unsigned long)b)<<8;
    ccc=(unsigned long)c;
    aux_ch=0xFF000000|aaa|bbb|ccc;  
  } else {
    aaa=(unsigned long)a<<16;
    bbb=(unsigned long)b<<8;
    ccc=(unsigned long)c;
    aux_ch=aaa|bbb|ccc;
  }
  Serial.println((float)aux_ch*4500/(pow(2, 23) - 1), 7);

  // Serial.println(aux_ch);


  //  // Read 3 bytes per ACTIVE channel
  //  byte read_out  = SPI.transfer(0x00);
  //  Serial.println(read_out, DEC);
  //  read_out  = SPI.transfer(0x00);
  //  Serial.println(read_out, DEC);
  //  read_out  = SPI.transfer(0x00);
  //  Serial.println(read_out, DEC);

  digitalWrite(SS, HIGH);
  delayMicroseconds(1);

  //resultado=256.0*256.0*read_out2+256.0*read_out1+read_out0;
  //Serial.println(resultado);
}

//void update_channel_data(){
//  byte inByte;
//
//  int nchan = 1;
//  digitalWrite(SS, LOW);        //  open SPI
//
//  // READ CHANNEL DATA FROM FIRST ADS IN DAISY LINE
//  for(int i=0; i<3; i++){     //  read 3 byte status register from ADS 1 (1100+LOFF_STATP+LOFF_STATN+GPIO[7:4])
//    inByte = transfer(0x00);
//    stat_1 = (stat_1<<8) | inByte;
//  }
//
//  for(int i = 0; i<nchan; i++){
//    for(int j=0; j<3; j++){   //  read 24 bits of channel data from 1st ADS in 8 3 byte chunks
//      inByte = SPI.transfer(0x00);
//      Serial.println(inByte, HEX);
//    }
//  }
//
//}

/* SYSTEM COMMANDS */

// TODO: This should be sent as a command too. Though we must figure out how to handle
// the intermediate delay.
// Wake-up from standby mode
void wake_up() {
  // Set SS low to communicate with device.
  digitalWrite(SS, LOW);
  SPI.transfer(WAKEUP);
  // Must wait at least 4 tCLK cycles (Datasheet, pg. 40)
  delay(4 * tCLK);
  // SS high to end communication
  digitalWrite(SS, HIGH);
}

// Send a command to the ADS 1299. Requires no delay.
void send_command(uint8_t command) {
  digitalWrite(SS, LOW);
  delay(1);
  SPI.transfer(command);
  delay(1);
  digitalWrite(SS, HIGH);
}

byte read_spi( void) {
  byte pepe = 0;
  digitalWrite(SS, LOW);
  pepe = SPI.transfer(0x00);
  digitalWrite(SS, HIGH);
  return pepe;
}

// Send a command to the ADS 1299. Issues a delay afterwards
void send_command_and_wait(uint8_t command, float time_to_wait) {
  digitalWrite(SS, LOW);
  SPI.transfer(command);
  digitalWrite(SS, HIGH);
  delay(time_to_wait);
}

/* REGISTER READ/WRITE COMMANDS */

// Read from register. Shouldn't it be returning the byte read?
// @param address: the starting register address.
// @param numberRegMinusOne: number of register to read - 1. (reads only 1 for now)
byte fRREG(byte address) {
  // RREG expects 001rrrrr where rrrrr = _address
  byte op_code = RREG + address;
  digitalWrite(SS, LOW);
  //send_command_and_wait(SSDATAC, 4*tCLK);
  SPI.transfer(op_code);
  SPI.transfer(0x00);
  byte data = SPI.transfer(0x00);
  // Close SPI
  digitalWrite(SS, HIGH);
  delay(1);
  return data;
}

// Write to register.
// @param address: the starting register address.
// @param data: value to write.
// @param numberRegMinusOne: number of register to write - 1. (we fix it to 0x00 for now)
void fWREG(byte address, byte data) {
  // WREG expects 001rrrrr where rrrrr = _address
  // Open SPI.
  byte op_code = WREG + address;
  digitalWrite(SS, LOW);
  // send_command_and_wait(SSDATAC, 4*tCLK);
  SPI.transfer(op_code);
  // Write only one register
  SPI.transfer(0x00);
  SPI.transfer(data);
  // Close SPI
  digitalWrite(SS, HIGH);
  if (verbose) {
    Serial.print("Register 0x");
    Serial.print(address, HEX);
    Serial.println(" modified.");
  }
  delay(1);
}

// Method to retrieve device ID
void getDeviceID() {
  // Halt SPI data transfer and start reading
  //  delay(500);
  //  send_command_and_wait(SSDATAC, 4*tCLK);
  //  delay(10);
  byte data = fRREG(ID);
  // If retrieved ID is valid, then no power up is needed
  deviceID = data;
  if (verbose) {
    Serial.println("Device ID: ");
    Serial.println(deviceID, BIN);
  }
}

void reset_communication(void) {
  //Resetea la comunicaciÃ³n (datasheet p.30)
  digitalWrite(PIN_SS, HIGH);
  digitalWrite(PIN_RESET, HIGH);
  delay(1000);
  digitalWrite(PIN_RESET, LOW);
  delay(1000);
  digitalWrite(PIN_RESET, HIGH);
  delay(100);
  digitalWrite(PIN_SS, LOW);
  delay(1000);
  digitalWrite(PIN_SS, HIGH);
}




