// Simulación de Sistemas Naturales
// Proyecto: Simulación de Terraformación
// Integrantes:
//  Ariana Alvarado Molina
//  María Paula Bolaños Apú
//  Marco Herrera González

// -------------------------------------------------------------------------------------

import peasy.*;
PeasyCam cam;
SpaceBackground spaceBg;
Planet planet;
Sun sun;
VariableModel variableModel;
PImage bgImage;

int previousMillis = 0;
int interval = 1000;

void setup() {
  
  size(1300, 800, P3D);  
  
  // Configuración de distancia de renderizado
  perspective(PI / 3.0, (float)width / (float)height, 0.1, 10000);
  
  // Configuración de la cámara
  cam = new PeasyCam(this, 1500);
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(3000); 
  
  spaceBg = new SpaceBackground(1500);  
  planet = new Planet(300);  
  sun = new Sun(0, 0, -2700, 20);
  variableModel = new VariableModel(255.0, 1.496e11, 0.0, 0.78, 28, 70, 2, 100000);
}

void draw() {
  
  spaceBg.display();
  planet.display();
  sun.display();
  
  int currentMillis = millis();
  
  // Actualiza el modelo cada segundo
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    variableModel.update();
  }
}
