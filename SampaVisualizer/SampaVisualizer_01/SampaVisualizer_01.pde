
DisposeHandler dh;
PFont font;
import processing.net.*; 

Client sampa; 
String dataIn; 

color ground = color(5,70,130);
color moonColor = color(190,250,250);
color sunColor = color(240,240,100);

float sunA,sunZ,moonA,moonZ;  // sun and moon positions
final float aRange = 1080.0;  // 3x 360
final float zRange = 540.0;   // 3x 180
final int axes = 2;
final int vertices = 200;
final int X = 0;
final int Y = 1;
float xOffset,yOffset;

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
  // Connect to the local machine at port 5204.
  // This example will not run if you haven't
  // previously started a server on this port.
  sampa = new Client(this, "127.0.0.1", 9876);
  // in case of connection refusal, start server program here
  lastMinute = minute();
} 
 
void draw() { 
  
  drawStuff();
  
  if(minute() != lastMinute){
    lastMinute = minute();
    sendTimeStamp();
  }
  checkSampa();
} 

void sendTimeStamp(){
  //println("sending on "+str(minute()));
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
