import java.util.*;
import net.objecthunter.exp4j.Expression;
GraphEngine graph;
DraggableBox textbox = new DraggableBox(40, 40, 200, 25, 15, 10, 4);

TextField differentialField = new TextField(textbox, 0, "Differential equation");
TextField xField = new TextField(textbox, 1, "Starting point's x-coordinate");
TextField yField = new TextField(textbox, 2, "Starting point's y-coordinate");
TextField hField = new TextField(textbox, 3, "Step length");

float initialMouseX, initialMouseY;
boolean moving = false;
boolean zooming = false;

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
  boolean buttonPressed = false;
  initialMouseX = graph.fitScreenToX(mouseX);
  initialMouseY = graph.fitScreenToY(mouseY);

  if(differentialField.mousePressed()) buttonPressed = true;
  if(xField.mousePressed()) buttonPressed = true;
  if(yField.mousePressed()) buttonPressed = true;
  if(hField.mousePressed()) buttonPressed = true;
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
    buttonPressed = true;
  }
  
  if (mouseX >= textbox.startX+25 && mouseX <= textbox.startX+25 + 150 && mouseY >= textbox.startY+textbox.increment*5 && mouseY <= textbox.startY+textbox.increment*5 + 30) {
    graph.removeAllPoints();
    buttonPressed = true;
  }
  if (mouseX >= 754 && mouseX <= 754 + 37 && mouseY >= 210 && mouseY <= 210 + 37) {
    buttonPressed = true;
    zooming = true;
  }
  if (mouseX >= 754 && mouseX <= 754 + 37 && mouseY >= 252 && mouseY <= 252 + 37) {
    buttonPressed = true;
    zooming = true;
  }
  
  // Don't move the textbox if pressing other buttons
  if (!buttonPressed) {
    if(textbox.mousePressed()) {
      buttonPressed = true; 
    }
  }

  // Don't pan the screen if pressing other buttons or if adding points 
  if (!buttonPressed) { 
    if (mouseButton == RIGHT) {
      try {
        float x = graph.fitScreenToX(mouseX);
        float y = graph.fitScreenToY(mouseY);
        float h = Float.parseFloat(hField.getText());
        graph.insertPoint(x, y, h);
      }
      catch (Exception e) {
        // Don't add if cannot parse (x, y)
      }
    }
    else moving = true;
  } else moving = false;
}

void mouseDragged() {
  if (mouseX >= width || mouseX <= 0 || mouseY >= height || mouseY <= 0) return;
  textbox.mouseDragged();
  if (moving) {
    graph.setCenterX(graph.getCenterX() - (graph.fitScreenToX(mouseX) - initialMouseX));
    graph.setCenterY(graph.getCenterY() - (graph.fitScreenToY(mouseY) - initialMouseY));
  }
}

void mouseWheel(MouseEvent event) {
  //use mouse wheel to scroll
  float scroll = event.getCount();
  if (scroll > 0) {
    for (int i = 0; i < scroll; i++)
      graph.increaseZoom();
  }
  else if (scroll < 0) {
    for (int i = 0; i < -scroll; i++)
      graph.decreaseZoom();
  }
}


void mouseReleased() {
  moving = false;
  zooming = false;
  textbox.mouseReleased();
}

void draw() {
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
  if (zooming) {
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
  
  // Delete point button
  fill(#C6C9FF, 220);
  rect(textbox.startX+25, textbox.startY+textbox.increment*5, 150, 30, 5);

  fill(#7E85FF);
  text("Clear Points!", textbox.startX+25 + 150 / 2, textbox.startY+textbox.increment*5 + 12);
}
