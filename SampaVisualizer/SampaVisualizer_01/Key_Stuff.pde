



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
      case 'p':
        printVertecesArrays();
        break;
      default:
        println("keyboard got "+key);
        break;
    }
  }
}

void printVertecesArrays(){
  println("Sun Az    Sun Al    Moon AZ    Moon AL");
  for(int i=0; i<vertices; i++){
    println(sunHistory[X][i]+"    "+sunHistory[Y][i]+"    "+moonHistory[X][i]+"    "+moonHistory[Y][i]);
  }
}
