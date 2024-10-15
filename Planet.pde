class Planet {
  // Radio del planeta
  private float radius;

  // Coordenadas del planeta en el espacio 3D
  private float x, y, z;

  // Forma del planeta (una esfera)
  private PShape globe;

  // Imágenes para las texturas base, de agua, vegetación, hielo, algas y combinadas
  private PImage baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture, combinedTexture, noiseMap;

  // Últimos porcentajes aplicados para el agua, vegetación, hielo y algas
  private float lastWaterPerc;
  private float lastVegetationPerc;
  private float lastIcePerc;
  private float lastAlgaePerc;

  Planet(float radius) {
    this.radius = radius;
    x = 0;
    y = 0;
    z = 0;

    // Cargar las texturas base del planeta 
    baseTexture = loadImage("images/planet_texture.jpg");
    waterTexture = loadImage("images/water_texture.jpg");
    vegetationTexture = loadImage("images/vegetation_texture.jpg");
    iceTexture = loadImage("images/ice_texture.jpg");
    algaeTexture = loadImage("images/algas_texture.jpg");

    // Redimensionar las texturas para asegurarnos que tienen el mismo tamaño
    baseTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    waterTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    vegetationTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    iceTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    algaeTexture.resize(baseTexture.width / 2, baseTexture.height / 2);

    // Crea el mapa de ruido por adelantado para usarlo en la distribución del agua, vegetación, hielo y algas
    noiseMap = createNoiseMap(baseTexture.width, baseTexture.height);

    // Inicializar las texturas combinadas con 50% de agua, 50% de vegetación y 0% de hielo y algas
    combinedTexture = createCombinedTexture(baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture, 0.0, 0.0, 0.0, 0.0);

    // Guardar los porcentajes iniciales
    lastWaterPerc = 0.5;
    lastVegetationPerc = 0.5;
    lastIcePerc = 0.0;
    lastAlgaePerc = 0.0;

    noStroke();
    noFill();
    globe = createShape(SPHERE, radius);
    globe.setTexture(combinedTexture);
  }

  // Método para crear un mapa de ruido que ayuda a decidir dónde colocar el agua, vegetación, hielo y algas
  private PImage createNoiseMap(int width, int height) {
    PImage noiseImg = createImage(width, height, ARGB);
    noiseImg.loadPixels();

    // Generar ruido Perlin para cada píxel de la imagen, según cada coordenada
    for (int i = 0; i < width * height; i++) {
      float u = (i % width) / float(width);
      float v = (i / width) / float(height);
      float noiseValue = noise(u * 10, v * 10);
      noiseImg.pixels[i] = color(noiseValue * 255);
    }
    noiseImg.updatePixels();
    return noiseImg;
  }

  // Método para combinar las texturas del planeta según los porcentajes de agua, vegetación, hielo y algas
  private PImage createCombinedTexture(PImage baseImg, PImage waterImg, PImage vegetationImg, PImage iceImg, PImage algasImg, float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {
  
    int width = baseImg.width;
    int height = baseImg.height;

    // Redimensionar todas las imágenes al tamaño de la imagen base
    if (waterImg.width != width || waterImg.height != height) {
      waterImg.resize(width, height);
    }
    if (vegetationImg.width != width || vegetationImg.height != height) {
      vegetationImg.resize(width, height);
    }
    if (iceImg.width != width || iceImg.height != height) {
      iceImg.resize(width, height);
    }
    if (algasImg.width != width || algasImg.height != height) {
      algasImg.resize(width, height);
    }

    PImage result = createImage(width, height, ARGB);
    baseImg.loadPixels();
    waterImg.loadPixels();
    vegetationImg.loadPixels();
    iceImg.loadPixels();
    algasImg.loadPixels();
    result.loadPixels();
    noiseMap.loadPixels();

    int totalPixels = width * height;

    for (int i = 0; i < totalPixels; i++) {

      color baseColor = baseImg.pixels[i];
      color waterColor = waterImg.pixels[i];
      color vegetationColor = vegetationImg.pixels[i];
      color iceColor = iceImg.pixels[i];
      color algaeColor = algasImg.pixels[i];

      float noiseValue = red(noiseMap.pixels[i]) / 255.0;
      
      if (noiseValue < waterPerc) {
        
        if (noiseValue < algaePerc * waterPerc) {
          result.pixels[i] = algaeColor;
        } else {
          result.pixels[i] = waterColor;
        }
        
      } 
      else if (noiseValue < (waterPerc + icePerc)) {
        result.pixels[i] = iceColor;
      } 
      else {

        if (noiseValue < vegetationPerc * (1 - waterPerc - icePerc)) {
          result.pixels[i] = vegetationColor;
        } else {
          result.pixels[i] = baseColor;
        }
      }
    }

    result.updatePixels();
    return result;
}



  // Método para actualizar la textura del planeta cuando cambian los porcentajes de agua, vegetación, hielo o algas
  public void updateTextures(float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {

    boolean waterChanged = abs(waterPerc - lastWaterPerc) != 0;
    boolean vegetationChanged = abs(vegetationPerc - lastVegetationPerc) != 0;
    boolean iceChanged = abs(icePerc - lastIcePerc) != 0;
    boolean algaeChanged = abs(algaePerc - lastAlgaePerc) != 0;


    if (waterChanged || vegetationChanged || iceChanged || algaeChanged) {
      combinedTexture = createCombinedTexture(baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture, waterPerc, vegetationPerc, icePerc, algaePerc);
      globe.setTexture(combinedTexture);
      //combinedTexture.save("textura_guardada.jpg");
      lastWaterPerc = waterPerc;
      lastVegetationPerc = vegetationPerc;
      lastIcePerc = icePerc;
      lastAlgaePerc = algaePerc;
    }
  }

  // Método para dibujar el planeta con la textura actual
  public void display() {
    pushMatrix();
    translate(x, y, z);
    shape(globe);
    popMatrix();
  }
}
