/*
    Do all the things that you need to do when the program closes here

*/




void stop(){
  compassWrite(LIS3MDL_REG_CTRL_REG2,LIS3MDL_SOFT_RESET);  // reset registers
  stopCompass();
  println("in stop");
  super.stop();
}

void exit(){
  compassWrite(LIS3MDL_REG_CTRL_REG2,LIS3MDL_SOFT_RESET);  // reset registers
  stopCompass();
  println("in exit");
  super.exit();
}

public class DisposeHandler
{
  DisposeHandler(PApplet pa)
  {
    pa.registerMethod("dispose", this);
  }
 
  public void dispose()
  {
    compassWrite(LIS3MDL_REG_CTRL_REG2,LIS3MDL_SOFT_RESET);  // reset registers
    stopCompass();
    println("in dispose");
  }
}
