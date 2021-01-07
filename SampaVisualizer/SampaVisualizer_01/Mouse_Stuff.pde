

void checkMousePos(){
  if(mouseX<sunX+6 && mouseX>sunX-6 && mouseY<sunY+6 && mouseY>sunY-6){
    fill(gridColor);
      text("a:"+sunA+"  z:"+sunZ,sunX,sunY-20);
  }
  if(mouseX<moonX+6 && mouseX>moonX-6 && mouseY<moonY+6 && mouseY>moonY-6){
    fill(gridColor);
      text("a:"+moonA+"  z:"+moonZ,moonX,moonY-20);
  }
}
