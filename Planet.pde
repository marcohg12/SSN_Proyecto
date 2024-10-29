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
<<<<<<< HEAD
  PImage createCombinedTexture(PImage baseImg, PImage waterImg, PImage vegetationImg, PImage iceImg, PImage algasImg, float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {
=======
  private PImage createCombinedTexture(PImage baseImg, PImage waterImg, PImage vegetationImg, PImage iceImg, PImage algasImg, float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {
  
>>>>>>> 9fe3b8b76cbd63476da9dcc6b9da269c8b298711
    int width = baseImg.width;
    int height = baseImg.height;

    waterImg.resize(width, height);
    vegetationImg.resize(width, height);
    iceImg.resize(width, height);
    algasImg.resize(width, height);

<<<<<<< HEAD
    initializeTerrainMap(width, height);

=======
>>>>>>> 9fe3b8b76cbd63476da9dcc6b9da269c8b298711
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

      color baseColor = baseImg.pixels[i];
      color waterColor = waterImg.pixels[i];
      color vegetationColor = vegetationImg.pixels[i];
      color iceColor = iceImg.pixels[i];
      color algaeColor = algasImg.pixels[i];

      float noiseValue = red(noiseMap.pixels[i]) / 255.0;
<<<<<<< HEAD

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
=======
      
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
>>>>>>> 9fe3b8b76cbd63476da9dcc6b9da269c8b298711
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
<<<<<<< HEAD
  void updateTextures(float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {
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
=======
  public void updateTextures(float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {

    boolean waterChanged = abs(waterPerc - lastWaterPerc) != 0;
    boolean vegetationChanged = abs(vegetationPerc - lastVegetationPerc) != 0;
    boolean iceChanged = abs(icePerc - lastIcePerc) != 0;
    boolean algaeChanged = abs(algaePerc - lastAlgaePerc) != 0;

>>>>>>> 9fe3b8b76cbd63476da9dcc6b9da269c8b298711

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
