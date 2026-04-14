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
  
    fill(teamColor, 15);    // Base Team 0(red)
/*     rect(0, 0, 150, 350);
    
    fill(team1Color, 15);    // Base Team 1(blue) 
    rect(width - 151, height - 351, 150, 350); */
    rect(baseX, baseY, baseW, baseH);
  }

  void display() {
    displayHomeBase();
  }
}

