// Robin Karim, Oliwer Carpman, Rafal Galinski
class Tank extends Sprite {

  PVector acceleration;
  PVector velocity;

  PVector startpos;
  PImage img;
  color col;
  Team team;

  float speed;
  float maxspeed;
  float angle;  // Tanks direction
  int shootCooldown = 0;
  int Abullets = 3;
  int health;

  int state;
  boolean isInTransition;
  Tank[] enemyTanks = new Tank[3];

  ArrayList<Node> astarPath = null;
  int pathIndex = 0;
  boolean pathCalculated = false;

  int turning; // -1 = turning left, 0 = not turning, 1 = turning right
  int stepsToNext = -1; // steps until next turn

  int stepsFromLastGpsReading = 0; // Tanks read gps whenever in their home base (or later manual reading) and will get more lost the longer since last reading.
  int inCombatSince = 0; // Used to determine when to give up on combat and try to keep moving.
  PVector positionTarget = null;
  int aStarCooldown = 0; // Cooldown to prevent A* from being called every frame when stuck

  Map map;
  Radio radio;

  //======================================
  Tank(String _name, PVector _startpos, float _size, color _col, Team _team ) {
    this.name         = _name;
    this.diameter     = _size;
    this.col          = _col;
    this.team          = _team;


    this.startpos     = new PVector(_startpos.x, _startpos.y);
    this.position     = new PVector(this.startpos.x, this.startpos.y);
    this.velocity     = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);

    this.state        = 0; //0(still), 1(moving)
    this.speed        = 0;
    this.maxspeed     = 3;
    this.health       = 3; // 3 liv, på liv 1 är damaged (moves half speed, not implemented), på liv 0 är den död
    this.angle = 0;  // pointing right by default
    this.isInTransition = false;
    this.map = new Map(20);
    this.radio = new Radio(this);

