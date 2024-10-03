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
    
    textureImg = loadImage("images/planet_texture.jpg");  // Imagen base del planeta
    
    noStroke();
    noFill();
    
    // Modificar la textura para agregar manchas de agua
    addWaterSpots(textureImg, 10, 200);  // 10 manchas de agua, tamaño máximo 20 píxeles
    
    globe = createShape(SPHERE, radius);
    globe.setTexture(textureImg);
  }
  
  // Método para agregar manchas de agua a la textura
  void addWaterSpots(PImage img, int numSpots, int maxRadius) {
    img.loadPixels();  // Cargar los píxeles de la imagen
    
    // Generar los puntos iniciales de las manchas
    for (int i = 0; i < numSpots; i++) {
      int centerX = int(random(img.width));
      int centerY = int(random(img.height));
      
      // Expander la mancha desde el punto inicial
      expandWaterSpot(img, centerX, centerY, maxRadius);
    }
    
    img.updatePixels();  // Actualizar los píxeles después de los cambios
  }
  
  // Método para expandir una mancha de agua desde un punto inicial
  void expandWaterSpot(PImage img, int cx, int cy, int maxRadius) {
    int radius = int(random(100, maxRadius));  // Radio de expansión de la mancha
    for (int r = 0; r < radius; r++) {
      for (int angle = 0; angle < 360; angle += 5) {  // Expandir en círculos
        int x = cx + int(r * cos(radians(angle)));
        int y = cy + int(r * sin(radians(angle)));
        
        // Asegurar que las coordenadas estén dentro de los límites de la imagen
        if (x >= 0 && x < img.width && y >= 0 && y < img.height) {
          img.pixels[y * img.width + x] = color(0, 100, 255);  // Color azul para agua
        }
      }
    }
  }

  void display() {
    pushMatrix();
    translate(x, y, z);  
    shape(globe);
    popMatrix();
  }
}
