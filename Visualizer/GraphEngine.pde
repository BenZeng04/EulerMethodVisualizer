class GraphEngine {
  // The position of the camera: what (x, y) co-ordinate is on the center of the screen?
  // Note that (x, y) refers to graph co-ordinates, not processing graphics co-ordinates
  private final float zoom = 25;
  private final float[] polynomial = {-1, 1, 1, -3, 1}; // x^4 - 3x^3 + x^2 + x - 1
  
  public void renderAxis() {
    background(255);
    stroke(0);
    strokeWeight(2);
    line(0, height / 2, width, height / 2);
    line(width / 2, 0, width / 2, height);
    textAlign(LEFT, BASELINE);
    final int skip = 5;
    // Drawing x-axis with a thicker line & label every 5 units
    int xStart = -ceil(width / 2 / zoom), xEnd = -xStart;
    for (int i = xStart; i <= xEnd; i++) {
      if (i == 0) continue;
      if (i % skip == 0) {
        strokeWeight(1);
        stroke(0, 175);
        float x = i * zoom + width / 2;
        line(x, 0, x, height);
        fill(0);
        final int size = 12;
        textSize(size);
        text(i, x + size / 4, height / 2 + size);
      }
      else {
        strokeWeight(0.5);
        stroke(0, 80);
        float x = i * zoom + width / 2;
        line(x, 0, x, height);
      }
    }
    
    // Drawing y-axis with a thicker line & label every 5 units
    int yStart = -ceil(height / 2 / zoom), yEnd = -yStart;
    for (int i = yStart; i <= yEnd; i++) {
      if (i == 0) continue;
      if (i % skip == 0) {
        strokeWeight(1);
        stroke(0, 175);
        float y = -i * zoom + height / 2;
        line(0, y, width, y);
        fill(0);
        final int size = 12;
        textSize(size);
        text(i, width / 2 + size / 4, y + size);
      }
      else {
        strokeWeight(0.5);
        stroke(0, 80);
        float y = -i * zoom + height / 2;
        line(0, y, width, y);
      }
    }
    
    // Drawing the zero label at (0, 0)
    fill(0);
    final int size = 12;
    textSize(size);
    text(0, width / 2 + size / 4, height / 2 + size);
  }
  
  public float f(float x) {
    float res = 0;
    float pow = 1;
    for (int i = 0; i < polynomial.length; i++) {
      res += pow * polynomial[i];
      pow *= x;
    }
    return res;
  }
  
  public void renderPolynomial() {
    stroke(255, 0, 0);
    strokeWeight(3);
    float prevX = 0, prevY = 0;
    for (int i = 0; i <= width; i++) {
      float x = ((float) i - width / 2) / zoom;
      float y = -f(x);
      // y needs to be negative to be rendered correctly, since processing field is inverted
      if (i == 0) {
        point(x * zoom + width / 2, y * zoom + height / 2);
      } else {
        line(prevX * zoom + width / 2, prevY * zoom + height / 2, x * zoom + width / 2, y * zoom + height / 2);
      }
      prevX = x; 
      prevY = y;
    }
  }
  
  public void renderPoint(float x, float y) {
    x *= zoom;
    y *= -zoom;
    x += width / 2;
    y += height / 2;
    ellipse(x, y, 20, 20);
  }

  public void render() {
    pushMatrix();
    renderAxis();
    renderPolynomial();
    popMatrix();
  }
}
