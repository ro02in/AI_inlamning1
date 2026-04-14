class Tank extends Sprite {

  PVector velocity;
  
  PVector startpos;
  PImage img;
  color col;

  float speed;
  float angle;  // Tanks direction
  
  int state;
  boolean isInTransition;

  int turning; // -1 = turning left, 0 = not turning, 1 = turning right
  int stepsToNext = -1;

  List<Edge> path;

  //======================================
  Tank(String _name, PVector _startpos, float _size, color _col) {
    println("*** Tank.Tank()");
    this.name         = _name;
    this.diameter     = _size;
    this.col          = _col;

    this.startpos     = new PVector(_startpos.x, _startpos.y);
    this.position     = new PVector(this.startpos.x, this.startpos.y);
    this.velocity     = new PVector(0, 0);
    
    this.state        = 0; //0(still), 1(moving)
    this.speed        = 0;
    this.angle = 0;  // pointing right by default
    this.isInTransition = false;

    this.path = new ArrayList<>();
  }

  //======================================
  void moveForward(){
    speed = 3;
    println("*** Tank.moveForward()");

    if (stepsToNext < 0) {
      stepsToNext = int(random(10, 200));
    }
    if (stepsToNext == 0) {
      stepsToNext -= 1;
      decideAndTurn();
      return;
    }
    
    stepsToNext -=1 ;

    velocity.x = cos(angle) * speed;
    velocity.y = sin(angle) * speed;
  }
  
  void moveBackward(){
    println("*** Tank.moveBackward()");
    
    /* if (this.velocity.x > -this.maxspeed) {
      this.velocity.x -= 0.01;
    } else {
      this.velocity.x = -this.maxspeed;  
    } */
    speed = -3;
    velocity.x = cos(angle) * speed;
    velocity.y = sin(angle) * speed;
  }

  PVector calculateNextPos() {
    float nextVX = cos(angle) * 3;
    float nextVY = sin(angle) * 3;

    return PVector.add(position, new PVector(nextVX, nextVY));
  }

  void decideAndTurn() {
    if (stepsToNext < 0 || stepsToNext > 20) {
      stepsToNext = int(random(10, 20));
    }

    if (turning == 0) {
      turning = random(1) < 0.5 ? -1 : 1;
    }

    switch (turning) {
      case -1:
        turnLeft();
        break;
      case 1:
        turnRight();
        break;
    }

    stepsToNext -= 1;

    if (stepsToNext == 0) {
      stepsToNext -= 1;
      turning = 0;
    }
  }

  void turnLeft() {
    angle -= 0.05;  
  }

  void turnRight() {
    angle += 0.05;  
  }
  
  void stopMoving(){
    println("*** Tank.stopMoving()");
    
    // hade varit finare med animering!
    speed = 0;
    velocity.set(0, 0);
  }
  
  //======================================
  void action(String _action) {
    println("*** Tank.action()");
    
    switch (_action) {
      case "move":
        moveForward();
        break;
      case "reverse":  
        moveBackward();
        break;
      case "turnLeft":
        turnLeft();
        break;
      case "turnRight":
        turnRight();
        break;
      case "turning":
        break;
      case "stop": 
        stopMoving();
        break;
      case "followPath":
        followPath();
        break;
    }
  }
  
  //======================================
  //Här är det tänkt att agenten har möjlighet till egna val. 
  
  void update() {
    println("*** Tank.update()");
    
    switch (state) {
      case 0:
        // still/idle
        action("stop");
        break;
      case 1:
        action("move");
        break;
      case 2:
        action("reverse");
        break;
      case 3: // Turn right
        action("turnRight");
        break;
      case 4: // Turn left
        action("turnLeft");
        break;
      case 5:
        action("followPath");
        break;
    }
    
    this.position.add(velocity);
    isHomeBase();
  }

  void followPath() {
    if (path == null || path.isEmpty()) {
      stopMoving();
      state = 0;
      return;
    }

    Edge currentEdge = path.get(0);
    if (currentEdge == null || currentEdge.toPos == null) {
      path.remove(0);
      stopMoving();
      return;
    }

    speed = 3;
    PVector target = currentEdge.toPos;

    if (currentEdge.center != null) {
      // Arc edge: walk along the circle around center
      float arcAngle = atan2(position.y - currentEdge.center.y,
                             position.x - currentEdge.center.x);
      float goalAngle = atan2(target.y - currentEdge.center.y,
                              target.x - currentEdge.center.x);

      // How far left until we reach goalAngle (clockwise = negative delta)
      float remaining = goalAngle - arcAngle;
      // Normalize to (-PI, PI]
      while (remaining >  PI) remaining -= TWO_PI;
      while (remaining < -PI) remaining += TWO_PI;

      if (abs(remaining) < 0.05f) {
        // Close enough to the arc endpoint — snap and advance
        position.set(target.x, target.y);
        path.remove(0);
        velocity.set(0, 0);
        return;
      }

      // Step size in radians this frame
      float stepRad = speed / currentEdge.radius;
      // Move in the same direction as remaining, but don't overshoot
      float move = (remaining > 0) ? min(stepRad, remaining) : max(-stepRad, remaining);
      float newArcAngle = arcAngle + move;

      // Tangent to the circle at current position = movement direction
      angle = (move >= 0) ? newArcAngle + HALF_PI : newArcAngle - HALF_PI;

      float nextX = currentEdge.center.x + currentEdge.radius * cos(newArcAngle);
      float nextY = currentEdge.center.y + currentEdge.radius * sin(newArcAngle);
      velocity.x = nextX - position.x;
      velocity.y = nextY - position.y;
    } else {
      // Straight-line edge
      float dx = target.x - position.x;
      float dy = target.y - position.y;
      float dist = (float)Math.sqrt(dx * dx + dy * dy);

      if (dist < 5f) {
        path.remove(0);
        if (path.isEmpty()) {
          stopMoving();
          state = 0;
        }
        return;
      }

      angle = atan2(dy, dx);
      velocity.x = cos(angle) * speed;
      velocity.y = sin(angle) * speed;
    }
  }

  boolean isHomeBase() {

    if (this.position.x < 150 && this.position.y < 350){
      println("i AM HOME");
      return true;
    } else return false;

  }

  boolean isEnemyBase() {
    println("isEnemyBase metohd");
  if (position.x > width - 150 && position.y > height - 350) {
    println("ENEMY BASE FOUND!!!!!!!!!!!!!!!!!!!!!!!!!");
    return true;
  }

  return false;
}
  
  //======================================
  void drawTank(float x, float y) {
    fill(this.col, 50);

    ellipse(x, y, 50, 50);
    strokeWeight(1);
    line(x, y, x+25, y);
    
    //kanontornet
    ellipse(0, 0, 25, 25);
    strokeWeight(3);
    float cannon_length = this.diameter/2;
    line(0, 0, cannon_length, 0);
  }
  
  void display() {
    fill(this.col);
    strokeWeight(1);
    
    pushMatrix();
    
      translate(this.position.x, this.position.y);
      rotate(angle);  //shows rotation visually

      imageMode(CENTER);
      drawTank(0, 0);
      imageMode(CORNER);
      popMatrix();
      
      strokeWeight(1);
      fill(230);
      float hudX = this.position.x + 25;
      float hudY = this.position.y - 25;
      rect(hudX, hudY, 100, 40);
      fill(30);
      textSize(15);
      String posText = String.format(Locale.US, "(%.2f, %.2f)", this.position.x, this.position.y);
      //text(this.name +"\n( " + this.position.x + ", " + this.position.y + " )", this.position.x+25+5, this.position.y-5-5);
      text(this.name + "\n" + posText, hudX + 5, hudY + 20);
  }

}
