class Planet {
  // Radio del planeta
  float radius;

  // Coordenadas del planeta en el espacio 3D
  float x, y, z;

  // Forma del planeta (una esfera)
  PShape globe;
  
  // Niveles de auras
  float oxigenLevel, greenHELevel, tempLevel;

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

    waterImg.resize(width, height);
    vegetationImg.resize(width, height);
    iceImg.resize(width, height);
    algasImg.resize(width, height);

    initializeTerrainMap(width, height);

    PImage result = createImage(width, height, ARGB);
    baseImg.loadPixels();
    waterImg.loadPixels();
    vegetationImg.loadPixels();
    iceImg.loadPixels();
    algasImg.loadPixels();
    result.loadPixels();
    noiseMap.loadPixels();

    int totalPixels = width * height;
    float totalAlgaePerc = waterPerc * algaePerc;

    for (int i = 0; i < totalPixels; i++) {
      int x = i % width;
      int y = i / width;

      color baseColor = baseImg.pixels[i];
      color waterColor = waterImg.pixels[i];
      color vegetationColor = vegetationImg.pixels[i];
      color iceColor = iceImg.pixels[i];
      color algasColor = algasImg.pixels[i];

      float noiseValue = red(noiseMap.pixels[i]) / 255.0;

      // Si vegetación tiene prioridad
      if (vegetationPerc > waterPerc) {
        // 1. Aplicar vegetación en áreas vacías
        if (noiseValue < vegetationPerc && terrainMap[x][y] == EMPTY) {
          result.pixels[i] = vegetationColor;
          terrainMap[x][y] = VEGETATION;
        }
        // 2. Aplicar agua solo en áreas sin vegetación, con margen de separación
        else if (terrainMap[x][y] == EMPTY && noiseValue < (vegetationPerc + waterPerc)) {
          if (!isNearVegetation(x, y, width, height)) {
            result.pixels[i] = waterColor;
            terrainMap[x][y] = WATER;
          } else {
            result.pixels[i] = baseColor;
          }
        }
      }
      // Si agua tiene prioridad
      else {
        // 1. Aplicar agua en áreas vacías
        if (noiseValue < waterPerc && terrainMap[x][y] == EMPTY) {
          result.pixels[i] = waterColor;
          terrainMap[x][y] = WATER;
        }
        // 2. Aplicar vegetación solo en áreas sin agua, con margen de separación
        else if (terrainMap[x][y] == EMPTY && noiseValue < (waterPerc + vegetationPerc)) {
          if (!isNearWater(x, y, width, height)) {
            result.pixels[i] = vegetationColor;
            terrainMap[x][y] = VEGETATION;
          } else {
            result.pixels[i] = baseColor;
          }
        }
      }

      // 3. Aplicar hielo donde no haya agua, vegetación ni algas
      if (terrainMap[x][y] == EMPTY && noiseValue < (vegetationPerc + waterPerc + icePerc)) {
        result.pixels[i] = iceColor;
        terrainMap[x][y] = ICE;
      }

      // 4. Aplicar algas a la par del agua, en áreas vacías
      if (terrainMap[x][y] == WATER && noiseValue < totalAlgaePerc) {
        result.pixels[i] = algasColor;
        terrainMap[x][y] = ALGAE;  // Marcar el terreno como algas
      }

      // 5. Si no hay texturas aplicadas, usar la textura base
      if (terrainMap[x][y] == EMPTY) {
        result.pixels[i] = baseColor;
      }
    }

    result.updatePixels();
    return result;
  }

  // Método auxiliar para verificar si hay agua cerca de una posición
  boolean isNearWater(int x, int y, int width, int height) {
    for (int offsetX = -1; offsetX <= 1; offsetX++) {
      for (int offsetY = -1; offsetY <= 1; offsetY++) {
        int neighborX = x + offsetX;
        int neighborY = y + offsetY;
        if (neighborX >= 0 && neighborX < width && neighborY >= 0 && neighborY < height) {
          if (terrainMap[neighborX][neighborY] == WATER) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // Método auxiliar para verificar si hay vegetación cerca de una posición
  boolean isNearVegetation(int x, int y, int width, int height) {
    for (int offsetX = -1; offsetX <= 1; offsetX++) {
      for (int offsetY = -1; offsetY <= 1; offsetY++) {
        int neighborX = x + offsetX;
        int neighborY = y + offsetY;
        if (neighborX >= 0 && neighborX < width && neighborY >= 0 && neighborY < height) {
          if (terrainMap[neighborX][neighborY] == VEGETATION) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // Método para actualizar la textura del planeta cuando cambian los porcentajes de agua, vegetación, hielo o algas
  void updateTextures(float waterPerc, float vegetationPerc, float icePerc, float algaePerc, float greenHEPerc, float oxigenPerc, float tempPerc) {
    greenHELevel = greenHEPerc;
    oxigenLevel = oxigenPerc;
    tempLevel = tempPerc;
    updateAuras();
    // Suma de todos los porcentajes
    println("Suma agua + vegetación + hielo : " + (waterPerc + vegetationPerc + icePerc) * 100 + "%");

    // Verifica si el porcentaje de agua ha cambiado más de un 5% desde el último valor guardado
    boolean waterChanged = abs(waterPerc - lastWaterPerc) > 0.05;

    // Verifica si el porcentaje de vegetación ha cambiado más de un 5% desde el último valor guardado
    boolean vegetationChanged = abs(vegetationPerc - lastVegetationPerc) > 0.05;

    // Verifica si el porcentaje de hielo ha cambiado más de un 5% desde el último valor guardado
    boolean iceChanged = abs(icePerc - lastIcePerc) > 0.05;

    // Verifica si el porcentaje de algas ha cambiado más de un 5% desde el último valor guardado
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
  
  // Método para actualizar las auras que representan la temperatura, oxigeno y efecto invernadero
  void updateAuras() {
    float temp = map(tempLevel, 0, 1, 0, 50); 
    fill(255, 0, 0, temp); 
    
    pushMatrix();
    sphere(radius * 1.03); 
    popMatrix();
    
    float greenHouse = map(greenHELevel, 0, 1, 5, 50); 
    fill(200, 200, 200, greenHouse); 
    
    pushMatrix();
    sphere(radius * 1.1); 
    popMatrix();
    
    float oxigen = map(oxigenLevel, 0, 1, 5, 50);  
    fill(255, 255, 255, oxigen);  

    pushMatrix();
    sphere(radius * 1.2); 
    popMatrix();
  }

  // Método para dibujar el planeta con la textura actual
  void display() {
    pushMatrix();
    translate(x, y, z);
    shape(globe);
    popMatrix();
  }
}
