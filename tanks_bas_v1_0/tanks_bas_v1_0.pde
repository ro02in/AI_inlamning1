// Följande kan användas som bas inför uppgiften.
// Syftet är att sammanställa alla varabelvärden i scenariet.
// Variabelnamn har satts för att försöka överensstämma med exempelkoden.
// Klassen Tank är minimal och skickas mer med som koncept(anrop/states/vektorer).

boolean left, right, up, down;
boolean mouse_pressed;

PImage tree_img;
PVector tree1_pos, tree2_pos, tree3_pos;

Tree[] allTrees   = new Tree[3];
Tank[] allTanks   = new Tank[6];

// Trees
Tree tree1, tree2, tree3;

// Team0
color team0Color;
PVector team0_tank0_startpos;
PVector team0_tank1_startpos;
PVector team0_tank2_startpos;
Tank tank0, tank1, tank2;

Team team0;

// Team1
color team1Color;
PVector team1_tank0_startpos;
PVector team1_tank1_startpos;
PVector team1_tank2_startpos;
Tank tank3, tank4, tank5;

Team team1;

int tank_size;

boolean gameOver;
boolean pause;
boolean moveWithKeys;

//======================================
void setup() 
{
  size(800, 800);
  up             = false;
  down           = false;
  mouse_pressed  = false;
  
  gameOver       = false;
  pause          = true;
  
  // Trad
  tree_img = loadImage("tree01_v2.png");
  tree1_pos = new PVector(230, 600);
  tree2_pos = new PVector(280, 230);
  tree3_pos = new PVector(530, 520);

  tree1 = new Tree(tree_img, tree1_pos);
  tree2 = new Tree(tree_img, tree2_pos);
  tree3 = new Tree(tree_img, tree3_pos);

  allTrees[0] = tree1;
  allTrees[1] = tree2;
  allTrees[2] = tree3;
  
  tank_size = 50;
  
  // Team0
  team0Color  = color(204, 50, 50);             // Base Team 0(red)
  team0_tank0_startpos  = new PVector(50, 50);
  team0_tank1_startpos  = new PVector(50, 150);
  team0_tank2_startpos  = new PVector(50, 250);

  team0 = new Team(team0Color, 0, 0, 150, 350);
  
  // Team1
  team1Color  = color(0, 150, 200);             // Base Team 1(blue)
  team1_tank0_startpos  = new PVector(width-50, height-250);
  team1_tank1_startpos  = new PVector(width-50, height-150);
  team1_tank2_startpos  = new PVector(width-50, height-50);

  team1 = new Team(team1Color, width-150, height-350, 150, 350);
  
  //tank0_startpos = new PVector(50, 50);
  tank0 = new Tank("tank0", team0_tank0_startpos,tank_size, team0 );
  tank1 = new Tank("tank1", team0_tank1_startpos,tank_size, team0 );
  tank2 = new Tank("tank2", team0_tank2_startpos,tank_size, team0 );
  
  tank3 = new Tank("tank3", team1_tank0_startpos,tank_size, team1 );
  tank4 = new Tank("tank4", team1_tank1_startpos,tank_size, team1 );
  tank5 = new Tank("tank5", team1_tank2_startpos,tank_size, team1 ); 
  
  allTanks[0] = tank0;                         // Symbol samma som index!
  allTanks[1] = tank1;
  allTanks[2] = tank2;
  allTanks[3] = tank3;
  allTanks[4] = tank4;
  allTanks[5] = tank5; 
}

void draw()
{
  background(200);

  if (!gameOver && !pause) {
  
    // SEARCH FOR ENEMIES
    searchForEnemies();

    // UPDATE LOGIC
    updateTanksLogic();
  
  }
  
  // UPDATE DISPLAY 
  team0.displayHomeBase();
  team1.displayHomeBase();
  displayTrees();
  displayTanks();
  displayMap(tank0);
  
  displayGUI();
}

//======================================
void searchForEnemies() {
  for (Tank tank : allTanks) {
    if(moveWithKeys){
      return;
    }
    if (!tank.name.equals("tank0")) // Remove to make all move around
      return;
    if (tank.state == 5)
      return;
    if (tank.isEnemyBase()) {
      if (tank.state != 5) {       // only reset path when first entering state 5
        tank.pathCalculated = false;
      }
      tank.state = 5;
      return;
    }

    if (tank.turning == 0 && canMoveForwards(tank)) {
      tank.state = 1; // Forwards
    } else {
      tank.state = 0; // Still
      tank.decideAndTurn();
    }
  }
}

//======================================
void updateTanksLogic() {
  for (Tank tank : allTanks) {
    tank.update();
  }
}

boolean canMoveForwards(Tank tank) {
  float accel = 0.1;
  float nextSpeed = tank.speed + accel;
  if (nextSpeed > tank.maxspeed) nextSpeed = tank.maxspeed;

  float nextVX = cos(tank.angle) * nextSpeed;
  float nextVY = sin(tank.angle) * nextSpeed;

  PVector nextPos = PVector.add(tank.position, new PVector(nextVX, nextVY));

  // "Spöktank"
  Sprite sprite = new Sprite();
  sprite.position = nextPos;
  sprite.diameter = tank.diameter;
  sprite.name = tank.name; // Tillagd för att förhindra "spökkollision" med faktiska tanken

  return !checkForCollisions(sprite);
}

boolean checkForCollisions(Sprite sprite) {
  for (Tank tank : allTanks) {
    if (sprite.checkForCollisions(tank))
      return true;
  }
  for (Tree tree : allTrees) {
    if (sprite.checkForCollisions(tree))
      return true;
  }
  if (sprite.checkForEnvironmentCollisions())
    return true;
  return false;
}

//====================================== 
// Följande bör ligga i klassen Tree
void displayTrees() {
  imageMode(CENTER);
  image(tree_img, tree1_pos.x, tree1_pos.y);
  image(tree_img, tree2_pos.x, tree2_pos.y);
  image(tree_img, tree3_pos.x, tree3_pos.y);
  imageMode(CORNER);
}

void displayTanks() {
  for (Tank tank : allTanks) {
    tank.display();
  }
}

void displayGUI() {
  if (pause) {
    textSize(36);
    fill(30);
    text("...Paused! (\'p\'-continues)\n(\'2\'-move with keys)\n(\'1\'-ai move)", width/1.7-100, height/2.5);
  }
  
  if (gameOver) {
    textSize(36);
    fill(30);
    text("Game Over!", width/2-100, height/2);
  }  
}

void displayMap(Tank tank) {
  tank.map.display();
}



void keyPressed(){
  if (key == 'p') {
    pause = !pause;
  }
    if (key == '1') {
    pause = false;
    moveWithKeys = false;

  }

  if(key == '2'){
    pause = false;
    moveWithKeys = true;
    tank0.state = 0;
  }

  if(!moveWithKeys){return;}

    if (key == 'w') tank0.state = 1;
    if (key == 'a') tank0.state = 4;
    if (key == 's') tank0.state = 2;
    if (key == 'd') tank0.state = 3;
}

void keyReleased(){
  if(!moveWithKeys){return;}

    if (key == 'w' || key == 's' || key == 'a' || key == 'd') {
    tank0.state = 0;
  }
}
