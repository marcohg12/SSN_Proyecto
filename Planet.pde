class Planet {
  float radius;      
  float x, y, z;   
  PShape globe;
  PImage textureImg;
  
  Planet(float radius) {
    this.radius = radius;
    x = 0;
    y = 0;
    z = 0;
    
    textureImg = loadImage("planet_texture.jpg");
    
    noStroke();
    noFill();
    globe = createShape(SPHERE, radius);
    globe.setTexture(textureImg);
  }
  
    void display() {
    pushMatrix();
    translate(x, y, z);  
    shape(globe);
    popMatrix();
  }
}
