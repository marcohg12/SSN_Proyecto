// Simulación de Sistemas Naturales
// Proyecto: Simulación de Terraformación
// Integrantes:
//  Ariana Alvarado Molina
//  María Paula Bolaños Apú
//  Marco Herrera González

// -------------------------------------------------------------------------------------

import peasy.*;
import controlP5.*;
PeasyCam cam;
SpaceBackground spaceBg;
Planet planet;
Sun sun;
VariableModel variableModel;
Boolean displayControls;
ControlP5 cp5;
Slider distanceSlider;
Slider temperatureSlider;
Slider greenHouseEffectSlider;
Slider waterPercSlider;
Slider icePercSlider;
Slider oxigenPercSlider;
Slider vegetationPercSlider;
Slider algaePercSlider;
Slider yearsPerSecondSlider;

void setup() {
  
  size(1300, 800, P3D);  
  
  // Configuración de distancia de renderizado
  perspective(PI / 3.0, (float)width / (float)height, 0.1, 10000);
  
  // Configuración de la cámara
  cam = new PeasyCam(this, 1500);
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(3000); 
  
  // Modelo de variables
  //avgTemperature, distanceToTheSun, oxigenPerc, greenHouseEffect, vegetationPerc, waterPerc, icePerc, yearsPerSecond, algaePerc
  variableModel = new VariableModel(255.0, 1.496e11, 0.0, 0.78, 0, 0, 0, 0, 0.0);
  
  float initialAvgTemperature = variableModel.avgTemperature;
  float initialGreenHouseEffect = variableModel.greenHouseEffect;
  float initialDistanceToTheSun = variableModel.distanceToTheSun / 1.496e11;
  float initialWaterPerc = variableModel.waterPerc;
  float initialIcePerc = variableModel.icePerc;
  float initialVegetationPerc = variableModel.vegetationPerc;
  float initialAlgaePerc = variableModel.algaePerc;
  float initialOxigenPerc = variableModel.oxigenPerc;
  
  // Configuración de controles
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  cp5.addButton("togglePause")
    .setPosition(10, 760)
    .setSize(100, 30)
    .setLabel("Variable's panel");
  
  distanceSlider = cp5.addSlider("setDistanceValue") 
    .setPosition(10, 10)
    .setSize(200, 20)
    .setRange(0.0, 2.0)  
    .setValue(initialDistanceToTheSun)
    .setLabel("Distance to the Sun (AU)")
    .hide();
  
  temperatureSlider = cp5.addSlider("setTemperatureValue") 
    .setPosition(10, 40)
    .setSize(200, 20)
    .setRange(0.0, 5000.0)            
    .setValue(initialAvgTemperature)
    .setLabel("Average Temperature")
    .hide();
  
  greenHouseEffectSlider = cp5.addSlider("setGreenHouseEffect") 
    .setPosition(10, 70)
    .setSize(200, 20)
    .setRange(0.0, 1.0)            
    .setValue(initialGreenHouseEffect)
    .setLabel("Greenhouse effect")
    .hide();
 
 waterPercSlider = cp5.addSlider("setWaterPerc") 
    .setPosition(10, 100)
    .setSize(200, 20)
    .setRange(0.0, 100.0)            
    .setValue(initialWaterPerc)
    .setLabel("Water %")
    .hide();
  
  icePercSlider = cp5.addSlider("setIcePerc") 
    .setPosition(10, 130)
    .setSize(200, 20)
    .setRange(0.0, 100.0)            
    .setValue(initialIcePerc)
    .setLabel("Ice %")
    .hide();
  
  oxigenPercSlider = cp5.addSlider("setOxigenPerc") 
    .setPosition(10, 160)
    .setSize(200, 20)
    .setRange(0.0, 100.0)            
    .setValue(initialOxigenPerc)
    .setLabel("Oxigen %")
    .hide();
  
  vegetationPercSlider = cp5.addSlider("setVegetationPerc") 
    .setPosition(10, 190)
    .setSize(200, 20)
    .setRange(0.0, 100.0)            
    .setValue(initialVegetationPerc)
    .setLabel("Vegetation %")
    .hide();
  
  algaePercSlider = cp5.addSlider("setAlgaePerc") 
    .setPosition(10, 220)
    .setSize(200, 20)
    .setRange(0.0, 100.0)            
    .setValue(initialAlgaePerc)
    .setLabel("Algae %")
    .hide();
    
  yearsPerSecondSlider = cp5.addSlider("setYearsPerSecond") 
    .setPosition(10, 250)
    .setSize(200, 20)
    .setRange(0, 10000)            
    .setValue(1)
    .setLabel("Years per second")
    .hide();
  
  spaceBg = new SpaceBackground(1500);  
  planet = new Planet(300);  
  sun = new Sun(0, 0, -3000, 35);
  // mínimo -3000, 35
  // máximo -3500, 3200
  displayControls = false;
}

