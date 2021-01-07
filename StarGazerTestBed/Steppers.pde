/*
    Stepper Motor Driver ADafruit Motor Hat
    Uses PCA9685 PWM Driver
    I2C Address: 0x40

*/

final byte stepperAddress = 0x40;

final byte PCA9685_MODE1  = 0x00;
final byte PCA9685_MODE2 = 0x01;

final byte PCA9685_SUBADR1 = 0x02;
final byte PCA9685_SUBADR2 = 0x03;
final byte PCA9685_SUBADR3 = 0x04;
final byte PCA9685_ALL_CALL = 0x05;
final byte PCA9685_PRESCALE = byte(0xFE);
final byte PCA9685_TEST_MODE = byte(0xFF);

final byte LED0_ON_L = 0x06;
final byte LED0_ON_H = 0x07;
final byte LED0_OFF_L = 0x08;
final byte LED0_OFF_H = 0x09;

final byte ALLLED_ON_L = byte(0xFA);
final byte ALLLED_ON_H = byte(0xFB);
final byte ALLLED_OFF_L = byte(0xFC);
final byte ALLLED_OFF_H = byte(0xFD);

final boolean OFF = false;
final boolean ON = true;

final int AZIMUTH = 0;
final int ALTITUDE = 1;

int[] currentStep = {0,0};
int[] azimuthEnable = {8,13};  // PWM pins
int[] azimuthCoils = {9,10,11,12};  // PWM pins
int[] altitudeEnable = {2,7};  // PWM pins
int[] altitudeCoils = {3,4,5,6};  // PWM pins
int[] steps = {10,9,5,6};  // PWM pins

int revSteps = 200;
float azimuthRevolutions = 0.0;
float azimuthDegrees = 0.0;
float altitudeRevolutions = 0.0;
float altitudeDegrees = 0.0;


boolean initSteppers(){
  boolean enabled = true;
  //println("stepper reset");
  //stepperReset();  // do a software reset on the PWM driver
  // mode 1 register: RESTART; EXTCLK; AI; SLEEP; SUB1; SUB2; SUB3; ALLCALL
  //stepperWriteByte(PCA9685_MODE1,0x01); // enable Auto Increment, respond to All Call
  iic.beginTransmission(0x40);
  iic.write(PCA9685_MODE1);
  iic.write(0x21); // auto increment put in normal mode 
  iic.write(0x04); // default
  iic.endTransmission();
  // mode 2 register: 0; 0; 0; INVERT; OCH; OUTDRV; OUTNE1; OUTNE0
  //stepperWriteByte(PCA9685_MODE2,0x04); // outputs set to totem pole DEFAULT REG VALUE
  // prescale register: default set to 200Hz, should be OK since we don't PWM
  stepperStep(AZIMUTH,0);
  stepperStep(ALTITUDE,0);
  stepperEnable(AZIMUTH);
  stepperEnable(ALTITUDE);
  
  return enabled;
}

byte stepperReadAll(){
  iic.beginTransmission(0x40);
  iic.write(0x00);
  iic.write(0x21);
  byte[] b = iic.read(70);
  byte returnByte = b[0];
  return returnByte;
}

byte stepperReadByte(){
  iic.beginTransmission(0x40);
  iic.write(0x00);
  //iic.write(0x21);
  byte[] b = iic.read(1);
  byte returnByte = b[0];
  return returnByte;
}
  
void stepperWriteByte(int reg, int data){
  println("writing 0x"+hex(data)+" to 0x"+hex(reg));
  iic.beginTransmission(0x40);
  iic.write(reg);
  iic.write(data);
  iic.endTransmission();
}

void stepperSetPin(int pin, boolean powered){
 int pinToSet = LED0_ON_L + 4 * pin;
 println("writing "+powered+" to 0x"+hex(pinToSet));
 
 if(powered){  // set the driver to full on
 iic.beginTransmission(stepperAddress);
 iic.write(pinToSet);
   iic.write(0x00);
   iic.write(0x10);  
   iic.write(0x00);
   iic.write(0x00);
 iic.endTransmission();
 } else {      // set the driver to full off
 iic.beginTransmission(stepperAddress);
 iic.write(pinToSet);
   iic.write(0x00);
   iic.write(0x00);  
   iic.write(0x00);
   iic.write(0x10);
 iic.endTransmission();
 }
}

void stepperEnable(int stepper){
  if(stepper == AZIMUTH){
    stepperSetPin(azimuthEnable[0],ON);
    stepperSetPin(azimuthEnable[1],ON);
  } else {
    stepperSetPin(altitudeEnable[0],ON);
    stepperSetPin(altitudeEnable[1],ON);
  }
}

// receives the step number and uses the steps array to drive the pins
void stepperStep(int _stepper, int _step){
  int step = _step%4;  // taking only whole steps
  iic.beginTransmission(stepperAddress);
  if(_stepper == AZIMUTH){
    stepperSetPin(azimuthCoils[0],boolean(step & 0x8));
    stepperSetPin(azimuthCoils[1],boolean(step & 0x4));
    stepperSetPin(azimuthCoils[2],boolean(step & 0x2));
    stepperSetPin(azimuthCoils[3],boolean(step & 0x1));
  } else {
    stepperSetPin(altitudeCoils[0],boolean(step & 0x8));
    stepperSetPin(altitudeCoils[1],boolean(step & 0x4));
    stepperSetPin(altitudeCoils[2],boolean(step & 0x2));
    stepperSetPin(altitudeCoils[3],boolean(step & 0x1));
  }
}

void stepperDisable(int stepper){
  if(stepper == AZIMUTH){
    stepperSetPin(azimuthEnable[0],OFF);
    stepperSetPin(azimuthEnable[1],OFF);
  } else {
    stepperSetPin(altitudeEnable[0],OFF);
    stepperSetPin(altitudeEnable[1],OFF);
  }
}

void stepperReset(){
  iic.beginTransmission(0x00);
  iic.write(0x06);
  iic.endTransmission();
  delay(10);
}
