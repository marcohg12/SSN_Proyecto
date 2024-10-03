// Simulación de Sistemas Naturales
// Proyecto: Simulación de Terraformación
// Integrantes:
//  Ariana Alvarado Molina
//  María Paula Bolaños Apú
//  Marco Herrera González

import peasy.*;
PeasyCam cam;
SpaceBackground spaceBg;
Planet planet;
Sun sun;

void setup() {
  size(1300, 800, P3D);  
  cam = new PeasyCam(this, 1000);
  spaceBg = new SpaceBackground(300);  
  //planet = new Planet(300);  
  sun = new Sun(0, 0, 0, 300);
}

void draw() {
  spaceBg.display(); 
  //planet.display();
  sun.display();
}
