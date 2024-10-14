class Planet {
  // Radio del planeta
  float radius;

  // Coordenadas del planeta en el espacio 3D
  float x, y, z;

  // Forma del planeta (una esfera)
  PShape globe;

  // Imágenes para las texturas base, de agua, vegetación, hielo, algas y combinadas
  PImage baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture, combinedTexture, noiseMap;

  // Últimos porcentajes aplicados para el agua, vegetación, hielo y algas
  float lastWaterPerc;
  float lastVegetationPerc;
  float lastIcePerc;
  float lastAlgaePerc;

  // Matriz que tendrá el tipo de terreno en cada píxel
  int[][] terrainMap;

  // Constantes para los tipos de terreno
  final int EMPTY = 0; //Tierra
  final int WATER = 1;
  final int ICE = 2;
  final int VEGETATION = 3;
  final int ALGAE = 4;

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
  PImage createNoiseMap(int width, int height) {
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

  // Inicializar la matriz de terreno
  void initializeTerrainMap(int width, int height) {
    terrainMap = new int[width][height];

    // Inicializar toda la matriz con el valor EMPTY (tierra)
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        terrainMap[x][y] = EMPTY;  // Tierra vacía por defecto
      }
    }
  }

  // Método para combinar las texturas del planeta según los porcentajes de agua, vegetación, hielo y algas
PImage createCombinedTexture(PImage baseImg, PImage waterImg, PImage vegetationImg, PImage iceImg, PImage algasImg, float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {
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

    initializeTerrainMap(width, height);  // Inicializar la matriz de terreno

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
      int x = i % width;
      int y = i / width;

      color baseColor = baseImg.pixels[i];
      color waterColor = waterImg.pixels[i];
      color vegetationColor = vegetationImg.pixels[i];
      color iceColor = iceImg.pixels[i];
      color algasColor = algasImg.pixels[i];

      float noiseValue = red(noiseMap.pixels[i]) / 255.0;

      // 1. Aplicar agua
      if (noiseValue < waterPerc) {
        result.pixels[i] = waterColor;
        terrainMap[x][y] = WATER;  // Marcar el terreno como agua
      }
      // 2. Aplicar hielo donde no haya agua
      else if (terrainMap[x][y] == EMPTY && noiseValue < (waterPerc + icePerc)) {
        result.pixels[i] = iceColor;
        terrainMap[x][y] = ICE;  // Marcar el terreno como hielo
      }
      // 3. Aplicar vegetación donde no haya agua ni hielo
      else if (terrainMap[x][y] == EMPTY && noiseValue < (waterPerc + icePerc + vegetationPerc)) {
        result.pixels[i] = vegetationColor;
        terrainMap[x][y] = VEGETATION;  // Marcar el terreno como vegetación
      }
      // 4. Aplicar algas solo donde no hay agua ni hielo
      else if (terrainMap[x][y] == EMPTY && noiseValue < (waterPerc + icePerc + vegetationPerc + algaePerc)) {
        result.pixels[i] = algasColor;
        terrainMap[x][y] = ALGAE;  // Marcar el terreno como algas
      }
      // 5. Si no hay texturas aplicadas, usar la textura base
      else {
        result.pixels[i] = baseColor;
      }
    }

    result.updatePixels();
    return result;
}



  // Método para actualizar la textura del planeta cuando cambian los porcentajes de agua, vegetación, hielo o algas
  void updateTextures(float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {
    // Suma de todos los porcentajes
    println("Suma agua + vegetación + hielo + algas: " + (waterPerc + vegetationPerc + icePerc + algaePerc) * 100 + "%");

    boolean waterChanged = abs(waterPerc - lastWaterPerc) > 0.05;
    boolean vegetationChanged = abs(vegetationPerc - lastVegetationPerc) > 0.05;
    boolean iceChanged = abs(icePerc - lastIcePerc) > 0.05;
    boolean algaeChanged = abs(algaePerc - lastAlgaePerc) > 0.05;

    // Porcentajes individuales
    println("Agua: " + waterPerc * 100 + "%");
    println("Vegetación: " + vegetationPerc * 100 + "%");
    println("Hielo: " + icePerc * 100 + "%");
    println("Algas: " + algaePerc * 100 + "%");

    if (waterChanged || vegetationChanged || iceChanged || algaeChanged) {
      combinedTexture = createCombinedTexture(baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture, waterPerc, vegetationPerc, icePerc, algaePerc);
      globe.setTexture(combinedTexture);
      lastWaterPerc = waterPerc;
      lastVegetationPerc = vegetationPerc;
      lastIcePerc = icePerc;
      lastAlgaePerc = algaePerc;
    }
  }

  // Método para dibujar el planeta con la textura actual
  void display() {
    pushMatrix();
    translate(x, y, z);
    shape(globe);
    popMatrix();
  }
}
