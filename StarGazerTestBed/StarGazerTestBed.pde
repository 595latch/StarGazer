/*
    Star Gazer Test Bed


*/

DisposeHandler dh;

import processing.io.*;

I2C i2c;
int lastTick;

boolean boo = false;

boolean isRunning = false;



void setup(){
  size(200, 200);
  background(12);
  noStroke();
  GPIO.pinMode(DRDY,GPIO.INPUT);
  dh = new DisposeHandler(this);
  //printArray(I2C.list());
  i2c = new I2C(I2C.list()[0]);

  //boo = initCompass();
  //println("compass enabled: "+boo);
   boo = initSteppers();
   println("steppers enabled: "+boo);
  // lastTick = second();
}

void draw(){
  drawStuff();

  if(isRunning){
    if(second() != lastTick){
      lastTick = second();
      //updateCompassAxes();
      //printCompassAxes();
      currentStep[ALTITUDE]++;
      currentStep[AZIMUTH]++;
      stepperStep(ALTITUDE,currentStep[ALTITUDE]);
      stepperStep(AZIMUTH,currentStep[AZIMUTH]);
      altitudeRevolutions = currentStep[ALTITUDE]/200;
      azimuthRevolutions = currentStep[AZIMUTH]/200;
      println("Altitude Step: "+(currentStep[ALTITUDE]%4)+"Altitude Rotation: "+altitudeRevolutions);
      println("Azimuth Step: "+(currentStep[AZIMUTH]%4)+"Azimuth Rotation: "+azimuthRevolutions);
    }
  }


}


void drawStuff(){

}
