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

  Planet(float radius) {
    this.radius = radius;
    x = 0;
    y = 0;
    z = 0;

    // Cargar las texturas base del planeta (marrón), del agua (azul), de la vegetación (verde), del hielo (blanco) y de las algas (verde oscuro)
    baseTexture = loadImage("images/planet_texture.jpg");
    waterTexture = loadImage("images/water_texture.jpg");
    vegetationTexture = loadImage("images/vegetation_texture.jpg");
    iceTexture = loadImage("images/ice_texture.jpg");
    algaeTexture = loadImage("images/algas_texture.jpg");

    // Redimensionar las texturas (reduce la cantidad de píxeles a procesar)
    baseTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    waterTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    vegetationTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    iceTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    algaeTexture.resize(baseTexture.width / 2, baseTexture.height / 2);

    // Crea el mapa de ruido por adelantado para usarlo en la distribución del agua, vegetación, hielo y algas
    noiseMap = createNoiseMap(baseTexture.width, baseTexture.height);

    // Inicializar las texturas combinadas con 50% de agua, 50% de vegetación y 0% de hielo y algas
    combinedTexture = createCombinedTexture(baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture, 0.5, 0.5, 0.0, 0.0);

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

  // Método para combinar las texturas del planeta según los porcentajes de agua, vegetación, hielo y algas
  PImage createCombinedTexture(PImage baseImg, PImage waterImg, PImage vegetationImg, PImage iceImg, PImage algasImg, float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {
    if (baseImg.width != waterImg.width || baseImg.height != waterImg.height || baseImg.width != vegetationImg.width || baseImg.width != iceImg.width || baseImg.width != algasImg.width) {
      waterImg.resize(baseImg.width, baseImg.height);
      vegetationImg.resize(baseImg.width, baseImg.height);
      iceImg.resize(baseImg.width, baseImg.height);
      algasImg.resize(baseImg.width, baseImg.height);
    }

    PImage result = createImage(baseImg.width, baseImg.height, ARGB);
    baseImg.loadPixels();
    waterImg.loadPixels();
    vegetationImg.loadPixels();
    iceImg.loadPixels();
    algasImg.loadPixels();
    result.loadPixels();
    noiseMap.loadPixels();

    int totalPixels = baseImg.width * baseImg.height;
    float totalPerc = waterPerc + vegetationPerc + icePerc + algaePerc;

    for (int i = 0; i < totalPixels; i++) {
      color baseColor = baseImg.pixels[i];
      color waterColor = waterImg.pixels[i];
      color vegetationColor = vegetationImg.pixels[i];
      color iceColor = iceImg.pixels[i];
      color algasColor = algasImg.pixels[i];

      float noiseValue = red(noiseMap.pixels[i]) / 255.0;

      // Aplicar agua si el valor del ruido está dentro del rango del porcentaje de agua
      if (noiseValue < waterPerc) {
        result.pixels[i] = waterColor;
      }
      // Aplicar vegetación si el valor del ruido está dentro del rango del porcentaje de vegetación
      else if (noiseValue >= waterPerc && noiseValue < (waterPerc + vegetationPerc)) {
        result.pixels[i] = vegetationColor;
      }
      // Aplicar hielo si el valor del ruido está dentro del rango del porcentaje de hielo
      else if (noiseValue >= (waterPerc + vegetationPerc) && noiseValue < (waterPerc + vegetationPerc + icePerc)) {
        result.pixels[i] = iceColor;
      }
      // Aplicar algas si el valor del ruido está dentro del rango del porcentaje de algas
      else if (noiseValue >= (waterPerc + vegetationPerc + icePerc) && noiseValue < totalPerc) {
        result.pixels[i] = algasColor;
      }
      // Mostrar solo la superficie del planeta (base)
      else {
        result.pixels[i] = baseColor;
      }
    }

    result.updatePixels();
    return result;
  }

  // Método para actualizar la textura del planeta cuando cambian los porcentajes de agua, vegetación, hielo o algas
  void updateTextures(float waterPerc, float vegetationPerc, float icePerc, float algaePerc) {
    boolean waterChanged = abs(waterPerc - lastWaterPerc) > 0.05;
    boolean vegetationChanged = abs(vegetationPerc - lastVegetationPerc) > 0.05;
    boolean iceChanged = abs(icePerc - lastIcePerc) > 0.05;
    boolean algaeChanged = abs(algaePerc - lastAlgaePerc) > 0.05;

    println("Suma de agua, vegetación, hielo y algas: " + (waterPerc + vegetationPerc + icePerc + algaePerc) * 100 + "%");
    println("Agua: " + (waterPerc) * 100 + "%");
    println("Vegetación: " + (vegetationPerc) * 100 + "%");
    println("Hielo: " + (icePerc) * 100 + "%");
    println("Algas: " + (algaePerc) * 100 + "%");

    // Si el agua, vegetación, hielo o algas cambiaron significativamente, actualizamos las texturas
    if (waterChanged || vegetationChanged || iceChanged || algaeChanged) {
      combinedTexture = createCombinedTexture(baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture, waterPerc, vegetationPerc, icePerc, algaePerc);
      globe.setTexture(combinedTexture);  // Asigna la nueva textura al planeta
      lastWaterPerc = waterPerc;          // Guarda el nuevo porcentaje de agua
      lastVegetationPerc = vegetationPerc; // Guarda el nuevo porcentaje de vegetación
      lastIcePerc = icePerc;              // Guarda el nuevo porcentaje de hielo
      lastAlgaePerc = algaePerc;          // Guarda el nuevo porcentaje de algas
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
