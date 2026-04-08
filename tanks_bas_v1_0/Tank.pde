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
  void moveForward(){
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
  
  void moveBackward(){
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
    if (stepsToNext < 0) {
      stepsToNext = int(random(3, 10));
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
    }
    
    this.position.add(velocity);
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
      
      strokeWeight(1);
      fill(230);
      rect(0+25, 0-25, 100, 40);
      fill(30);
      textSize(15);
      text(this.name +"\n( " + this.position.x + ", " + this.position.y + " )", 25+5, -5-5);
    
    popMatrix();
  }
}
