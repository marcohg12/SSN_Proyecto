import java.util.ArrayList;

class Planet {
  // Radio del planeta
  float radius;

  // Coordenadas del planeta en el espacio 3D
  float x, y, z;

  // Forma del planeta (una esfera)
  PShape globe;

  // Niveles de auras
  float oxigenLevel, greenHELevel, tempLevel, greenHouse, temp, oxigen;

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

  // Constructor
  Planet(float radius) {
    this.radius = radius;
    x = 0;
    y = 0;
    z = 0;

    // Carga las texturas base del planeta
    baseTexture = loadImage("images/planet_texture.jpg");
    waterTexture = loadImage("images/water_texture.jpg");
    vegetationTexture = loadImage("images/vegetation_texture.jpg");
    iceTexture = loadImage("images/ice_texture.jpg");
    algaeTexture = loadImage("images/algas_texture.jpg");

    // Redimensiona las texturas para asegurarnos que tienen el mismo tamaño
    baseTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    waterTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    vegetationTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    iceTexture.resize(baseTexture.width / 2, baseTexture.height / 2);
    algaeTexture.resize(baseTexture.width / 2, baseTexture.height / 2);

    // Genera un mapa de ruido para la distribución de terreno
    noiseMap = createNoiseMap(baseTexture.width, baseTexture.height);

    // Inicializa la textura combinada del planeta
    combinedTexture = createCombinedTexture(baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture, 0.0, 0.0, 0.0, 0.0);

    // Inicializa los porcentajes de terreno
    lastWaterPerc = 0.01;
    lastVegetationPerc = 0.01;
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

    // Genera ruido Perlin para cada píxel de la imagen, según cada coordenada, es decir,
    // rellena cada píxel del mapa con un valor de ruido Perlin
    for (int i = 0; i < width * height; i++) {
      float u = (i % width) / float(width);
      float v = (i / width) / float(height);
      float noiseValue = noise(u * 10, v * 10);
      noiseImg.pixels[i] = color(noiseValue * 255);
    }
    noiseImg.updatePixels();
    return noiseImg;
  }

  // Inicializa la matriz de terreno
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
  PImage createCombinedTexture(PImage baseTexture, PImage waterTexture, PImage vegetationTexture, PImage iceTexture, PImage algaeTexture, float waterPercentage, float vegetationPercentage, float icePercentage, float algaePercentage) {
    int width = baseTexture.width;
    int height = baseTexture.height;
    int totalPixels = width * height;

    // Redimensiona todas las texturas a la misma dimensión que la textura base
    waterTexture.resize(width, height);
    vegetationTexture.resize(width, height);
    iceTexture.resize(width, height);
    algaeTexture.resize(width, height);

    // Inicializa el mapa de terreno que almacenará el tipo de terreno en cada píxel
    initializeTerrainMap(width, height);

    // Crea la imagen de resultado y carga los píxeles de cada textura y del mapa de ruido
    PImage resultTexture = createImage(width, height, ARGB);
    baseTexture.loadPixels();
    waterTexture.loadPixels();
    vegetationTexture.loadPixels();
    iceTexture.loadPixels();
    algaeTexture.loadPixels();
    resultTexture.loadPixels();
    noiseMap.loadPixels();

    // Define cuántos píxeles deben corresponder a cada tipo de terreno
    int icePixelTarget = (int) (totalPixels * icePercentage);
    int waterPixelTarget = (int) (totalPixels * waterPercentage);
    int vegetationPixelTarget = (int) (totalPixels * vegetationPercentage);
    int algaePixelTarget = (int) (waterPixelTarget * algaePercentage); // Algas dentro del agua

    // Lista que almacena los índices de cada píxel en la textura
    ArrayList<Integer> pixelIndices = new ArrayList<>();
    for (int i = 0; i < totalPixels; i++) {
      pixelIndices.add(i);
    }

    // Ordena los píxeles según su "ruido" (un valor que ayuda a decidir el tipo de terreno).
    // Así, los píxeles con valores parecidos se agrupan y forman áreas de terreno más continuas,
    // es decir, zonas de agua o vegetación, en lugar de estar repartidos de forma aleatoria.
    pixelIndices.sort((a, b) -> Float.compare(
      red(noiseMap.pixels[a]) / 255.0,
      red(noiseMap.pixels[b]) / 255.0
      ));

    // Variable de índice para recorrer y asignar los tipos de terreno a los píxeles
    int pixelIndex = 0;

    // Usa los primeros 'icePixelTarget' píxeles para asignar hielo, es decir,
    // asigna hielo a los primeros píxeles en función del ruido
    for (pixelIndex = 0; pixelIndex < icePixelTarget; pixelIndex++) {
      int currentPixel = pixelIndices.get(pixelIndex);
      resultTexture.pixels[currentPixel] = iceTexture.pixels[currentPixel];
      terrainMap[currentPixel % width][currentPixel / width] = ICE;
    }

    // Usa los siguientes 'waterPixelTarget' píxeles para asignar agua.
    for (int waterIndex = 0; waterIndex < waterPixelTarget; waterIndex++) {
      int currentPixel = pixelIndices.get(pixelIndex++);
      resultTexture.pixels[currentPixel] = waterTexture.pixels[currentPixel];
      terrainMap[currentPixel % width][currentPixel / width] = WATER;
    }

    // Usa los siguientes 'vegetationPixelTarget' píxeles para asignar vegetación.
    for (int vegetationIndex = 0; vegetationIndex < vegetationPixelTarget; vegetationIndex++) {
      int currentPixel = pixelIndices.get(pixelIndex++);
      resultTexture.pixels[currentPixel] = vegetationTexture.pixels[currentPixel];
      terrainMap[currentPixel % width][currentPixel / width] = VEGETATION;
    }

    // Asigna algas en una parte de los píxeles de agua
    int algaeAssigned = 0;
    for (int i = icePixelTarget; i < icePixelTarget + waterPixelTarget && algaeAssigned < algaePixelTarget; i++) {
      int currentPixel = pixelIndices.get(i);
      if (terrainMap[currentPixel % width][currentPixel / width] == WATER) {
        resultTexture.pixels[currentPixel] = algaeTexture.pixels[currentPixel];
        terrainMap[currentPixel % width][currentPixel / width] = ALGAE;
        algaeAssigned++;
      }
    }

    // Llena los píxeles restantes con la textura base, donde el tipo de terreno aún esté vacío
    for (int i = 0; i < totalPixels; i++) {
      if (terrainMap[i % width][i / width] == EMPTY) {
        resultTexture.pixels[i] = baseTexture.pixels[i];
      }
    }

    // Actualiza los píxeles de la textura resultante antes de devolver la imagen
    resultTexture.updatePixels();
    return resultTexture;
  }



