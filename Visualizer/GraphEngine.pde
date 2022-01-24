class GraphEngine {
  double centerX = 0, centerY = 0;
  // ApproximationPoints are (x, y) values you can "add" to the graph that will constantly move according to Euler's Method.
  class ApproximationPoint {
    private color trail;
    private ArrayList<Double> pathX, pathY;
    private double prevX, prevY;
    private double x, y;
    private double h;
    private final double baseStep = 0.01; // A "base-step" is used so that large values of h will not cause points to go extremely fast, and instead have animated movement in a straight line per step
    private long frame;
    public ApproximationPoint(double x0, double y0, double h) {
      this.x = this.prevX = x0;
      this.y = this.prevY = y0;
      trail = color(random(255), random(255), random(255));
      pathX = new ArrayList<Double>();
      pathY = new ArrayList<Double>();
      pathX.add(x0);
      pathY.add(y0);
      // Round the step up to the nearest baseStep (used for animations)
      
      if (h > 0) {
        long roundedQuotient = (long) Math.round(h / baseStep);
        this.h = roundedQuotient * baseStep;
      } else {
        // Round down if negative
        long roundedQuotient = (long) Math.round(h / baseStep);
        this.h = roundedQuotient * baseStep;
      }
      if (this.h == 0) this.h = baseStep;
    }
    public void render() {
      double displayX, displayY;
      // Euler's Method
      // Modulo is used so that the Point only follows a step in Euler's method every (h / baseStep) frames; this causes all points added to move with the same x-velocity.
      if (frame % (long) (h / baseStep) == 0) {
        prevX = x;
        prevY = y;
        pathX.add(x);
        pathY.add(y);
        displayX = x;
        displayY = y;
        double dydx = parser.differential(x, y);
        if (!Double.isNaN(dydx)) {
          y = y + h * dydx;
          x += h;
        }
      } else {
        // Instead of teleporting to the next Point per iteration of Euler's method, points will travel a straight line from (x1, y1) to (x2, y2)
        double progress = (frame % (long) (h / baseStep)) / (h / baseStep);
        if (progress < 0) progress *= -1;
        progress = Math.pow(progress, 0.5); // The progress is rooted such that the animation is non-linear and more realistically "snaps" to the next point
        displayX = prevX + (x - prevX) * progress;
        displayY = prevY + (y - prevY) * progress;
      }
      // Label is given showcasing (x, y), rounded to the nearest 100th
      // Note that it showcases (x, y) as per Euler's method iterations and not the animated progress
      String msg = "(" + String.format("%.2f", x)  + ", " + String.format("%.2f", y) + ")";

      double slope = parser.differential(prevX, prevY);
      fill(trail, 230);
      stroke(trail, 200);
      if (!Double.isNaN(slope)) {
        double theta = Math.atan(slope);
        double len = width / zoom / 32 * 1.4;
        double xLen = (double) (Math.cos(theta) * len);
        double yLen = (double) (Math.sin(theta) * len);

        strokeWeight(5);
        renderLine(displayX - xLen / 2, displayY - yLen / 2, displayX + xLen / 2, displayY + yLen / 2);
      }
      strokeWeight(3);
      final long maxPathLength = 20;
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
  private final long baseZoom = 25;
  private double zoom = 25;
  private double zoomLog = 0;

  // Raw unparsed differential
  private DifferentialParser parser;

  private void increaseZoom() {
    zoomLog += 0.01;
    zoom = baseZoom * Math.pow(10, zoomLog);
  }
  private void decreaseZoom() {
    zoomLog -= 0.01;
    zoom = baseZoom * Math.pow(10, zoomLog);
  }
  
  // Maps a Point on the Processing window (screenX, screenY) to cartesian co-ordinates on the graph
  private double fitScreenToX(double screenX) {
    return (screenX - width / 2) / zoom + centerX;
  }
  
  private double fitScreenToY(double screenY) {
    return (screenY - height / 2) / -zoom + centerY;
  }

  // Maps cartesian co-ordinates (x, y) on the graph to a Point on the Processing window
  private double fitXToScreen(double x) {
    return (x - centerX) * zoom + width / 2;
  }

  private double fitYToScreen(double y) {
    return (y - centerY) * -zoom + height / 2; // Needs to be negative because Processing co-ordinates are mirrored; y=0 is the top of the screen
  }

  private void renderAxis() {
    background(255);
    stroke(0);
    strokeWeight(2);
    line(0, (float) fitYToScreen(0), width, (float) fitYToScreen(0));
    line((float) fitXToScreen(0), 0, (float) fitXToScreen(0), height);
    textAlign(LEFT, BASELINE);
    long skip = (long) Math.ceil(Math.pow(10, Math.ceil(Math.log(width / zoom / 64) / log(10)))); // Only draw grid line markers every _skip_ coordinates (this skip will always be a power of 10 based on the zoom)
    long xStart = (long) fitScreenToX(0), xEnd = (long) fitScreenToX(width);
    for (long i = xStart / skip * skip; i <= xEnd; i += skip) {
      if (i == 0) continue; // Don't draw at (x = 0), that's the y-axis
      if (i % (skip * 5) == 0) { // Draw thicker grid line markers every 5 'regular' lines
        strokeWeight(1);
        stroke(0, 175);
        float x = (float) fitXToScreen(i);
        line(x, 0, x, height);
        fill(0);
        final long size = 12;
        textSize(size);
        // Labels on the x-axis
        text("" + i, x + size / 4, (float) fitYToScreen(0) + size);
      } else {
        strokeWeight(0.5);
        stroke(0, 80);
        float x = (float) fitXToScreen(i);
        line(x, 0, x, height);
      }
    }

    long yStart = (long) fitScreenToY(height), yEnd = (long) fitScreenToY(0);
    for (long i = yStart / skip * skip; i <= yEnd; i += skip) {
      if (i == 0) continue;
      if (i % (skip * 5) == 0) {
        strokeWeight(1);
        stroke(0, 175);
        float y = (float) fitYToScreen(i);
        line(0, y, width, y);
        fill(0);
        final long size = 12;
        textSize(size);
        text("" + i, (float) fitXToScreen(0) + size / 4, y + size);
      } else {
        strokeWeight(0.5);
        stroke(0, 80);
        float y = (float) fitYToScreen(i);
        line(0, y, width, y);
      }
    }

    // Drawing the zero label at (0, 0)
    fill(0);
    final long size = 12;
    textSize(size);
    text(0, (float) fitXToScreen(0) + size / 4, (float) fitYToScreen(0) + size);
  }

  private void renderSlopeField() {
    stroke(0, 0, 255, 66);
    strokeWeight(3);
    // Calculates the set of cartesian coordinates that should contain a slope field line based on the zoom __smoothly__ (not every increase and decrease in zoom will change the set, rounded to the nearest power of 5)
    long skip = (long) Math.ceil(Math.pow(2, Math.ceil(Math.log(width / zoom / 32) / log(2))));
    long xStart = (long) fitScreenToX(0), xEnd = (long) fitScreenToX(width);
    long yStart = (long) fitScreenToY(height), yEnd = (long) fitScreenToY(0);

    // Displays a slope field line at every (x, y) visible on the screen such that x and y are multiples of _skip_
    for (long x = xStart / skip * skip; x <= xEnd; x += skip) {
      for (long y = yStart / skip * skip; y <= yEnd; y += skip) {
        double slope = parser.differential(x, y);
        if (Double.isNaN(slope)) continue;
        double theta = Math.atan(slope);
        double len = skip * 0.8;
        double xLen = (double) (Math.cos(theta) * len);
        double yLen = (double) (Math.sin(theta) * len);
        renderLine(x - xLen / 2, y - yLen / 2, x + xLen / 2, y + yLen / 2);
      }
    }
  }

  // x, y are given in cartesian coordinates, and then translated to a position on screen
  private void renderPoint(double x, double y) {
    x = fitXToScreen(x);
    y = fitYToScreen(y);
    if (x >= 0 && x <= width && y >= 0 && y <= height) {
      point((float) x, (float) y);
    }
  }

  // identical to renderPoint() but with a label
  private void renderPointWithLabel(double x, double y, String msg) {
    textAlign(LEFT, BASELINE);
    x = fitXToScreen(x);
    y = fitYToScreen(y);

    if (x >= 0 && x <= width && y >= 0 && y <= height) {
      point((float) x, (float) y);
    }

    float size = 12;
    textSize(size);
    text(msg, (float) x + size, (float) y);
  }

  // x1, y1, x2, and y2 are given in cartesian coordinates, and then translated to a position on screen
  private void renderLine(double x1, double y1, double x2, double y2) {
    x1 = fitXToScreen(x1);
    y1 = fitYToScreen(y1);
    x2 = fitXToScreen(x2);
    y2 = fitYToScreen(y2);
    if ((x1 >= 0 && x1 <= width && y1 >= 0 && y1 <= height) ||
      (x2 >= 0 && x2 <= width && y2 >= 0 && y2 <= height)) {
      // Only display if it actually is on screen to prevent lag
      line((float) x1, (float) y1, (float) x2, (float) y2);
    }
  }
  
  public GraphEngine(String differential) {
    this.parser = new DifferentialParser(differential);
  }

  public void updateDifferential(String differential) {
    this.parser = new DifferentialParser(differential);
  }

  public void insertPoint(double x, double y, double h) {
    points.add(new ApproximationPoint(x, y, h));
  }

  public void removeAllPoints() {
    points.clear();
  }

  public void render() {
    pushMatrix();
    renderAxis();
    renderSlopeField();
    for (ApproximationPoint p : points) p.render();
    popMatrix();
  }
  
  public double getCenterX() {
    return centerX;
  }
  
  public double getCenterY() {
    return centerY;
  }
  
  public void setCenterX(double x) {
    centerX = x;
  }
  
  public void setCenterY(double y) {
    centerY = y;
  }
}
