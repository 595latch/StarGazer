/*
    All Things Keyboard related
    
    This includes Dispose Handler

*/

void keyPressed(){
 
  switch(key){
    case 'c':
      getCompassID();
      break;
    case 'b':
      isRunning = true;
      lastTick = second();
      //startCompass();
      break;
    case 's':
      isRunning = false;
      //stopCompass();
      break;
    case 'I':
      initSteppers();
      //initCompass();
      break;
    case 'r':
      byte reg = 0x00;
      print("reading reg 0x" +reg+" value 0x"+hex(stepperReadByte()));
      break;
    default:
      break;
  }
}

void printCommands(){
  println("Star Gazer Commands");
  println("Press 'I' to initialize");
  println("Press 'b' to begin test");
  println("Press 's' to stop test");
  println();
}
