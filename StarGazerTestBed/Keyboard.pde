/*
    All Things Keyboard related
    
    This includes Dispose Handler

*/

void keyPressed(){
 
  switch(key){
    case 'C':
      isRunning = true;
      lastTick = second();
      //startCompass();
      break;
    case 'c':
      isRunning = false;
      //stopCompass();
      break;
    default:
      break;
  }
}
