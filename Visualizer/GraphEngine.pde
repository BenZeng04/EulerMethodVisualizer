class GraphEngine {
  // ApproximationPoints are (x, y) values you can "add" to the graph that will constantly move according to Euler's Method.
  class ApproximationPoint {
    private color trail;
    private ArrayList<Float> pathX, pathY;
    private float prevX, prevY;
    private float x, y;
    private float h;
    private final float baseStep = 0.01; // A "base-step" is used so that large values of h will not cause points to go extremely fast, and instead have animated movement in a straight line per step
    private int frame;
    public ApproximationPoint(float x0, float y0, float h) {
      this.x = this.prevX = x0;
      this.y = this.prevY = y0;
      trail = color(random(255), random(255), random(255));
      pathX = new ArrayList<Float>();
      pathY = new ArrayList<Float>();
      pathX.add(x0);
      pathY.add(y0);
      // Round the step up to the nearest baseStep (used for animations)
      if (h == 0) h = baseStep;
      else if (h > 0) {
        int roundedQuotient = ceil(h / baseStep);
        this.h = roundedQuotient * baseStep;
      } else {
        // Round down if negative
        int roundedQuotient = floor(h / baseStep);
        this.h = roundedQuotient * baseStep;
      }
    }
    public void render() {
      float displayX, displayY;
      // Euler's Method
      // Modulo is used so that the point only follows a step in Euler's method every (h / baseStep) frames; this causes all points added to move with the same x-velocity.
      if (frame % (int) (h / baseStep) == 0) {
        prevX = x; 
        prevY = y;
        pathX.add(x);
        pathY.add(y);
        displayX = x;
        displayY = y;
        float dydx = parser.differential(x, y);
        if (!Float.isNaN(dydx)) {
          y = y + h * dydx;
          x += h;
        }
      } else {
        // Instead of teleporting to the next point per iteration of Euler's method, points will travel a straight line from (x1, y1) to (x2, y2)
        float progress = (frame % (int) (h / baseStep)) / (h / baseStep);
        if (progress < 0) progress *= -1;
        progress = pow(progress, 0.5); // The progress is rooted such that the animation is non-linear and more realistically "snaps" to the next point
        displayX = prevX + (x - prevX) * progress;
        displayY = prevY + (y - prevY) * progress;
      }
      // Label is given showcasing (x, y), rounded to the nearest 100th
      // Note that it showcases (x, y) as per Euler's method iterations and not the animated progress
      String msg = "(" + String.format("%.2f", x)  + ", " + String.format("%.2f", y) + ")";
      
      float slope = parser.differential(prevX, prevY);
      fill(trail, 230);
      stroke(trail, 200);
      if (!Float.isNaN(slope)) {
        double theta = Math.atan(slope);
        double len = width / zoom / 32 * 1.4;
        float xLen = (float) (Math.cos(theta) * len);
        float yLen = (float) (Math.sin(theta) * len);
        
        strokeWeight(5);
        renderLine(displayX - xLen / 2, displayY - yLen / 2, displayX + xLen / 2, displayY + yLen / 2);
      }
      strokeWeight(3);
      final int maxPathLength = 20;
      if (pathX.size() > maxPathLength) {
        pathX.remove(0);
        pathY.remove(0);
      }
      // Draw at most 20 previous path segments to prevent lag
      for (int i = 1; i < pathX.size(); i++) {
        renderLine(pathX.get(i - 1), pathY.get(i - 1), pathX.get(i), pathY.get(i));
      }
      renderLine(pathX.get(pathX.size() - 1), pathY.get(pathX.size() - 1), displayX, displayY);
      strokeWeight(15);
      renderPointWithLabel(displayX, displayY, msg);
      frame++;
      
      
    }
  }
  ArrayList<ApproximationPoint> points = new ArrayList<>();
    
  // Base zoom; zoom when zoomLog = 0
  // Zooming with the plus and minus button is logarithmic, the actual zoom is 10^(zoomLog)
  private final int baseZoom = 25;
  private float zoom = 25;
  private float zoomLog = 0; 
  
  // Raw unparsed differential
  private DifferentialParser parser;
  
  public GraphEngine(String differential) {
    this.parser = new DifferentialParser(differential);
  }
  
  public void updateDifferential(String differential) {
    this.parser = new DifferentialParser(differential);
  }
  
  public void insertPoint(float x, float y, float h) {
    points.add(new ApproximationPoint(x, y, h));
  }

  private void increaseZoom() {
    zoomLog += 0.01;
    zoom = baseZoom * pow(10, zoomLog);
  }
  private void decreaseZoom() {
    zoomLog -= 0.01;
    zoom = baseZoom * pow(10, zoomLog);
  }
    
  private float fitXToScreen(float x) {
    return x * zoom + width / 2;
  }
  
  private float fitYToScreen(float y) {
    return y * -zoom + height / 2; // Needs to be negative because Processing co-ordinates are mirrored; y=0 is the top of the screen
  }

  private void renderAxis() {
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
  
  public void renderSlopeField() {
    stroke(0, 0, 255, 66);
    strokeWeight(3);
    // Calculates the set of cartesian coordinates that should contain a slope field line based on the zoom __smoothly__ (not every increase and decrease in zoom will change the set, rounded to the nearest power of 5)
    int skip = ceil(pow(5, ceil(log(width / zoom / 32) / log(5))));
    int xStart = -ceil(width / 2 / zoom), xEnd = -xStart;
    int yStart = -ceil(height / 2 / zoom), yEnd = -yStart;
    
    for (int x = xStart / skip * skip; x <= xEnd; x += skip) {
      for (int y = yStart / skip * skip; y <= yEnd; y += skip) {
        float slope = parser.differential(x, y);
        if (Float.isNaN(slope)) continue;
        double theta = Math.atan(slope);
        double len = skip * 0.8;
        float xLen = (float) (Math.cos(theta) * len);
        float yLen = (float) (Math.sin(theta) * len);
        renderLine(x - xLen / 2, y - yLen / 2, x + xLen / 2, y + yLen / 2);
      }
    }
  }

  // x, y are given in cartesian coordinates, and then translated to a position on screen
  public void renderPoint(float x, float y) {
    x = fitXToScreen(x);
    y = fitYToScreen(y);
    if (x >= 0 && x <= width && y >= 0 && y <= height) {
      point(x, y);
    }
  }

  // identical to renderPoint() but with a label
  public void renderPointWithLabel(float x, float y, String msg) {
    textAlign(LEFT, BASELINE);
    x = fitXToScreen(x);
    y = fitYToScreen(y);
    
    if (x >= 0 && x <= width && y >= 0 && y <= height) {
      point(x, y);
    }
    
    float size = 12;
    textSize(size);
    text(msg, x + size, y);
  }
  
  // x1, y1, x2, and y2 are given in cartesian coordinates, and then translated to a position on screen
  public void renderLine(float x1, float y1, float x2, float y2) {  
    x1 = fitXToScreen(x1);
    y1 = fitYToScreen(y1);
    x2 = fitXToScreen(x2);
    y2 = fitYToScreen(y2);
    if ((x1 >= 0 && x1 <= width && y1 >= 0 && y1 <= height) ||
      (x2 >= 0 && x2 <= width && y2 >= 0 && y2 <= height)) {
        // Only display if it actually is on screen to prevent lag
      line(x1, y1, x2, y2);
    }
  }
  
  public void render() {
    pushMatrix();
    renderAxis();
    renderSlopeField();
    for (ApproximationPoint p: points) p.render();
    popMatrix();
  }
}
