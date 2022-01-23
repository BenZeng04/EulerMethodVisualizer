import java.util.*;
import net.objecthunter.exp4j.Expression;
GraphEngine graph;
DraggableBox textbox = new DraggableBox(40, 40, 200, 25, 15, 10, 4);

TextField differentialField = new TextField(textbox.startX, textbox.startY, textbox.width, textbox.height, textbox.textSize, "Differential equation");
TextField xField = new TextField(textbox.startX, textbox.startY+textbox.increment, textbox.width, textbox.height, textbox.textSize, "Starting point's x-coordinate");
TextField yField = new TextField(textbox.startX, textbox.startY+textbox.increment*2, textbox.width, textbox.height, textbox.textSize, "Starting point's y-coordinate");
TextField hField = new TextField(textbox.startX, textbox.startY+textbox.increment*3, textbox.width, textbox.height, textbox.textSize, "Step length");

//todo: clicking to add points, panning across graph, option to slow down, mouse to zoom

class DraggableBox { //so i thought it would be nice to have the text boxes be draggable
  int startX = 40; int startY = 40; int width = 200; int height = 25; int textSize = 15;
  int increment = height+10; int numberOfTextBoxes = 4;
  
  public DraggableBox (int x, int y, int w, int h, int t, int i, int n) {
    startX=x; startY=y; width=w; height=h; textSize=t; increment=i+height; numberOfTextBoxes = n;
  }
  boolean ifDragged() {
    //drag window
    if (mouseX >= startX-10 && mouseX <= startX + width+20 && mouseY >= startY-10 && mouseY <= startY + height*(numberOfTextBoxes+1) + 25) {
      startX = mouseX;
      startY = mouseY;
      return true;
    }
    return false;
  }
  void drawBox() {
    rect(startX-10, startY-10, width+20, height*(numberOfTextBoxes+1) + 25, 5);
  }
}

void setup() {
  size(800, 500);
  graph = new GraphEngine("");
}

void keyTyped() {
  differentialField.keyTyped();
  xField.keyTyped();
  yField.keyTyped();
  hField.keyTyped();
}

void mousePressed() {
  differentialField.mousePressed();
  xField.mousePressed();
  yField.mousePressed();
  hField.mousePressed();
  // Add point button
  if (mouseX >= textbox.startX+25 && mouseX <= textbox.startX+25 + 150 && mouseY >= textbox.startY+textbox.increment*4 && mouseY <= textbox.startY+textbox.increment*4 + 30) {
    try {
      float x = Float.parseFloat(xField.getText());
      float y = Float.parseFloat(yField.getText());
      float h = Float.parseFloat(hField.getText());
      graph.insertPoint(x, y, h);
    }
    catch (Exception e) {
      // Don't add if cannot parse (x, y)
    }
  }
}

void mouseDragged() {
  //dragging textbox
  boolean objectDragged = textbox.ifDragged();
  //translating text field if nothing else is dragged
  if (!objectDragged) {
    translate(mouseX, mouseY);
  }
}

void mouseWheel(MouseEvent event) {
  //use mouse wheel to scroll
  float scroll = event.getCount();
  if (scroll>0) graph.increaseZoom();
  else if (scroll<0) graph.decreaseZoom();
}


void draw() {
  //update position of textboxes based on draggable box
  differentialField.x = textbox.startX;
  differentialField.y = textbox.startY;
  xField.x = textbox.startX;
  xField.y = textbox.startY + textbox.increment;
  yField.x = textbox.startX;
  yField.y = textbox.startY + textbox.increment*2;
  hField.x = textbox.startX;
  hField.y = textbox.startY + textbox.increment*3;

  //draw graph
  graph.updateDifferential(differentialField.getText());
  graph.render();
  
  //draw textboxes
  textbox.drawBox();
  differentialField.render();
  xField.render();
  yField.render();
  hField.render();

  // Side buttons for zoom
  stroke(#7E85FF, 190);
  fill(#C6C9FF, 220);
  strokeWeight(3);
  rect(750, 200, 45, 100, 5);
  rect(754, 210, 37, 37, 5);
  rect(754, 252, 37, 37, 5);

  stroke(111, 220);
  line(765, 229, 780, 229);
  line(773, 222, 773, 237);
  line(765, 271, 780, 271);

  // Zoom buttons here instead of mousePressed() so holding down continues to zoom
  if (mousePressed) {
    if (mouseX >= 754 && mouseX <= 754 + 37 && mouseY >= 210 && mouseY <= 210 + 37) {
      graph.increaseZoom();
    }
    if (mouseX >= 754 && mouseX <= 754 + 37 && mouseY >= 252 && mouseY <= 252 + 37) {
      graph.decreaseZoom();
    }
  }

  // Add point button
  stroke(#7E85FF, 190);
  fill(#C6C9FF, 220);
  strokeWeight(3);
  rect(textbox.startX+25, textbox.startY+textbox.increment*4, 150, 30, 5);
  textSize(20);
  fill(#7E85FF);

  textAlign(CENTER, CENTER);
  text("Add Point!", textbox.startX+25 + 150 / 2, textbox.startY+textbox.increment*4 + 12);
}
