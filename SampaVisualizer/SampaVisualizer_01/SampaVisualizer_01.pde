
DisposeHandler dh;
PFont font;
import processing.net.*; 

Client sampa; 
String dataIn; 

color ground = color(5,70,130);
color moonColor = color(190,250,250);
color sunColor = color(240,240,100);
color gridColor = color(128,128,128);

float sunA,sunZ,moonA,moonZ;  // sun and moon positions
final float aRange = 1080.0;  // 3x 360
final float zRange = 540.0;   // 3x 180
final int axes = 2;
final int vertices = 288;  // every 10 munites for 48 hours
final int X = 0;
final int Y = 1;
float xOffset,yOffset;
float sunX, sunY, moonX, moonY;
float[][] sunHistory = new float[axes][vertices];
float[][] moonHistory = new float[axes][vertices];
int dataPointCounter = 0;

int dia = 10;
int lastMinute;
boolean gotData = false;

void setup() { 
  size(1200, 600); 
  noStroke();
  ellipseMode(CENTER);
  xOffset = (width-aRange)/2;
  yOffset = (height-zRange)/2;
  resetDataPoints();
  font = createFont("FreeMono Bold",48);
  textFont(font,24);
  textAlign(CENTER);
  if(!connectToSwerver()){
    delay(100);
    println("Could not connect to sampa server");
    println("Try starting sampa manually and press 'c' to try again");
  } else {
    println("Connected to sampa");
  }
  lastMinute = minute();
} 
 
void draw() { 
  
  drawStuff();
  
  if(minute() != lastMinute){
    lastMinute = minute();
    sendTimeStamp();
  }
  checkSampa();
  checkMousePos();
} 

void sendTimeStamp(){
  println("sending on "+str(minute()));
  String timeStamp = str(year())+" "+str(month())+" "+str(day())+" "+str(hour())+" "+str(minute());
  sampaWrite(timeStamp);
}

void resetDataPoints(){
  
    for(int v=0; v<vertices; v++){
      sunHistory[X][v] = width/2;
      sunHistory[Y][v] = height/2;
      moonHistory[X][v] = width/2;
      moonHistory[Y][v] = height/2;
    }
    
}
