class TextField {
  private boolean focus;
  private String text;
  private String filler;
  private int x, y, w, h;
  private int textSize;
  private boolean[] alphaNumeric = new boolean[256];
  private char[] operations = {'+', '-', '*', '/', '^', '(', ')'};
  
  public TextField(int x, int y, int w, int h, int textSize, String filler) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.textSize = textSize;
    this.filler = filler;
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
    for (char c: operations) alphaNumeric[c] = true;
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
  
  public void mousePressed() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      focus = true;
    } else {
      focus = false;
    }
  }
  public String getText() {
    return text;
  }
  public void render() {
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
    }
    else {
      fill(0);
      text(text, x + textSize / 4, y + textSize);
    }
  }
}
