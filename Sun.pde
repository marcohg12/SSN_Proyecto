class Sun {
  PVector position;
  float radius;

  Sun(float x, float y, float z, float radius) {
    this.position = new PVector(x, y, z);
    this.radius = radius;
  }

  void display() {
    // Iluminación
    //ambientLight(249, 255, 116); 
    pointLight(250, 255, 224, position.x, position.y, position.z); 
    directionalLight(250, 255, 224, 0, 0, -1);     // adelante
    directionalLight(250, 255, 224, 0, 0, 1);      // atras 
    directionalLight(0, 0, 0, 0, -1, 0);         // abajo
    directionalLight(0, 0, 0, 0, 1, 0);          // arriba
    directionalLight(0, 0, 0, -1, 0, 0);         // izq
    directionalLight(0, 0, 0, 1, 0, 0);          // derecha

    // Dibuja la esfera del sol
    pushMatrix();
    translate(position.x, position.y, position.z);
    noStroke();
    fill(249, 255, 116);
    sphereDetail(50); 
    sphere(radius);
    popMatrix();

  }
}
