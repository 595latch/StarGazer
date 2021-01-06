

void sampaWrite(String s){
  if(sampa.active() == true){
    sampa.write(s);
  }
}

String sampaRead(){
  String response = "0";
  if(sampa.active() == true){
    
  }
  return response;
}

void checkSampa(){
  if(sampa.active() == true){
    if (sampa.available() > 0) { 
      boolean eom = false;
      dataIn = sampa.readStringUntil('\n'); 
      String floaty = nf(float(dataIn.substring(1)),0,2);
      switch(dataIn.charAt(0)){
        case 'A':
          print("Sun Azimuth: ");
          sunA = float(floaty);
          break;
        case 'Z':
          print("Sun Zenith: ");
          sunZ = float(floaty);
          break;
        case 'a':
          print("Moon Azimuth: ");
          moonA = float(floaty);
          break;
        case 'z':
          print("Moon Zenith: ");
          moonZ = float(floaty);
          break;
        case '$':
          eom = true;
          break;
        default:
          println("i got: "+dataIn.charAt(0));
          break;
      }
      if(eom){ recordData(); } // return from this
      //dataIn = dataIn.substring(1);
      println(floaty); // verbose
    }
  } 
}
