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
final byte PCA9685_PRESCALE = 0xFE;
final byte PCA9685_TEST_MODE = 0xFF;

final byte LED0_ON_L = 0x06;
final byte LED0_ON_H = 0x07;
final byte LED0_OFF_L = 0x08;
final byte LED0_OFF_H = 0x09;

final byte ALLLED_ON_L = 0xFA;
final byte ALLLED_ON_H = 0xFB;
final byte ALLLED_OFF_L = 0xFC;
final byte ALLLED_OFF_H = 0xFD;

final boolean OFF = false;
final boolean ON = true;

final int AZIMUTH = 0;
final int ALTITUDE = 1;

int[] currentStep = new int [2];
int[] azimuthEnable = new int {8,13};
int[] azumuthCoils = new int {9,10,11,12};
int[] altitudeEnable = new int {2,7};
int[] altitudeCoils = new int {3,4,5,6};
int[] steps = new int {10,9,5,6};

int revSteps = 200;
float azimuthRevolutions = 0.0;
float azimuthDegrees = 0.0;
float altitudeRevolutions = 0.0;
float altitudeDegrees = 0.0;


boolean initSteppers(){
  boolean enabled = true;

  // mode 1 register: RESTART; EXTCLK; AI; SLEEP; SUB1; SUB2; SUB3; ALLCALL
  stepperWriteByte(PCA9685_MODE1,0x21); // enable Auto Increment, respond to All Call
  // mode 2 register: 0; 0; 0; INVERT; OCH; OUTDRV; OUTNE1; OUTNE0
  stepperWriteByte(PCA9685_MODE2,0x04); // outputs set to totem pole DEFAULT REG VALUE
  // prescale register: default set to 200Hz, should be OK
  
  
  return enabled;
}

  
void stepperWriteByte(byte reg, byte data){
  i2c.beginTransmission(stepperAddress);
  i2c.write(reg);
  i2c.write(data);
  i2c.endTransmission();
}

void stepperSetPin(int pin, boolean powered){
 byte pinToSet = byte(LED0_ON_L + 4 * pin);
 i2c.beginTransmission(stepperAddress);
 i2c.write(pinToSet);
 if(powered){  // set the driver to full on
   i2c.write(0x00);
   i2c.write(0x10);  
   i2c.write(0x00);
   i2c.write(0x00);
 } else {      // set the driver to full off
   i2c.write(0x00);
   i2c.write(0x00);  
   i2c.write(0x00);
   i2c.write(0x10);
 }
 i2c.endTransmission();
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
void stepperStep(int stepper, int step){
  i2c.beginTransmission(stepperAddress);
  if(stepper = AZIMUTH
    i2c.write(azimuthCoils[0],boolean(step & 0x8));
    i2c.write(azimuthCoils[1],boolean(step & 0x4));
    i2c.write(azimuthCoils[2],boolean(step & 0x2));
    i2c.write(azimuthCoils[3],boolean(step & 0x1));
  } else {
    i2c.write(altitudeCoils[0],boolean(step & 0x8));
    i2c.write(altitudeCoils[1],boolean(step & 0x4));
    i2c.write(altitudeCoils[2],boolean(step & 0x2));
    i2c.write(altitudeCoils[3],boolean(step & 0x1));
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
  i2c.beginTransmission(0x00);
  i2c.write(0x06);
  i2c.endTransmission();
  delay(10);
}
