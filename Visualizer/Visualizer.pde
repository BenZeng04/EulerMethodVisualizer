import java.util.*;
import net.objecthunter.exp4j.Expression;
GraphEngine graph;
TextField differentialField = new TextField(40, 40, 200, 25, 15, "Differential equation");
TextField xField = new TextField(40, 75, 200, 25, 15, "Starting point's x-coordinate");
TextField yField = new TextField(40, 110, 200, 25, 15, "Starting point's y-coordinate");
TextField hField = new TextField(40, 145, 200, 25, 15, "Step length");

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
  if (mouseX >= 65 && mouseX <= 65 + 150 && mouseY >= 180 && mouseY <= 180 + 30) {
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

void draw() {
  graph.updateDifferential(differentialField.getText());
  graph.render();
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
  rect(65, 180, 150, 30, 5);
  textSize(20);
  fill(#7E85FF);

  textAlign(CENTER, CENTER);
  text("Add Point!", 65 + 150 / 2, 180 + 12);
}
