/*
    Star Gazer Test Bed
    
    
*/

DisposeHandler dh;

import processing.io.*;

I2C i2c;
int lastTick;

boolean boo = false;

boolean isRunning = false;

final byte stepperAddress= 0x40;

void setup(){
  size(200, 200);
  background(12);
  noStroke();
  GPIO.pinMode(DRDY,GPIO.INPUT);
  dh = new DisposeHandler(this);
  //printArray(I2C.list());
  i2c = new I2C(I2C.list()[0]);
  
  boo = initCompass();
  println("compass enabled: "+boo);
  boo = initSteppers();
  println("steppers enabled: "+boo);
  lastTick = second();
}
  
void draw(){
  drawStuff();
  
  if(isRunning){
    if(GPIO.digitalRead(DRDY) == GPIO.LOW){
      updateCompassAxes();
      printCompassAxes();
    }
  }
  
  
}


void drawStuff(){
  
}
