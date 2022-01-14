class GraphEngine {
  class ApproximationPoint {
    private float prevX, prevY;
    private float x, y;
    private int frame;
    public ApproximationPoint(float x0, float y0) {
      this.x = this.prevX = x0;
      this.y = this.prevY = y0;
    }
    public void render() {
      float h = 0.01;
      float baseStep = 0.01;
      float displayX, displayY;
      if (frame % (int) (h / baseStep) == 0) {
        prevX = x; 
        prevY = y;
        displayX = x;
        displayY = y;
        y = y + h * differential(x, y);
        x += h;
        
      } else {
        float progress = (frame % (int) (h / baseStep)) / (h / baseStep);
        progress = pow(progress, 0.5);
        displayX = prevX + (x - prevX) * progress;
        displayY = prevY + (y - prevY) * progress;
      }
      String msg = "(" + x + ", " + y + ")";
      
      double slope = differential(prevX, prevY);
      double theta = Math.atan(slope);
      int skip = ceil(pow(5, ceil(log(width / zoom / 32) / log(5))));
      double len = skip * 1.4;
      float xLen = (float) (Math.cos(theta) * len);
      float yLen = (float) (Math.sin(theta) * len);
      fill(77, 230);
      stroke(127, 200);
      strokeWeight(5);
      renderLine(displayX - xLen / 2, displayY - yLen / 2, displayX + xLen / 2, displayY + yLen / 2);
      strokeWeight(15);
      renderPointWithLabel(displayX, displayY, msg);
      frame++;
    }
  }
  ArrayList<ApproximationPoint> points = new ArrayList<>();
  public GraphEngine() {
    points.add(new ApproximationPoint(-1, 0));
    points.add(new ApproximationPoint(-2, 0));
    points.add(new ApproximationPoint(-3, 0));
    points.add(new ApproximationPoint(-4, 0));
    points.add(new ApproximationPoint(-5, 0));
  }
  private final int baseZoom = 25;
  private float zoom = 25;
  private float zoomLog = 0; 
  private void increaseZoom() {
    zoomLog += 0.01;
    zoom = baseZoom * pow(10, zoomLog);
  }
  private void decreaseZoom() {
    zoomLog -= 0.01;
    zoom = baseZoom * pow(10, zoomLog);
  }
  private float[] polynomial = {-1, 0.03, 0.03, -0.1, 0.01}; // x^4 - 3x^3 + x^2 + x - 1
  private float differential(float x, float y) {
    float res = 0;
    float pow = 1;
    for (int i = 1; i < polynomial.length; i++) {
      res += i * pow * polynomial[i];
      pow *= x;
    }
    return -x/(abs(y) + 1);
  }
  public void renderAxis() {
    background(255);
    stroke(0);
    strokeWeight(2);
    line(0, height / 2, width, height / 2);
    line(width / 2, 0, width / 2, height);
    textAlign(LEFT, BASELINE);
    int skip = ceil(pow(10, ceil(log(width / zoom / 64) / log(10))));

    int xStart = -ceil(width / 2 / zoom), xEnd = -xStart;
    for (int i = xStart; i <= xEnd; i++) {
      if (i == 0) continue;
      if (i % skip != 0) continue;
      if (i % (skip * 5) == 0) {
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

    int yStart = -ceil(height / 2 / zoom), yEnd = -yStart;
    for (int i = yStart; i <= yEnd; i++) {
      if (i == 0) continue;
      if (i % skip != 0) continue;
      if (i % (skip * 5) == 0) {
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
  
  public void renderSlopeField() {
    stroke(0, 0, 255, 66);
    strokeWeight(3);
    int skip = ceil(pow(5, ceil(log(width / zoom / 32) / log(5))));
    int xStart = -ceil(width / 2 / zoom), xEnd = -xStart;
    int yStart = -ceil(height / 2 / zoom), yEnd = -yStart;
    for (int x = xStart / skip * skip; x <= xEnd; x += skip) {
      for (int y = yStart / skip * skip; y <= yEnd; y += skip) {
        double slope = differential(x, y);
        double theta = Math.atan(slope);
        double len = skip * 0.8;
        float xLen = (float) (Math.cos(theta) * len);
        float yLen = (float) (Math.sin(theta) * len);
        renderLine(x - xLen / 2, y - yLen / 2, x + xLen / 2, y + yLen / 2);
      }
    }
  }
  
  public void renderPolynomial() {
    stroke(255, 0, 0);
    strokeWeight(3);
    float prevX = 0, prevY = 0;
    for (int i = 0; i <= width; i++) {
      float x = ((float) i - width / 2) / zoom;
      float y = f(x);

      if (i == 0) {
        renderPoint(x, y);
      } else {
        renderLine(x, y, prevX, prevY);
      }
      prevX = x; 
      prevY = y;
    }
    stroke(0, 0, 255);
  }
  public void renderPointWithLabel(float x, float y, String msg) {
    textAlign(LEFT, BASELINE);
    
    x *= zoom;
    y *= -zoom;
    x += width / 2;
    y += height / 2;
    
    if (x >= 0 && x <= width && y >= 0 && y <= height) {
      point(x, y);
    }
    
    float size = 12;
    textSize(size);
    text(msg, x + size, y);
  }
  public void renderPoint(float x, float y) {
    x *= zoom;
    y *= -zoom;
    x += width / 2;
    y += height / 2;
    if (x >= 0 && x <= width && y >= 0 && y <= height) {
      point(x, y);
    }
  }

  public void renderLine(float x1, float y1, float x2, float y2) {
    x1 *= zoom;
    y1 *= -zoom;
    x1 += width / 2;
    y1 += height / 2;
    x2 *= zoom;
    y2 *= -zoom;
    x2 += width / 2;
    y2 += height / 2;
    if ((x1 >= 0 && x1 <= width && y1 >= 0 && y1 <= height) ||
      (x2 >= 0 && x2 <= width && y2 >= 0 && y2 <= height)) {
      line(x1, y1, x2, y2);
    }
  }
  
  public void render() {
    
    pushMatrix();
    renderAxis();
    renderSlopeField();
    renderPolynomial();
    for (ApproximationPoint p: points) p.render();
    popMatrix();
  }
}
