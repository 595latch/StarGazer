/*
    Do all the things that you need to do when the program closes here

*/




void stop(){
  println("stopping");
  sampaWrite("exitConnection");
  super.stop();
}

void exit(){
  println("exiting");
  sampaWrite("exitConnection");
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
    println("disposing");
    sampaWrite("exitConnection");
  }
}
