class Tree extends Sprite {
  
  PImage  img;
  
  //**************************************************
  Tree(PImage _image, PVector position) {
    
    this.img       = _image;
    this.diameter  = this.img.width/2;
    this.name      = "tree";
    this.position  = position;
    
  }

  //************************************************** 
  void display() {
      
  }
}