  // Método para actualizar la textura del planeta cuando cambian los porcentajes de agua, vegetación, hielo o algas
  void updateTextures(float waterPerc, float vegetationPerc, float icePerc, float algaePerc, float greenHEPerc, float oxigenPerc, float tempPerc) {
    
    // Actualiza los niveles de aura
    updateAuras(greenHEPerc, oxigenPerc, tempPerc);

    // Espacio total disponible al inicio (100% del planeta)
    float availableSurface = 1.0;

    // Ajusta el porcentaje de agua en función del espacio disponible.
    // Si waterPerc es mayor que el espacio disponible, se limita al espacio restante.
    float adjustedWaterPerc = min(waterPerc, availableSurface);
    availableSurface -= adjustedWaterPerc; // Actualizamos el espacio restante después de aplicar agua
    
    // Ajusta el porcentaje de hielo según el espacio restante después de agua y vegetación.
    // Nos aseguramos que el hielo solo ocupe el espacio que queda disponible.
    float adjustedIcePerc = min(icePerc, availableSurface);
    availableSurface -= adjustedIcePerc; // Actualizamos el espacio restante después de aplicar hielo

    // Ajusta el porcentaje de vegetación según el espacio que queda después del agua.
    // Multiplicamos vegetationPerc por el espacio restante para que solo ocupe lo que queda disponible.
    float adjustedVegetationPerc = min(vegetationPerc * availableSurface, availableSurface);
    availableSurface -= adjustedVegetationPerc; // Actualizamos el espacio restante después de aplicar vegetación

    //println("Agua aplicada: " + adjustedWaterPerc * 100 + "%");
    //println("Vegetación aplicada: " + adjustedVegetationPerc * 100 + "%");
    //println("Hielo aplicado: " + adjustedIcePerc * 100 + "%");
    //println("Algas: " + algaePerc * 100 + "% (sin cambios)");
    //println("Espacio libre restante available: " + availableSurface * 100 + "%");

    // Verifica si alguno de los valores ha cambiado
    boolean waterChanged = abs(adjustedWaterPerc - lastWaterPerc) > 0.001;
    boolean vegetationChanged = abs(adjustedVegetationPerc - lastVegetationPerc) > 0.001;
    boolean iceChanged = abs(adjustedIcePerc - lastIcePerc) > 0.001;
    boolean algaeChanged = abs(algaePerc - lastAlgaePerc) > 0.001;

    // Si hubo cambios, crea la textura combinada y actualiza la esfera del planeta
    if (waterChanged || vegetationChanged || iceChanged || algaeChanged) {
      // Crear la textura combinada con los valores ajustados
      combinedTexture = createCombinedTexture(
        baseTexture, waterTexture, vegetationTexture, iceTexture, algaeTexture,
        adjustedWaterPerc, adjustedVegetationPerc, adjustedIcePerc, algaePerc // algaePerc sin cambios
        );

      globe.setTexture(combinedTexture);

      // Guarda los últimos valores actualizados
      lastWaterPerc = adjustedWaterPerc;
      lastVegetationPerc = adjustedVegetationPerc;
      lastIcePerc = adjustedIcePerc;
      lastAlgaePerc = algaePerc;
    }
  }

  // Método para actualizar las auras que representan la temperatura, oxigeno y efecto invernadero
  void updateAuras(float greenHEPerc, float oxigenPerc, float tempPerc) {
    if(tempPerc != tempLevel){
      tempLevel = tempPerc;  
      temp = map(tempLevel, 0, 1, 0, 50);
    }
    fill(255, 0, 0, temp);
    pushMatrix();
    sphere(radius * 1.03);
    popMatrix();
    
    if( greenHEPerc != greenHELevel){
      greenHELevel = greenHEPerc;
      greenHouse = map(greenHELevel, 0, 1, 5, 50);
    }
    fill(200, 200, 200, greenHouse);
    pushMatrix();
    sphere(radius * 1.1);
    popMatrix();
    
    
    if(oxigenPerc != oxigenLevel){
      oxigenLevel = oxigenPerc;
      oxigen = map(oxigenLevel, 0, 1, 5, 50);
    }
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