    map.addToMap(startpos.x, startpos.y, ObstacleType.NONE, diameter/2);
  }

  //======================================
  void moveForward() {

    if (!moveWithKeys) {
      if (stepsToNext < 0) stepsToNext = int(random(40, 100));
      stepsToNext--;
      if (stepsToNext <= 0) {
        turning = (random(1) < 0.5) ? -1 : 1;
        state = (turning == -1) ? 4 : 3;
        stepsToNext = int(random(10, 30));
        return;
      }
      stepsToNext -=1;
    }

    if (isHomeBase()) {
      stepsFromLastGpsReading = 0;
    } else {
      stepsFromLastGpsReading++;
    }

    float accel = 0.1;
    speed += accel;
    if (speed > maxspeed) speed = maxspeed;
    velocity.x = cos(angle) * speed;
    velocity.y = sin(angle) * speed;
  }

  void moveBackward() {
    if (isHomeBase()) {
      stepsFromLastGpsReading = 0;
    } else {
      stepsFromLastGpsReading++;
    }

    float accel = 0.1;
    speed -= accel;
    if (speed < -maxspeed) speed = -maxspeed;
    velocity.x = cos(angle) * speed;
    velocity.y = sin(angle) * speed;
  }

  /**
  * Look at the space ahead of the tank in a triangular pattern (meant to replicate field of view)
  * Adds the seen space into this tank's map - marking obstacles etc.
  * When an obstacle is seen, the tank slows down slightly and might turn to avoid the obstacle.
  * For example, a tree seen on the left side of the tanks FOV will make it turn right.
  */
  void lookAhead() {
    float lookAngle = angle - 0.5;
    boolean obstacleDetected = false;
    Integer[] rayBlocked = new Integer[5];
    for (int i = 0; i < 5; i++) {
      for (int j = 1; j < 7; j++) {
        float x = position.x + cos(lookAngle) * j * 20;
        float y = position.y + sin(lookAngle) * j * 20;
        if (x < 0 || x > width || y < 0 || y > height) {
          rayBlocked[i] = j;
          break;
        }
        ObstacleType obstacleType = checkForObstacles(x, y);
        Boolean addedObstacle = map.addToMap(x, y, obstacleType, diameter/2);
        if (addedObstacle == null) {
          rayBlocked[i] = j;
        }
        if (obstacleType != ObstacleType.NONE) {
          rayBlocked[i] = j;
          if (addedObstacle != null && addedObstacle)
            radio.reportRadio(new PVector(x, y), obstacleType, stepsFromLastGpsReading, team);
            obstacleDetected = true;
          break;
        }
      }
      lookAngle += 0.25;
    }

    if (state == -1) return; // Keep standing dead if dead
    if (state == 0) return; // Keep standing still if still
    if (state == 5 || state == 6) {
      if (obstacleDetected)
        pathCalculated = false; // Might need to find a new path upon a newly detected obstacle
      return;
    }
    if (moveWithKeys) return;


    // If committed to a turn, keep going until done
    if (turning != 0) {
      stepsToNext--;
      speed -= 0.03;
      if (speed < 0) speed = 0;
      if (stepsToNext <= 0) {
        if (canMoveForwards()) {
          turning = 0;
          stepsToNext = int(random(20, 50));
        }
      }
      return;
    }

    // Center is clear -> go straight
    if (rayBlocked[1] == null && rayBlocked[2] == null && rayBlocked[3] == null) {
      state = 1;
      return;
    }

    speed -= 0.15; // Slow down if obstacle
    if (speed < 0) speed = 0;

    int left = (rayBlocked[0] != null) ? rayBlocked[0] : 5;
    int right = (rayBlocked[4] != null) ? rayBlocked[4] : 5;
    boolean leftOpen = (left == 5);
    boolean rightOpen = (right == 5);

    // Both blocked close, reverse. Note: this doesn't work at the moment but the problem is not yet identified.
    if (left < 2 && right < 2) {
      if (canMoveBackwards()) {
        state = 2;
        return;
      }
    }

    // Pick a direction and commit to it
    if (leftOpen && !rightOpen) turning = -1;
    else if (rightOpen && !leftOpen) turning = 1;
    else if (left > right) turning = -1;
    else if (right > left) turning = 1;
    else turning = (random(1) < 0.5) ? -1 : 1;

    state = (turning == -1) ? 4 : 3;
    stepsToNext = int(random(10, 30));
  }

  // Checks if this tank can move forwards
  boolean canMoveForwards() {
    if (this.state == -1) return false;

    float accel = 0.1;
    float nextSpeed = speed + accel;
    if (nextSpeed > maxspeed) nextSpeed = maxspeed;
  
    float nextVX = cos(angle) * nextSpeed;
    float nextVY = sin(angle) * nextSpeed;
  
    PVector nextPos = PVector.add(position, new PVector(nextVX, nextVY));
  
    // "Spöktank"
    Sprite sprite = new Sprite();
    sprite.position = nextPos;
    sprite.diameter = diameter;
    sprite.name = name; // Tillagd för att förhindra "spökkollision" med faktiska tanken
  
    return !sprite.checkForGlobalCollisions();
  }

  // Checks if this tank can move backwards
  boolean canMoveBackwards() {
    float accel = 0.1;
    float nextSpeed = speed - accel;
    if (nextSpeed < -maxspeed) nextSpeed = -maxspeed;

    float nextVX = cos(angle) * nextSpeed;
    float nextVY = sin(angle) * nextSpeed;

    PVector nextPos = PVector.add(position, new PVector(nextVX, nextVY));
  
    // "Spöktank"
    Sprite sprite = new Sprite();
    sprite.position = nextPos;
    sprite.diameter = diameter;
    sprite.name = name; // Tillagd för att förhindra "spökkollision" med faktiska tanken
  
    return !sprite.checkForGlobalCollisions();
  }

  // Checks if this tank can move with the current velocity
  boolean canMove(PVector vel) {
    PVector nextPos = PVector.add(position, vel);
    Sprite sprite = new Sprite();
    sprite.position = nextPos;
    sprite.diameter = diameter;
    sprite.name = name;
    return !sprite.checkForGlobalCollisions();
  }

  boolean isAStarObstacleCell(int gx, int gy, boolean allowUnseen) {
    if (gx < 0 || gy < 0 || gx >= map.cols || gy >= map.rows) return true;
    Cell c = map.grid[gx][gy];
    if (c == null) return !allowUnseen;
    return c.obstacleType != ObstacleType.NONE;
  }

  Node nearestNonObstacleTo(Node desiredGoal, boolean allowUnseen) {
    if (desiredGoal == null) return null;

    int gx = constrain(desiredGoal.x, 0, map.cols - 1);
    int gy = constrain(desiredGoal.y, 0, map.rows - 1);

    if (!isAStarObstacleCell(gx, gy, allowUnseen)) return new Node(gx, gy);

    int maxR = 15;
    for (int r = 1; r <= maxR; r++) {
      for (int dx = -r; dx <= r; dx++) {
        for (int dy = -r; dy <= r; dy++) {
          if (abs(dx) != r && abs(dy) != r) continue; // only check ring
          int nx = gx + dx;
          int ny = gy + dy;
          if (!isAStarObstacleCell(nx, ny, allowUnseen)) {
            return new Node(nx, ny);
          }
        }
      }
    }

    return new Node(gx, gy);
  }

  // Check for obstacles at a position
  ObstacleType checkForObstacles(float x, float y) {
    for (Tree tree : allTrees) {
      if (tree.checkForCollisions(new PVector(x, y))) {
        return ObstacleType.TREE;
      }
    }

    for (Tank tank : allTanks) {
      if (tank == null) continue;
      if (tank.name == this.name) continue;
      if (tank.checkForCollisions(new PVector(x, y))) {
        if (tank.state == -1) {
          return ObstacleType.DEAD_TANK;
        }
        if (tank.team == this.team) {
          return ObstacleType.FRIENDLY_TANK;
        } else {
          if (state != 5 && Abullets != 0){
            shootEnemy(tank);
          }
          return ObstacleType.ENEMY_TANK;
        }
      }
    }
    return ObstacleType.NONE;
  }

  void shootEnemy(Tank target){
    inCombatSince = 10;

    float dx = target.position.x - this.position.x;
    float dy = target.position.y - this.position.y;
    float targetAngle = atan2(dy, dx);
    float angleDiff = targetAngle - angle;
    angleDiff = atan2(sin(angleDiff), cos(angleDiff));

    if (angleDiff >= 0.3) {
      state = 3;
    } else if (angleDiff <= -0.3) {
      state = 4;
    } else if (0.3 > angleDiff && -0.3 < angleDiff ){
      state = 1;
      shoot();

    }

  }

  void shoot() {
    if (shootCooldown > 0) return;
    if (Abullets <= 0) {
      if (aStarCooldown == 0) {
        state = 5;
        pathCalculated = false;
      }
      return;
    }

    float cannonLength = diameter/2;

    float bx = position.x + cos(angle) * cannonLength;
    float by = position.y + sin(angle) * cannonLength;

    bullets.add(new Bullet(bx, by, angle));
    Abullets -= 1;
    shootCooldown = 100;
  }


  // Decide where to turn if stepstonext is at 0. Then/otherwise turn in the current direction.
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
    velocity.x = cos(angle) * speed;
    velocity.y = sin(angle) * speed;
  }

  void turnRight() {
    angle += 0.05;
    velocity.x = cos(angle) * speed;
    velocity.y = sin(angle) * speed;
  }

  void stopMoving() {

    // hade varit finare med animering!
    speed = 0;
    velocity.set(0, 0);
  }

  void hit() {
    if (this.state == -1) return;

    health--;
    maxspeed = health; // Loses speed with hits
    if (speed > maxspeed) speed = maxspeed;
    // Loses color with hits
    float t = health / 3.0;
    this.col = color(
      red(col) * (0.1 + 0.9 * t),
      green(col) * (0.1 + 0.9 * t),
      blue(col) * (0.1 + 0.9 * t)
    );

    println(name + " hit! HP: " + health);

    if (health <= 0) {
      health = 0;
      state = -1; // DEAD State

      println(name + " destroyed!");
    }
  }
  //======================================
  void action(String _action) {
    if (state != -1) {
      lookAhead();
    }

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
      break;
    case "goToPositionAStar":
      goToPositionAStar();
      break;
    }
  }

  //======================================

  void update() {
    // DEAD STATE
    if (state == -1) {
      stopMoving();
      return;
    }

    if (isHomeBase()) {
      Abullets = 3;
      if (state == 0 || state == 5) state = 1;
    }

    if (shootCooldown > 0) shootCooldown--;
    if (aStarCooldown > 0) aStarCooldown--;
    if (radio.cooldown > 0) radio.cooldown--;
    if (inCombatSince > 0) {
      inCombatSince--;
      if (inCombatSince == 0) {
        println(name + " gives up combat.");
        if(state != 5) state = 1; // Give up combat and try to keep moving
      }
    } else {
      if (Abullets == 1 && aStarCooldown == 0) {
        beginGoToPositionAStar(startpos); // Only one bullet left and not in combat, go home (use state 6 which cancels on new threats)
      }
    }

    if (Abullets == 0 && aStarCooldown == 0) {
      state = 5;
      pathCalculated = false;
    }

    switch (state) {
    case -1:
      action("dead");
      return;
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
    case 6:
      action("goToPositionAStar");
      break;
    }

    if (!canMove(velocity)) {
      stopMoving();
      if (state == 5 || state == 6) {
        aStarCooldown = 10; // Wait a bit before trying to recalculate path to avoid doing it every frame when stuck
        state = 1; // Revert to random movement if stuck, will try A* again in a few frames
      }
    }

    this.position.add(velocity);
  }

  void beginGoToPositionAStar(PVector target) {
    if (state == -1) return; // Don't do anything if dead
    this.positionTarget = target;
    this.state = 6;
    this.pathCalculated = false;
  }

  /**
  * Calculates and follows a path to a target position using A* algorithm.
  * If a path is already calculated, trace the path towards the target position.
  * See goBackToBaseAStar for more details and fallback behavior if no path can be found with the current map.
  */
  void goToPositionAStar() {
    int gridSize = map.cellSize;

    if (!pathCalculated) {
      Node start = new Node(int(position.x / gridSize), int(position.y / gridSize));

      Node desiredGoal = new Node(int(positionTarget.x / gridSize), int(positionTarget.y / gridSize));

      AStar astar = new AStar(map, gridSize);
      Node goal = nearestNonObstacleTo(desiredGoal, false);
      astarPath = astar.findPath(start, goal, false);
      if (astarPath == null) {
        goal = nearestNonObstacleTo(desiredGoal, true);
        astarPath = astar.findPath(start, goal, true); // fallback to include unseen places on the map
      }

      if (astarPath == null) {
        println("Ingen väg hittad för tank " + name + " — tanken fortsätter åka slumpmässigt.");
        state = 1; // No path found, give up and just move randomly
      } else {
        println("Väg hittad för tank " + name + ", antal steg: " + astarPath.size());
        pathCalculated = true;
        pathIndex = 1; // Start at second node in path to prevent jittering backwards
      }
    }

    if (astarPath == null) {

      float targetX = startpos.x;
      float targetY = startpos.y;
      float dx = targetX - position.x;
      float dy = targetY - position.y;
      float dist = sqrt(dx * dx + dy * dy);
      if (dist > 5) {
        angle = atan2(dy, dx);
        speed += 0.1;
        if (speed > maxspeed) speed = maxspeed;
        velocity.x = cos(angle) * speed;
        velocity.y = sin(angle) * speed;
      } else {
        stopMoving();
        state = 1;
      }
      return;
    }

    if (pathIndex < astarPath.size()) {
      Node target  = astarPath.get(pathIndex);
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
      state = 1;
      pathCalculated = false;
    }
  }

  /**
  * Called when needing to reload or when the current calculated path is blocked.
  * Calculates a path to this tanks starting position using A* over all seen positions on the tanks map.
  * If a path is already calculated, trace the path back towards the home base.
  * If no path can be found with the current map, a path is instead calculated including unseen spaces on the map
  * but keeping all obstacles marked from the current map.
  * If no path can be found then - the game does the only sensible thing and crashes.
  */
  void goBackToBaseAStar() {
    int gridSize = map.cellSize;

    if (!pathCalculated) {
      Node start = new Node(int(position.x / gridSize), int(position.y / gridSize));

      Node desiredGoal = new Node(int(startpos.x / gridSize), int(startpos.y / gridSize));

      AStar astar = new AStar(map, gridSize);
      Node goal = nearestNonObstacleTo(desiredGoal, false);
      astarPath = astar.findPath(start, goal, false);
      if (astarPath == null) {
        goal = nearestNonObstacleTo(desiredGoal, true);
        astarPath = astar.findPath(start, goal, true); // fallback to include unseen places on the map
      }

      if (astarPath == null) {
        println("Ingen väg hittad för tank " + name + " - tanken fortsätter åka slumpmässigt.");
        state = 1; // No path found, give up and just move randomly
      } else {
        println("Väg hittad för tank " + name + ", antal steg: " + astarPath.size());
        pathCalculated = true;
        pathIndex = 1; // Start at second node in path to prevent jittering backwards
      }
    }

    if (astarPath == null) {

      float targetX = startpos.x;
      float targetY = startpos.y;
      float dx = targetX - position.x;
      float dy = targetY - position.y;
      float dist = sqrt(dx * dx + dy * dy);
      if (dist > 5) {
        angle = atan2(dy, dx);
        speed += 0.1;
        if (speed > maxspeed) speed = maxspeed;
        velocity.x = cos(angle) * speed;
        velocity.y = sin(angle) * speed;
      } else {
        stopMoving();
        state = 1;
      }
      return;
    }

    if (pathIndex < astarPath.size()) {
      Node target  = astarPath.get(pathIndex);
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
      state = 1;
      pathCalculated = false;
    }
  }

  // Checks if the tank is in the enemy base
  boolean isEnemyBase() {
    if (team == team0) {
      if (position.x > width - 150 && position.y > height - 350) {
        return true;
      }
    } else if (team == team1) {
      if (position.x < 150 && position.y < 350) {
        return true;
      }
    }

    return false;
  }

  // Checks if the tank is in the home base
  boolean isHomeBase() {
    if (team == team0) {
      if (position.x < 150 && position.y < 350) {
        return true;
      }
    } else if (team == team1) {
      if (position.x > width - 150 && position.y > height - 350) {
        return true;
      }
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

  void drawAstarPath() {
    if (astarPath == null) return;
    pushStyle();
    stroke(0, 0, 255);  //blå
    strokeWeight(1);
    noFill();

    for (int i = pathIndex; i < astarPath.size(); i++) {
      Node n = astarPath.get(i);
      float x = n.x * map.cellSize + map.cellSize/2;
      float y = n.y * map.cellSize + map.cellSize/2;
      ellipse(x, y, 5, 5);
    }
    popStyle();
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
    text(this.name + "  HP: " + this.health + " B: " + this.Abullets + "\n" + posText, hudX + 5, hudY + 20);
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
