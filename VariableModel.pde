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
  final float WATER_ALBEDO = 0.25;
  final float ICE_ALBEDO = 0.8;
  final float VEGETATION_ALBEDO = 0.25;
  final float EMPTY_LAND_ALBEDO = 0.4;
  final float EARTH_RADIUS = 6.37101e6;
  final float EMPTY_LAND_HC = 2250.0;
  final float WATER_HC = 4180.0;
  final float ICE_HC = 2000.0;
  final float VEGETATION_HC = 1850.0;
  final float EARTH_MASS = 5.972e24;
  final int ATMOSPHERE_LAYERS = 5;
  final float EARTH_AREA = 5.1e14;
  final float ICE_LAYER_THICKNESS = 2500;  // En metros
  final float ICE_DENSITY = 917;           // En kg por metro cúbrico
  final float ICE_HEAT_FUSION = 335000;
  final float SECONDS_IN_A_YEAR = 3.154e7;
  
  public VariableModel(float avgTemperature, float distanceToTheSun, float oxigenPerc, float greenHouseEffect,
                       float vegetationPerc, float waterPerc, float icePerc, int yearsPerSecond, float algaePerc){
    this.avgTemperature = avgTemperature;
    this.distanceToTheSun = distanceToTheSun;
    this.oxigenPerc = oxigenPerc;
    this.greenHouseEffect = greenHouseEffect;
    this.vegetationPerc = vegetationPerc;
    this.waterPerc = waterPerc;
    this.icePerc = icePerc;
    this.yearsPerSecond = yearsPerSecond;
    this.algaePerc = algaePerc;
  }
  
  private float getGreenHouseEffect(){
    if (greenHouseEffect == 0){
      return 0;
    }
    return ((2 * ATMOSPHERE_LAYERS - 2) - (ATMOSPHERE_LAYERS - 2) * greenHouseEffect) / 
           ((2 * ATMOSPHERE_LAYERS) - (ATMOSPHERE_LAYERS - 1) * greenHouseEffect);
  }
  
  private float getAlbedo(){
    
    float landPerc = 100 - (waterPerc + icePerc);
    float emptyLandPerc = landPerc - (vegetationPerc * landPerc) / 100;
    
    float albedo = (WATER_ALBEDO * (waterPerc / 100)) 
                 + (ICE_ALBEDO * (icePerc / 100)) 
                 + (VEGETATION_ALBEDO * ((landPerc - emptyLandPerc) / 100)) 
                 + (EMPTY_LAND_ALBEDO * (emptyLandPerc / 100));   
    
    return albedo;
  }
  
  private float getSurfaceHeatCapacity(){
    
    float landPerc = 100 - (waterPerc + icePerc);
    float emptyLandPerc = landPerc - (vegetationPerc * landPerc) / 100;
    
    float surfaceHeatCapacity = (WATER_HC * (waterPerc / 100)) 
                              + (ICE_HC * (icePerc / 100)) 
                              + (VEGETATION_HC * ((landPerc - emptyLandPerc) / 100)) 
                              + (EMPTY_LAND_HC * (emptyLandPerc / 100));
         
    return surfaceHeatCapacity;
  }
  
  private float getSolarConstant(){
    return SUN_LUMINOSITY / (4 * PI * pow(distanceToTheSun, 2));
  }
  
  private float getPabs(){
    
    // Calcula la energía obtenida de la estrella
    float Pstar = getSolarConstant() * (1 - getAlbedo()) * PI * pow(EARTH_RADIUS, 2);
    
    // Calcula la energía obtenido por la atmósfera
    float Patm = (getGreenHouseEffect() / 2) * (STEFAN_BOLTZMANN_CONST * pow(avgTemperature, 4)) * 4 * PI * pow(EARTH_RADIUS, 2);
    
    return Pstar + Patm;
  }
  
  private float getPrad(){
    
    // Calcula la energía que pierde el planeta
    float Prad = STEFAN_BOLTZMANN_CONST * pow(avgTemperature, 4) * 4 * PI * pow(EARTH_RADIUS, 2);
    
    return Prad;
  }
  
  // Actualiza la temperatura promedio del planeta
  // según el cambio de tiempo
  private void updateAvgTemperature(){
    
    float Pabs = getPabs();
    float Prad = getPrad();
    float C = getSurfaceHeatCapacity() * EARTH_MASS;
    
    float tempChange = (Pabs - Prad) * (SECONDS_IN_A_YEAR * yearsPerSecond) / C;
    
    avgTemperature += tempChange;
    
    if (avgTemperature == Float.POSITIVE_INFINITY){
      avgTemperature = 5000;
    }
    else if (avgTemperature == Float.NEGATIVE_INFINITY){
      avgTemperature = 0;
    }
    
    if (avgTemperature > 5000) { 
      avgTemperature = 5000; 
    }
    else if (avgTemperature < 0) { 
      avgTemperature = 0; 
    }
  }
  
  public void setWaterPerc(float value){
    
    float change = value - waterPerc;
    
    if (change != 0){ 
      
      float emptyLandPerc = 100 - icePerc - waterPerc;
      
      if (icePerc + emptyLandPerc != 0){
        icePerc -= change * (icePerc / (icePerc + emptyLandPerc));
      }
      
      waterPerc = value;
    }
  }
  
  public void setIcePerc(float value){
    
    float change = value - icePerc;
    
    if (change != 0){ 
      
      float emptyLandPerc = 100 - icePerc - waterPerc;
      
      if (waterPerc + emptyLandPerc != 0){
        waterPerc -= change * (waterPerc / (waterPerc + emptyLandPerc));
      }
          
      icePerc = value;
    }
  }
  
  // Retorna la masa en kg
  private float getIceMass(){
    float iceArea = (icePerc / 100) * EARTH_AREA;
    float iceVolume = iceArea * ICE_LAYER_THICKNESS;
    return iceVolume * ICE_DENSITY;
  }
  
  // Retorna la potencia en watts por segundo
  private float kelvinToPower(float kelvin){
    return kelvin * 1.38064878066852e-23;
  }
  
  private void updateIcePerc(){
    
    // El porcentaje de hielo supone una capa con grosor
    // de 2500 metros
    if (avgTemperature >= 273.15){
      
      // El hielo comienza a derretirse a temperaturas mayores a 
      // 0 grados celcius
      float timeToMeltAllIce = (ICE_HEAT_FUSION / kelvinToPower(avgTemperature)) * getIceMass();
      float timeStep = SECONDS_IN_A_YEAR * yearsPerSecond;
      
      System.out.println(getIceMass());
      
      if (timeStep >= timeToMeltAllIce){
        waterPerc += icePerc;
        icePerc = 0;
      } else {
        float percentageMelted = (((timeStep * 100) / timeToMeltAllIce) * 2) / 100;
        //System.out.println(percentageMelted);
        waterPerc += percentageMelted;
        icePerc -= percentageMelted;
      }
      
    }
  }
  
  
  public void update(){
    
    updateAvgTemperature();
    
    //updateIcePerc();
    
    System.out.println(avgTemperature);
  }
  
}
