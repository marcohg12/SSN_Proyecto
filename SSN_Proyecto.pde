// Simulación de Sistemas Naturales
// Proyecto: Simulación de Terraformación
// Integrantes:
//  Ariana Alvarado Molina
//  María Paula Bolaños Apú
//  Marco Herrera González


import peasy.*;
PeasyCam cam;
SpaceBackground spaceBg;

void setup() {
  size(1000, 800, P3D);  
  cam = new PeasyCam(this, 500);
  spaceBg = new SpaceBackground(300);  
}

void draw() {
  spaceBg.display(); 
}
