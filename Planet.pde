class Planet {
  float radius;
  float x, y, z;
  PShape globe;
  PImage baseTexture, waterTexture, combinedTexture, iceTexture;
  
  Planet(float radius) {
    this.radius = radius;
    x = 0;
    y = 0;
    z = 0;
    
    // Cargar las texturas
    baseTexture = loadImage("images/planet_texture.jpg");  // Textura del planeta (marrón)
    waterTexture = loadImage("images/water_texture.jpg");  // Textura del agua (azul, con transparencias)
    iceTexture = loadImage("images/ice_texture.jpg"); 
    // Crear una textura combinada que aplicará las imágenes con máscaras de opacidad
    combinedTexture = createCombinedTexture(baseTexture, waterTexture);
    
    //combinedTexture = createCombinedTexture(baseTexture, iceTexture);
    
    noStroke();
    noFill();
    globe = createShape(SPHERE, radius);
    globe.setTexture(combinedTexture);  // Aplicar la textura combinada
  }
  
  // Método para combinar las dos imágenes con una máscara de opacidad
 PImage createCombinedTexture(PImage baseImg, PImage waterImg) {
    // Asegurarse de que ambas imágenes tengan el mismo tamaño
    if (baseImg.width != waterImg.width || baseImg.height != waterImg.height) {
      println("Redimensionando imágenes para que tengan el mismo tamaño...");
      waterImg.resize(baseImg.width, baseImg.height);  // Ajustar el tamaño de waterImg para que coincida con baseImg
    }
  
    // Crear la imagen resultante con el tamaño de baseImg
    PImage result = createImage(baseImg.width, baseImg.height, ARGB);
  
    // Cargar píxeles antes de modificarlos
    baseImg.loadPixels();
    waterImg.loadPixels();
    result.loadPixels();
  
    int totalPixels = baseImg.width * baseImg.height;  // Número total de píxeles en la imagen
    
    // Combinar píxeles de las dos imágenes
    for (int i = 0; i < totalPixels; i++) {
      color baseColor = baseImg.pixels[i];
      color waterColor = waterImg.pixels[i];
      
      // Aquí aplicas las máscaras y la combinación de colores como antes
      float u = (i % baseImg.width) / float(baseImg.width);
      float v = (i / baseImg.width) / float(baseImg.height);
      
      float opacityMask = noise(u * 10, v * 10);  // Máscara de ruido
      opacityMask = constrain(opacityMask - 0, 0, 1);  // Ajustar la máscara
      
      float r = red(baseColor) * (1 - opacityMask) + red(waterColor) * opacityMask;
      float g = green(baseColor) * (1 - opacityMask) + green(waterColor) * opacityMask;
      float b = blue(baseColor) * (1 - opacityMask) + blue(waterColor) * opacityMask;
      
      result.pixels[i] = color(r, g, b);
    }
  
    // Actualizar la imagen resultante con los nuevos píxeles
    result.updatePixels();
    
    return result;
  }

  
  void display() {
    pushMatrix();
    translate(x, y, z);
    shape(globe);
    popMatrix();
  }
}
