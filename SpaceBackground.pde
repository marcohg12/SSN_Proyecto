class SpaceBackground {
  
  PVector[] stars; 
  
  SpaceBackground(int numStars) {
    
    stars = new PVector[numStars];
    
    // Genera una lista con las posiciones para cada estrella
    for (int i = 0; i < numStars; i++) {
      float x, y, z;
      do {
        x = random(-3100, 3100);
        y = random(-3100, 3100);
        z = random(-3100, 3100);
      } while (PVector.dist(new PVector(0, 0, 0), new PVector(x, y, z)) < 3000);
      stars[i] = new PVector(x, y, z);
    }
  }
  
  void display() {
    
    background(0); 
    fill(random(225, 255), random(225, 255), random(200, 255));      
    noStroke();     
    
    // Dibuja las estrellas
    for (PVector star : stars) {
      pushMatrix();
      translate(star.x, star.y, star.z); 
      ellipse(0, 0, 10, 10);
      popMatrix();
    }
  }
}
