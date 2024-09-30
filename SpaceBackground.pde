class SpaceBackground {
  PVector[] stars; 
  
  SpaceBackground(int numStars) {
    stars = new PVector[numStars];
    for (int i = 0; i < numStars; i++) {
      float x = random(-width, width);
      float y = random(-height, height);
      float z = random(-1000, 1000); 
      stars[i] = new PVector(x, y, z);
    }
  }
  
  void display() {
    background(0); 
    fill(random(225, 255), random(225, 255), random(200, 255));      
    noStroke();     
    for (PVector star : stars) {
      pushMatrix();
      translate(star.x, star.y, star.z);  
      ellipse(0, 0, 2, 2);  
      popMatrix();
    }
  }
}
