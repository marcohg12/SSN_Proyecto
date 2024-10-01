class ModelVariableConfig {
  
  // Variables de terraformación
  float avgTemperature;
  float distanceToTheSun;
  float oxigenPerc;        // Número entre 0 y 100
  float co2Perc;           // Número entre 0 y 100
  float vegetationPerc;    // Número entre 0 y 100
  float waterPerc;         // Número entre 0 y 100
  float icePerc;           // Número entre 0 y 100
  
  // Constantes
  final float STEFAN_BOLTZMANN_CONST = 5.670374419e-8;
  final float SUN_LUMINOSITY = 3.838e26;
  final float WATER_ALBEDO = 0.25;
  final float ICE_ALBEDO = 0.8;
  final float VEGETATION_ALBEDO = 0.25;
  final float EMPTY_LAND_ALBEDO = 0.4;
  
  float getSolarConstant(){
    return (SUN_LUMINOSITY / (4 * PI * pow(distanceToTheSun, 2)));
  }
  
  float getAlbedo(){
    
    float emptyLandPerc = 100 - (vegetationPerc + waterPerc + icePerc);
    float albedo = (WATER_ALBEDO * (waterPerc / 100)) 
                 + (ICE_ALBEDO * (icePerc / 100)) 
                 + (VEGETATION_ALBEDO * (vegetationPerc / 100)) 
                 + (EMPTY_LAND_ALBEDO * (emptyLandPerc / 100));
    
    return albedo;
  }
  
  float getGreenHouseEffect(){
    return 0.78;
  }
  
  float getAvgTemperature(){
    
    float solarConstant = getSolarConstant();
    float albedo = getAlbedo();
    float greenHouseEffect = getGreenHouseEffect();

    System.out.println(greenHouseEffect);
    
    float Te = pow((solarConstant * (1 - albedo)) / (4 * STEFAN_BOLTZMANN_CONST), 0.25);
    
    float Ts = Te * pow(1 / (1 - (greenHouseEffect / 2)), 0.25);
    
    return Ts;
  }
  
  
}