// Funciones para controlar la asignación de valores al modelo 
// por medio de los sliders

void setDistanceValue(float value) {
  variableModel.distanceToTheSun = value * 1.496e11;
}

void setTemperatureValue(float value) {
  variableModel.avgTemperature = value;
}

void setYearsPerSecond(int value) {
  variableModel.yearsPerSecond = value;
}

void setGreenHouseEffect(float value) {
  variableModel.greenHouseEffect = value;
}

void setWaterPerc(float value) {
  variableModel.updateWaterPerc(value);
}

void setIcePerc(float value) {
  variableModel.updateIcePerc(value);
}

void setOxigenPerc(float value) {
  variableModel.oxigenPerc = value;
}

void setVegetationPerc(float value) {
  variableModel.vegetationPerc = value;
}

void setAlgaePerc(float value) {
  variableModel.algaePerc = value;
}

void draw() {
  
  spaceBg.display();
  planet.display();
  sun.display();
  
  // Actualiza el modelo cada segundo
  if (frameCount % 60 == 0) {
    variableModel.update();
  }
  
  float distanceAU = distanceSlider.getValue();  
  sun.updateDistance(distanceAU);
  
  //float waterPerc = waterPercSlider.getValue() / 100.0;  
  //planet.updateWaterTexture(waterPerc); 
  
  float waterPerc = waterPercSlider.getValue() / 100.0;  
  float vegetationPerc = vegetationPercSlider.getValue() / 100.0;  
  float icePerc = icePercSlider.getValue() / 100.0; 
  float algaePerc = algaePercSlider.getValue() / 100.0; 
  planet.updateTextures(waterPerc, vegetationPerc, icePerc, algaePerc); 
  
  // Actualiza los valores en los controles  
  temperatureSlider.setValue(variableModel.avgTemperature);
  icePercSlider.setValue(variableModel.icePerc);
  waterPercSlider.setValue(variableModel.waterPerc);
  vegetationPercSlider.setValue(variableModel.vegetationPerc);
  algaePercSlider.setValue(variableModel.algaePerc);
  oxigenPercSlider.setValue(variableModel.oxigenPerc);
  greenHouseEffectSlider.setValue(variableModel.greenHouseEffect);
  
  if (displayControls) {
    distanceSlider.show();
    temperatureSlider.show();
    yearsPerSecondSlider.show();
    greenHouseEffectSlider.show();
    algaePercSlider.show();
    waterPercSlider.show();
    icePercSlider.show();
    vegetationPercSlider.show();
    oxigenPercSlider.show();
  } else {
    distanceSlider.hide();
    temperatureSlider.hide();
    yearsPerSecondSlider.hide();
    greenHouseEffectSlider.hide();
    algaePercSlider.hide();
    waterPercSlider.hide();
    icePercSlider.hide();
    vegetationPercSlider.hide();
    oxigenPercSlider.hide();
  }
  
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  
  cam.setActive(true);
  if (distanceSlider.isInside() || temperatureSlider.isInside() || yearsPerSecondSlider.isInside()
      || greenHouseEffectSlider.isInside() || algaePercSlider.isInside() || oxigenPercSlider.isInside()
      || icePercSlider.isInside() || waterPercSlider.isInside() || vegetationPercSlider.isInside()) {
    cam.setActive(false);
  }
}

void togglePause() {
  displayControls = !displayControls;
  if (displayControls) {
    cp5.getController("togglePause").setLabel("Hide");
  } else {
    cp5.getController("togglePause").setLabel("Variable's panel");
  }
}
