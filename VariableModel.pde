class VariableModel {
  
  // Variables de terraformación
  float avgTemperature;    // Temperatura promedio del planete en kelvin
  float distanceToTheSun;  // Distancia en metros del planeta a la estrella
  float oxigenPerc;        // Número entre 0 y 100
  float greenHouseEffect;  // Número entre 0 y 1
  float vegetationPerc;    // Número entre 0 y 100
  float waterPerc;         // Número entre 0 y 100
  float icePerc;           // Número entre 0 y 100
  float algaePerc;         // Número entre 0 y 100
  
  // Variable de escala de tiempo
  int yearsPerSecond;      // Cantidad de años por segundo
  
  // Constantes
  final float STEFAN_BOLTZMANN_CONST = 5.670374419e-8;
  final float SUN_LUMINOSITY = 3.838e26;
  final float WATER_ALBEDO = 0.45;
  final float ICE_ALBEDO = 0.75;
  final float VEGETATION_ALBEDO = 0.35;
  final float EMPTY_LAND_ALBEDO = 0.4;
  final float EARTH_RADIUS = 6.37101e6;
  final float EMPTY_LAND_HC = 2250.0;
  final float WATER_HC = 4000.0;
  final float ICE_HC = 2000.0;
  final float VEGETATION_HC = 1850.0;
  final float EARTH_MASS = 5.972e24;
  final float EARTH_SURFACE_AREA = 5.10e14;
  final int ATMOSPHERE_LAYERS = 5;
  final float SECONDS_IN_A_YEAR = 3.154e7;
  final float DEPTH_OF_ICE_MELTED_PER_DAY = 0.005;
  final float EARTH_WIND_AVG_VELOCITY = 33.05556;
  final float MAX_AVG_TEMP = 1000.0;
  final float EARTH_O2_MOLES = 3.375e19;
  
  public VariableModel(){
    yearsPerSecond = 1;
  }
  
  // Genera una configuración aleatoria para el planeta
  // Las variables de agua, algas, vegetación y oxígeno se inicializan en 0
  // Las demás variables se generan con valores apropiados para la terraformación
  public void generatePlanetConfig(){
    distanceToTheSun = random(0.7, 1.7) * 1.496e11;
    avgTemperature = random(263, 313);
    greenHouseEffect = random(0, 1);
    icePerc = random(10, 50);
    waterPerc = 0;
    algaePerc = 0;
    vegetationPerc = 0;
    oxigenPerc = 0;
  }
  
  // Retorna el valor del efecto invernadero ajustado a un modelo 
  // de atmósfera con 5 capas
  private float getGreenHouseEffect(){
    
    if (greenHouseEffect == 0){
      return 0;
    }
    
    if (greenHouseEffect >= 0.90){
      return greenHouseEffect;
    }
    
    return ((2 * ATMOSPHERE_LAYERS - 2) - (ATMOSPHERE_LAYERS - 2) * greenHouseEffect) / 
           ((2 * ATMOSPHERE_LAYERS) - (ATMOSPHERE_LAYERS - 1) * greenHouseEffect);
  }
  
  // Retorna el albedo de la superficie del planeta
  // El albedo se calcula a partir de la suma del porcentaje de superficie (agua, hielo, vegetación o tierra vacía)
  // multiplicado por el albedo del material
  private float getAlbedo(){
    
    float landPerc = 100 - (waterPerc + icePerc);
    float emptyLandPerc = landPerc - (vegetationPerc * landPerc) / 100;
    
    float albedo = (WATER_ALBEDO * (waterPerc / 100)) 
                 + (ICE_ALBEDO * (icePerc / 100)) 
                 + (VEGETATION_ALBEDO * ((landPerc - emptyLandPerc) / 100)) 
                 + (EMPTY_LAND_ALBEDO * (emptyLandPerc / 100));   
    
    return albedo;
  }
  
  // Retorna la capacidad de retención de calor del planeta
  // El valor se calcula a partir de la suma del porcentaje de superficie (agua, hielo, vegetación o tierra vacía)
  // multiplicado por la capacidad de retención de calor del material
  private float getSurfaceHeatCapacity(){
    
    float landPerc = 100 - (waterPerc + icePerc);
    float emptyLandPerc = landPerc - (vegetationPerc * landPerc) / 100;
    
    float surfaceHeatCapacity = (WATER_HC * (waterPerc / 100)) 
                              + (ICE_HC * (icePerc / 100)) 
                              + (VEGETATION_HC * ((landPerc - emptyLandPerc) / 100)) 
                              + (EMPTY_LAND_HC * (emptyLandPerc / 100));
         
    return surfaceHeatCapacity;
  }
  
  // Retorna la constante solar
  // La constante solar cambia con respecto a la distancia del planeta al sol
  private float getSolarConstant(){
    return SUN_LUMINOSITY / (4 * PI * pow(distanceToTheSun, 2));
  }
  
  // Retorna la cantidad de energía absorbida por el planeta
  // Las fuentes de energía son el calor de la estrella y la energía reflejada por la atmósfera a la superficie
  private float getPabs(){
    
    // Calcula la energía obtenida de la estrella
    float Pstar = getSolarConstant() * (1 - getAlbedo()) * PI * pow(EARTH_RADIUS, 2);
    
    // Calcula la energía obtenido por la atmósfera
    float Patm = (getGreenHouseEffect() / 2) * (STEFAN_BOLTZMANN_CONST * pow(avgTemperature, 4)) * 4 * PI * pow(EARTH_RADIUS, 2);
    
    return Pstar + Patm;
  }
  
  // Retorna la cantidad de energía que irradia el planeta
  private float getPrad(){
    
    float Prad = STEFAN_BOLTZMANN_CONST * pow(avgTemperature, 4) * 4 * PI * pow(EARTH_RADIUS, 2);
    
    return Prad;
  }
  
  // Actualiza la temperatura promedio del planeta según el cambio de tiempo
  private void updateAvgTemperature(){
    
    float Pabs = getPabs();
    float Prad = getPrad();
    float C = getSurfaceHeatCapacity() * EARTH_MASS;
    
    float tempChange = (Pabs - Prad) * (SECONDS_IN_A_YEAR * yearsPerSecond) / C;
    
    avgTemperature += tempChange;
    
    if (avgTemperature == Float.POSITIVE_INFINITY){
      avgTemperature = MAX_AVG_TEMP;
    }
    else if (avgTemperature == Float.NEGATIVE_INFINITY){
      avgTemperature = 0;
    }
    
    if (avgTemperature > MAX_AVG_TEMP) { 
      avgTemperature = MAX_AVG_TEMP; 
    }
    else if (avgTemperature < 0) { 
      avgTemperature = 0; 
    }
  }
  
  // Actualiza el porcentaje de agua y hielo al ser modificado manualmente por el usuario
  // Ajusta los porcentajes de agua y hielo para que sean consistentes con el cambio en el porcentaje de agua
  public void setWaterPerc(float value){
    
    float change = value - waterPerc;
    
    if (change > 0){ 
      
      float emptyLandPerc = 100 - icePerc - waterPerc;
      
      if (icePerc + emptyLandPerc != 0){
        icePerc -= change * (icePerc / (icePerc + emptyLandPerc));
      }
      
      waterPerc = value;
    } 
    else {
      waterPerc = value;
    }
  }
  
  // Actualiza el porcentaje de hielo y hielo al ser modificado manualmente por el usuario
  // Ajusta los porcentajes de agua y hielo para que sean consistentes con el cambio en el porcentaje de hielo
  public void setIcePerc(float value){
    
    float change = value - icePerc;
    
    if (change > 0){ 
      
      float emptyLandPerc = 100 - icePerc - waterPerc;
      
      if (waterPerc + emptyLandPerc != 0){
        waterPerc -= change * (waterPerc / (waterPerc + emptyLandPerc));
      }
          
      icePerc = value;
    } 
    else {
      icePerc = value;
    }
  }
  
  // Retorna una temperatura dada en kelvin en grados celcius
  private float kelvinToCelcius(float kelvin){
    return kelvin - 273.15;
  }
  
  // Actualiza el porcentaje de hielo según el cambio de tiempo
  private void updateIcePerc(){
    
    // El porcentaje de hielo supone una capa con grosor de 2500 metros
    
    // Si la temperatura es mayor a 0 y el porcentaje de hielo es mayor a 0,
    // entonces derrite el hielo presente
    if (avgTemperature >= 273.15 && icePerc > 0.0){
      
      // Calcula la profundidad de hielo derretido en el cambio de tiempo
      float depthOfIceMelted = (kelvinToCelcius(avgTemperature) * 365 * yearsPerSecond) * DEPTH_OF_ICE_MELTED_PER_DAY;
      
      // Si la profundidad es mayor a 2500 (por un cambio muy brusco de temperatura o escala de tiempo)
      // entonces convierte el porcentaje de hielo en agua y coloca el de hielo en 0
      if (depthOfIceMelted >= 2500.0){
        
        waterPerc += icePerc;
        
        if (waterPerc > 100.0){
          waterPerc = 100;
        }
        
        icePerc = 0;
        return;
      }
      
      // Si no, calcula el porcentaje derretido y resta al porcentaje actual
      
      float percentageMelted = (depthOfIceMelted * 100) / 2500;
      
      float absolutePercentageMelted = (percentageMelted * icePerc) / 100;
      
      icePerc -= absolutePercentageMelted;
      waterPerc += absolutePercentageMelted;
      
      if (icePerc < 0.01){
          icePerc = 0.0;
      }
      
    }
  }
  
  // Obtiene la superficie de agua presente en el planeta en metros cuadrados
  private float getWaterSurfaceArea(){
    return EARTH_SURFACE_AREA * (waterPerc / 100);
  }
  
  // Actualiza el porcentaje de agua según el cambio de tiempo
  private void updateWaterPerc(){
    
    if (waterPerc > 0.0){
      
      // Calcula el porcentaje de agua que se pierde por evaporación o congelamiento
      // El agua se mantiene estable entre 0 y 40 grados (no se modifica el porcentaje en este rango)
      
      float avgTempInCelcius = kelvinToCelcius(avgTemperature);
      
      float humidityRatio = 3.733e-3 + 3.2e-4 * avgTempInCelcius + 3e-6 * pow(avgTempInCelcius, 2) + 4e-7 * pow(avgTempInCelcius, 3);
      
      float waterSurfaceArea = getWaterSurfaceArea();
      
      float evaporationCoeficient = 25 + (19 * 11.9);
      
      float massEvaporated = yearsPerSecond * 365 * 24 * (evaporationCoeficient * waterSurfaceArea * humidityRatio);
      
      float currentMass = waterSurfaceArea * 2500 * 1000;
      
      float percentageLoss;
      
      if (abs(massEvaporated) > currentMass){
        percentageLoss = waterPerc;
      } 
      else {
        float percentageOfMassLoss = (massEvaporated * 100) / currentMass;
        percentageLoss = (percentageOfMassLoss * waterPerc) / 100;
      }
      
      // Si la temperatura es mayor a 40
      // se toma como evaporación
      if (avgTemperature >= 313.15){
        
        waterPerc -= percentageLoss;
      
        if (waterPerc < 0.01){
          waterPerc = 0.0;
        }
      } 
      
      // Si la temperatura es menor a 0
      // se toma como congelamiento
      else if (avgTemperature <= 273.15) {
        
        waterPerc -= abs(percentageLoss);
        icePerc += abs(percentageLoss);
        
        if (waterPerc < 0.01) {
          waterPerc = 0;
        }
        
        if (icePerc > 100) {
          icePerc = 100;
        }
      }
     
    }
  }
  
  // Actualiza el porcentaje de algas según el cambio de tiempo
  private void updateAlgaePerc(){
    
    // Si no hay agua, no hay crecimiento de algas y las que habían mueren
    if (waterPerc == 0){
      algaePerc = 0;
      return;
    } 
    
    float avgTempInCelcius = kelvinToCelcius(avgTemperature);
    
    // Si hay CO2 disponible y las temperaturas son estables para el crecimiento (entre 0 y 40), las algas crecen
    if (getGreenHouseEffect() > 0 && (avgTempInCelcius >= 0 && avgTempInCelcius <= 40)){
      
      
      if (algaePerc ==  100){
        return;
      }
      
      // Las algas cubren 30g (biomasa) por día
      // Para cubrir un metro se necesitan 120g de biomasa
      
      float waterSurfaceArea = getWaterSurfaceArea();
      float waterWithNoAlgae = waterSurfaceArea - (waterSurfaceArea * (algaePerc / 100));
      
      float greenHouseEffectBost = map(getGreenHouseEffect(), 0, 1, 0.01, 1);
      float tempBost = map(avgTempInCelcius, 0, 40, 0.01, 1);
      int newColonies = (int) random(100, 1000);
      float prevColonies = ((waterSurfaceArea * (algaePerc / 100)) / 120);
      
      // Calcula los metros cubiertos como la multiplicación de las colonias actualas más
      // las nuevas colonias
      float metersCoveredInAYear = ((30 * 365 * greenHouseEffectBost * tempBost * newColonies) / 120) + 
                                   ((30 * 365 * greenHouseEffectBost * tempBost * prevColonies) / 120);
      
      // Multiplica los metros cubiertos por un factor de escala (para simular muerte por factores ambientales)
      metersCoveredInAYear *= random(0, 1);
      
      float metersCovered = metersCoveredInAYear * yearsPerSecond;
      
      float incrementPerc = (metersCovered / waterWithNoAlgae) * 100;
      
      algaePerc += incrementPerc;   
      
      if (algaePerc > 100){
        algaePerc = 100;
      }
      
    }
    
    // Si las condiciones no son óptimas, entonces todas las algas mueren
    else {    
      algaePerc = 0;
    }
    
  }
  
  // Actualiza el porcentaje de oxígeno según el cambio de tiempo
  private void updateOxigenPerc(){
    
    // El porcentaje solo se actualiza si hay algas presentes
    if (algaePerc == 0){
      return;
    }
    
    float waterSurfaceArea = getWaterSurfaceArea();
    float algaeBiomass = (waterSurfaceArea * (algaePerc / 100)) * 120;
    float scalingFactor = random(0, 1);
    float o2MolesProduced = (yearsPerSecond * 365 * (24 * 0.00255 * algaeBiomass)) * scalingFactor;
   
    float incrementPerc = (o2MolesProduced * 100) / EARTH_O2_MOLES;
    
    oxigenPerc += incrementPerc;
    
    if (oxigenPerc > 100){
      oxigenPerc = 100;
    }
  }
  
  // Actualiza el porcentaje de vegetación según el cambio de tiempo
  private void updateVegetation(){
    
    float avgTempInCelcius = kelvinToCelcius(avgTemperature);
    float waterSurfaceArea = getWaterSurfaceArea();
    float landSurfaceArea = EARTH_SURFACE_AREA - waterSurfaceArea;
    
    // Los árboles crecen si hay área de crecimiento, dióxido de carbono en la atmósfera, 21% de oxígeno o más, hay agua y si la temperatura
    // está entre 0 y 40
    if (landSurfaceArea > 0 && getGreenHouseEffect() > 0 && oxigenPerc > 21 && waterPerc > 0 && (avgTempInCelcius >= 0 && avgTempInCelcius <= 40)){
      
      // Un arbol de roble ocupa un área de 200 m2
      // Los robles alcanzan la madurez aproximadamente a los 30 años
      // Al alcanzar la madurez, producen entre 0 y 6 robles en un periodo de 30 años
     
      float currentTrees = (landSurfaceArea * (vegetationPerc / 100)) / 200;
      
      if (currentTrees == 0){
        currentTrees = 1.0;
      }
      
      float reproductionCiclesPassed = yearsPerSecond / 30;   
      float scalingFactor = random(0, 0.8); 
      float areaCoveredByGrowth = 200 * random(0, 7) * reproductionCiclesPassed * currentTrees * scalingFactor;
      float incrementPerc = (areaCoveredByGrowth * 100) / landSurfaceArea;
      
      vegetationPerc += incrementPerc;
      
      if (vegetationPerc > 100){
        vegetationPerc = 100;
      }
      
    } 
    
    // Si no hay condiciones óptimas, entonces toda la vegetación muere
    else {
      vegetationPerc = 0;
    }
  }
  
  // Actualiza las variables de terraformación según el cambio de tiempo
  public void update(){
    
    updateAvgTemperature();
    
    updateIcePerc();
    
    updateWaterPerc();
    
    updateAlgaePerc();
    
    updateOxigenPerc();
    
    updateVegetation();
  }
  
}
