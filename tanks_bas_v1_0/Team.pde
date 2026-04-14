class Team {  
  color teamColor;
  float baseX, baseY, baseW, baseH;

  Team(color col, float x, float y, float w, float h) {
    this.teamColor = col;
    this.baseX = x;
    this.baseY = y;
    this.baseW = w;
    this.baseH = h;
  }
  // Används inte, men bör ligga här. 
  void displayHomeBase() {
    strokeWeight(1);
    fill(teamColor, 15);
    rect(baseX, baseY, baseW, baseH);
  }

  color getColor() {
    return teamColor;
  }
  boolean isInsideBase(PVector pos) {
    return pos.x > baseX &&
          pos.x < baseX + baseW &&
          pos.y > baseY &&
          pos.y < baseY + baseH;
  }

  void display() {
    displayHomeBase();
  }
}

