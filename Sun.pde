class Sun {
  PVector position;
  float radius;

  Sun(float x, float y, float z, float radius) {
    this.position = new PVector(x, y, z);
    this.radius = radius;
  }

  void display() {
    pushMatrix();
    translate(position.x, position.y, position.z);

    ambientLight(150, 150, 150);
    pointLight(250, 255, 224, position.x, position.y, position.z);
    directionalLight(255, 255, 255, 0, 0, 1);   //frente
    directionalLight(255, 255, 255, 0, 0, -1);  //atrás
    directionalLight(255, 255, 200, 1, 0, 0);   //derecha
    directionalLight(255, 255, 200, -1, 0, 0);  //izq
    directionalLight(255, 255, 200, 0, 1, 0);   //arriba
    directionalLight(255, 255, 200, 0, -1, 0);  //abajo

    // Dibuja el Sol sin textura
    noStroke();
    fill(255, 255, 255);
    sphereDetail(50);
    sphere(radius);

    int numLayers = 30;
    for (int i = 1; i <= numLayers; i++) {
      float alpha = map(i, 1, numLayers, 30, 0);
      fill(255, 200, 100, alpha);
      noStroke();
      float haloSize = radius + i * 5;
      sphere(haloSize);
    }
    popMatrix();
  }

  void updateDistance(float distanceAU) {

    this.position.z = map(distanceAU, 0, 2, -3500, -3000);

    /*if (distanceAU == 1.0) {
      this.radius = 2000;
    } else {
      this.radius = map(distanceAU, 0, 2, 3200, 35);
    }*/
    
    this.radius = map(distanceAU, 0, 2, 3200, 35);
    //println("Distancia en AU: " + distanceAU + ", Posición Z: " + position.z + ", Radio: " + radius);
  }
}
