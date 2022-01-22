class DifferentialParser {
  private String differential;
  
  public DifferentialParser(String toParse) {
    // Current parser valid args: "3*x^4+2*y^1
    differential = toParse.toLowerCase();
  }
  
  // Returns dy/dx at (x, y) given the string 
  // Uses the exp4j API, at https://www.objecthunter.net/exp4j/#Introduction
  public float differential(float x, float y) {
    try {
      Expression e = new ExpressionBuilder(differential)
                .variables("x", "y")
                .build()
                .setVariable("x", x)
                .setVariable("y", y);
      return (float) e.evaluate();
    } catch (Exception exp) {
      return Float.NaN;
    }
  }
}
