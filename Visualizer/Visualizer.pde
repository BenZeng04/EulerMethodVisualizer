GraphEngine graph;

void setup() {
  size(800, 500);
  graph = new GraphEngine(this);
}

void draw() {
  graph.render();
}
