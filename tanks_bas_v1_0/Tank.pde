import java.util.*;

class Tank extends Sprite {

  PVector acceleration;
  PVector velocity;

  PVector startpos;
  PImage img;
  color col;

  float speed;
  float maxspeed;
  float angle;  // Tanks direction

  int state;
  boolean isInTransition;

  ArrayList<Node> astarPath = null;
  int pathIndex = 0;
  boolean pathCalculated = false;

  int turning; // -1 = turning left, 0 = not turning, 1 = turning right
  int stepsToNext = -1;

  //======================================
  Tank(String _name, PVector _startpos, float _size, color _col ) {
    println("*** Tank.Tank()");
    this.name         = _name;
    this.diameter     = _size;
    this.col          = _col;

    this.startpos     = new PVector(_startpos.x, _startpos.y);
    this.position     = new PVector(this.startpos.x, this.startpos.y);
    this.velocity     = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);

    this.state        = 0; //0(still), 1(moving)
    this.speed        = 0;
    this.maxspeed     = 3;
    this.angle = 0;  // pointing right by default
    this.isInTransition = false;
  }

  //======================================
  void moveForward() {
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

    float accel = 0.1;
    speed += accel;
    if (speed > maxspeed) speed = maxspeed;
    velocity.x = cos(angle) * speed;
    velocity.y = sin(angle) * speed;
  }

  void moveBackward() {
    println("*** Tank.moveBackward()");

    /* if (this.velocity.x > -this.maxspeed) {
     this.velocity.x -= 0.01;
     } else {
     this.velocity.x = -this.maxspeed;
     } */
    float accel = 0.1;
    speed -= accel;
    if (speed < -maxspeed) speed = -maxspeed;
    velocity.x = cos(angle) * speed;
    velocity.y = sin(angle) * speed;
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

  void stopMoving() {
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
    case "goBackToBaseAStar":
      goBackToBaseAStar();
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
      action("goBackToBaseAStar");
      break;
    }

    this.position.add(velocity);
    isHomeBase();
  }


  void goBackToBaseAStar() {
    int gridSize = 20;

    if (!pathCalculated) {
      Node start = new Node(int(position.x / gridSize), int(position.y / gridSize));
      Node goal  = new Node(int(75  / gridSize), int(175 / gridSize));

      ArrayList<PVector> obstacles = new ArrayList<PVector>();
      obstacles.add(tree1_pos);
      obstacles.add(tree2_pos);
      obstacles.add(tree3_pos);

      AStar astar = new AStar(obstacles, gridSize);
      astarPath = astar.findPath(start, goal);
      pathCalculated = true;
      pathIndex = 0;
    }

    if (astarPath == null) {
      println("No path found");
      return;
    }
    println("Path found");

    if (astarPath == null) return;

    if (pathIndex < astarPath.size()) {
      Node target = astarPath.get(pathIndex);
      float targetX = target.x * gridSize + gridSize / 2.0;
      float targetY = target.y * gridSize + gridSize / 2.0;

      float dx = targetX - position.x;
      float dy = targetY - position.y;
      float dist = sqrt(dx * dx + dy * dy);

      if (dist < 5) {
        pathIndex++;
      } else {
        angle = atan2(dy, dx);
        speed += 0.1;
        if (speed > maxspeed) speed = maxspeed;
        velocity.x = cos(angle) * speed;
        velocity.y = sin(angle) * speed;
      }
    } else {
      stopMoving();
      state = 0;
      pathCalculated = false;
    }
  }

  boolean isHomeBase() {

    if (this.position.x < 150 && this.position.y < 350) {
      println("i AM HOMW");
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

class Node {
  int x, y;
  float g, h, f;
  Node parent;

  Node(int x, int y) {
    this.x = x;
    this.y = y;
    this.g = 0;
    this.h = 0;
    this.f = 0;
    this.parent = null;
  }
}
