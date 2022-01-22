import java.util.*;
import net.objecthunter.exp4j.Expression;
GraphEngine graph;

void setup() {
  size(800, 500);
  graph = new GraphEngine("-x/(2+y)");
  graph.insertPoint(-3, -3, 0.25);
}

void draw() {
  graph.render();
  
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
  
  if (mousePressed) {
    if (mouseX >= 754 && mouseX <= 754 + 37 && mouseY >= 210 && mouseY <= 210 + 37) {
      graph.increaseZoom();
    }
    if (mouseX >= 754 && mouseX <= 754 + 37 && mouseY >= 252 && mouseY <= 252 + 37) {
      graph.decreaseZoom();
    }
  }
}
