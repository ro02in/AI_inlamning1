public class Sprite {
  PVector position;
  float   diameter;
  String  name;

  PVector getPosition() {
    return position;
  }
  float getDiameter() {
    return diameter;
  }

  boolean checkForEnvironmentCollisions() {
    if (checkEnvironment())
      return true;
    return false;
  }

  boolean checkEnvironment() {
    return borders();
  }

  boolean checkForCollisions(Sprite sprite) {
    if (sprite.equals(this) || sprite.name.equals(this.name))
      return false;
    PVector othPos = sprite.getPosition();
    float othR = sprite.getDiameter()/2;
    float r = diameter/2;
    float xDistance = position.x - othPos.x;
    float yDistance = position.y - othPos.y;
    float distancePythagoras = (float)Math.sqrt((xDistance * xDistance) + (yDistance * yDistance));
    if (distancePythagoras < othR + r)
      return true;
    return false;
  }

  boolean checkForCollisions(PVector position) {
    float r = diameter/2;
    if (
        this.position.x < position.x + r &&
        this.position.x > position.x - r &&
        this.position.y < position.y + r &&
        this.position.y > position.y - r
      ) return true;
    return false;
  }
  
  boolean borders() {
    float r = diameter/2;
    if (position.x < r) return true;
    if (position.y < r) return true;
    if (position.x > width-r) return true;
    if (position.y > height-r) return true;
    return false;
  }
}
