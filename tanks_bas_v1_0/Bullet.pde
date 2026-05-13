// Robin Karim, Oliwer Carpman, Rafal Galinski
class Bullet {
  PVector position;
  PVector velocity;
  float speed = 6;
  float angle;

  Bullet(float x, float y, float angle) {
    this.position = new PVector(x, y);
    this.angle = angle;
    this.velocity = new PVector(cos(angle) * speed, sin(angle) * speed);
  }

  void update() {
    position.add(velocity);
  }

  void display() {
    fill(0);
    ellipse(position.x, position.y, 5, 5);
  }
}
