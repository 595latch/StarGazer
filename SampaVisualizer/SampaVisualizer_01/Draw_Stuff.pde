

void drawStuff(){
  background(ground);
  drawGrid();
  drawSun();
  drawMoon();
}

void drawGrid(){
  stroke(gridColor);
  strokeWeight(1);
  line(xOffset,height/2,width-xOffset,height/2);
  line(width/2,yOffset,width/2,height-yOffset);
  line(xOffset,height/2-30,xOffset,height/2+30);
  line(width-xOffset,height/2-30,width-xOffset,height/2+30);
  line(width/2-30,yOffset,width/2+30,yOffset);
  line(width/2-30,height-yOffset,width/2+30,height-yOffset);
  noStroke();
  fill(gridColor);
  text("E",xOffset-12,height/2+8);
  text("W",width-xOffset+12,height/2+8);
  text("Z",width/2,yOffset-8);
  text("Middle Earth",width/2,height-yOffset+20);
}

void drawSun(){
  noStroke();
  fill(sunColor);
  ellipse(sunX,sunY,dia,dia);
  stroke(sunColor);
  noFill();
  beginShape(POINTS);
  for(int v=0; v<vertices; v++){
    vertex(sunHistory[X][v],sunHistory[Y][v]);
  }
  endShape();
}

void drawMoon(){
  noStroke();
  fill(moonColor);
  ellipse(moonX,moonY,dia,dia);
  stroke(moonColor);
  noFill();
  beginShape(POINTS);
  for(int v=0; v<vertices; v++){
    vertex(moonHistory[X][v],moonHistory[Y][v]);
  }
  endShape();
}

void recordData(){
  if(minute()%10 == 0){ shiftData(); }
  addData();
}

void addData(){
  sunHistory[X][0] = sunX = map(sunA,0,360,xOffset,width-xOffset);
  sunHistory[Y][0] = sunY = map(sunZ,0,180,yOffset,height-yOffset);
  moonHistory[X][0] = moonX = map(moonA,0,360,xOffset,width-xOffset);
  moonHistory[Y][0] = moonY = map(moonZ,0,180,yOffset,height-yOffset);
}

void shiftData(){
  for(int a=0; a<2; a++){
    for(int i=vertices-1; i>0; i--){
      sunHistory[X][i] = sunHistory[X][i-1];
      sunHistory[Y][i] = sunHistory[Y][i-1];
      moonHistory[X][i] = moonHistory[X][i-1];
      moonHistory[Y][i] = moonHistory[Y][i-1];
      //print("sun: "+X+":"+i+" = "+sunHistory[X][i]);
      //println("  "+Y+":"+i+" = "+sunHistory[Y][i]);
      //print("moon: "+X+":"+i+" = "+moonHistory[X][i]);
      //println("  "+Y+":"+i+" = "+moonHistory[Y][i]);
    }
  }
}
