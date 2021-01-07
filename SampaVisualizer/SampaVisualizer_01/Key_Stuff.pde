



void keyPressed(){
  char k = key;
  if(key != CODED || key != ESC){
    switch(key){
      case 'c':
        if(!sampa.active()){
          if(!connectToSwerver()){
            println("connection failed, try again?");
          }
        } else {
          println("Already connected to sampa");
        }
        break;
      default:
        println("keyboard got "+key);
        break;
    }
  }
}
