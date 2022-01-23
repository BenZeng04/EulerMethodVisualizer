class DraggableBox {
  boolean dragging;
  int prevMouseX, prevMouseY;
  int startX = 40; int startY = 40; int width = 200; int height = 25; int textSize = 15;
  int increment = height+10; int numberOfTextBoxes = 4;
  
  public DraggableBox (int x, int y, int w, int h, int t, int i, int n) {
    dragging = false;
    startX=x; startY=y; width=w; height=h; textSize=t; increment=i+height; numberOfTextBoxes = n;
  }
  void mouseDragged() {
    if (dragging) {
      startX += mouseX - prevMouseX;
      startY += mouseY - prevMouseY;
      prevMouseX = mouseX;
      prevMouseY = mouseY;
    }
  }
  boolean mousePressed() {
    //drag window
    if (mouseX >= startX-10 && mouseX <= startX + width+20 && mouseY >= startY-10 && mouseY <= startY + height*(numberOfTextBoxes+1) + 25) {
      prevMouseX = mouseX;
      prevMouseY = mouseY;
      dragging = true;
      return true;
    }
    return false;
  }
  void mouseReleased() {
    dragging = false;
  }
  void drawBox() {
    stroke(#7E85FF, 190);
    fill(#C6C9FF, 220);
    strokeWeight(3);
    rect(startX-5, startY-5, width+10, height*(numberOfTextBoxes+1) + 15, 5);
  }
}


class TextField {
  private DraggableBox parent;
  private int row;
  
  private boolean focus;
  private String text;
  private String filler;
  public int x, y, w, h;
  public int textSize;
  private boolean[] alphaNumeric = new boolean[256];
  private char[] operations = {'+', '-', '*', '/', '^', '(', ')'};

  private void updateCoordinates() {
    if (parent != null) {
      x = parent.startX;
      y = parent.startY + row * parent.increment;
      w = parent.width;
      h = parent.height;
    }
  }
  
  public TextField() {
    text = "";
    focus = false;
    for (char c = 'a'; c <= 'z'; c++) {
      alphaNumeric[c] = true;
    }
    for (char c = 'A'; c <= 'Z'; c++) {
      alphaNumeric[c] = true;
    }
    for (char c = '0'; c <= '9'; c++) {
      alphaNumeric[c] = true;
    }
    alphaNumeric['.'] = true;
    alphaNumeric[' '] = true;
    for (char c : operations) alphaNumeric[c] = true;
  }
  
  public TextField(int x, int y, int w, int h, int textSize, String filler) {
    this();
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.textSize = textSize;
    this.filler = filler;
  }
  
  public TextField(DraggableBox parent, int row, String filler) {
    this();
    this.parent = parent;
    this.row = row;
    this.textSize = parent.textSize;
    this.filler = filler;
  }

  public void keyTyped() {
    if (focus) {
      if (key == BACKSPACE) {
        if (text.length() != 0) text = text.substring(0, text.length() - 1);
      } else if (alphaNumeric[key]) {
        text = text + Character.toString(key);
      }
    }
  }

  public boolean mousePressed() {
    updateCoordinates();
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      focus = true;
    } else {
      focus = false;
    }
    return focus;
  }
  public String getText() {
    return text;
  }
  public void render() {
    updateCoordinates();
    textAlign(LEFT, BASELINE);

    if (focus) strokeWeight(4);
    else strokeWeight(2);

    stroke(0);
    fill(255);
    textSize(textSize);
    rect(x, y, w, h);

    if (text.length() == 0 && !focus) {
      fill(100, 190);
      text(filler, x + textSize / 4, y + textSize);
    } else {
      fill(0);
      text(text, x + textSize / 4, y + textSize);
    }
  }
}
