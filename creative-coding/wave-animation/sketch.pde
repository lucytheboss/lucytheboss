int waveCount = 8;
float t = 0;

ArrayList<Fish> fishes;
ArrayList<Drop> drops;
ArrayList<BlockySeaweed> seaweeds;

boolean charging = false;
float chargeStartTime = 0;
float maxChargeTime = 2.0;

void setup() {
  size(800, 800);
  noStroke();
  fishes = new ArrayList<Fish>();
  drops = new ArrayList<Drop>();
  seaweeds = new ArrayList<BlockySeaweed>();

  for (int i = 0; i < 5; i++) {
    fishes.add(new Fish());
  }

  for (int i = 0; i < 50; i++) {
    float x = random(40, width - 40);
    seaweeds.add(new BlockySeaweed(x));
  }
}

void draw() {
  background(100, 180, 255);
  drawSun();
  drawSunReflection();
  drawWaves();
  drawFloatingShapes();
  drawBlockySeaweed();

  for (Fish f : fishes) {
    f.update();
    f.display();
  }

  for (int i = drops.size() - 1; i >= 0; i--) {
    Drop d = drops.get(i);
    d.update();
    d.display();
    if (d.finished()) {
      drops.remove(i);
    }
  }

  if (charging) {
    float heldTime = constrain((millis() / 1000.0) - chargeStartTime, 0, maxChargeTime);
    float sizeFactor = map(heldTime, 0, maxChargeTime, 20, 80);
    fill(180, 220, 255, 150);
    noStroke();
    ellipse(mouseX, mouseY, sizeFactor, sizeFactor);
  }

  t += 0.02;
}

void mousePressed() {
  charging = true;
  chargeStartTime = millis() / 1000.0;
}

void mouseReleased() {
  if (charging) {
    float heldTime = constrain((millis() / 1000.0) - chargeStartTime, 0, maxChargeTime);
    float sizeFactor = map(heldTime, 0, maxChargeTime, 20, 80);
    drops.add(new Drop(mouseX, mouseY, sizeFactor));
    charging = false;
  }
}

void drawWaves() {
  for (int i = 0; i < waveCount; i++) {
    float y = height/2 + i * 30;
    int c1 = color(0, 120 + i*10, 200 + i*10);
    int c2 = color(0, 100 + i*15, 180 + i*15);
    fill(lerpColor(c1, c2, 0.5), 160);

    beginShape();
    for (int x = 0; x <= width; x += 20) {
      float angle = (x * 0.02) + (t + i * 0.3);
      float yOffset = sin(angle) * 20;
      vertex(x, y + yOffset);
    }
    vertex(width, height);
    vertex(0, height);
    endShape(CLOSE);
  }
}

void drawSun() {
  float sunY = 150;
  fill(255, 220, 0);
  ellipse(width/2, sunY, 120, 120);

  stroke(255, 220, 0, 100);
  strokeWeight(2);
  for (int i = 0; i < 12; i++) {
    float angle = radians(i * 30);
    float x1 = width/2 + cos(angle) * 70;
    float y1 = sunY + sin(angle) * 70;
    float x2 = width/2 + cos(angle) * 110;
    float y2 = sunY + sin(angle) * 110;
    line(x1, y1, x2, y2);
  }
  noStroke();
}

void drawSunReflection() {
  for (int i = 0; i < 20; i++) {
    float size = random(10, 30);
    float x = random(width);
    float y = random(height/2, height * 0.9);
    fill(255, 255, 200, 150);
    ellipse(x, y, size, size / 2);
  }
}

void drawFloatingShapes() {
  for (int i = 0; i < 10; i++) {
    float x = width * noise(i * 0.1 + t * 0.2);
    float y = height * 0.45 + sin(t + i) * 10;

    int shapeType = i % 3;
    fill(255, 255, 255, 140);
    noStroke();
    pushMatrix();
    translate(x, y);
    rotate(t * 0.5 + i);

    if (shapeType == 0) {
      ellipse(0, 0, 20, 20);
    } else if (shapeType == 1) {
      rectMode(CENTER);
      rect(0, 0, 18, 18);
    } else {
      triangle(-10, 10, 0, -10, 10, 10);
    }

    popMatrix();
  }
}

void drawBlockySeaweed() {
  for (BlockySeaweed b : seaweeds) {
    b.update();
    b.display();
  }
}

class BlockySeaweed {
  float baseX, phase, speed;
  int segments;
  float blockSize;
  float noiseOffset;
  color baseColor;

  BlockySeaweed(float x) {
    baseX = x;
    phase = random(TWO_PI);
    speed = random(0.005, 0.015);
    segments = int(random(6, 12));
    blockSize = int(random(6, 9));
    noiseOffset = random(1000);
    baseColor = color(20 + random(60), 150 + random(80), 90 + random(60), 200);
  }

  void update() {
    phase += speed;
  }

  void display() {
    for (int i = 0; i < segments; i++) {
      float sway = sin(phase + i * 0.5) * 5;
      float noiseSway = map(noise(noiseOffset + i * 0.3), 0, 1, -3, 3);
      float x = baseX + sway + noiseSway;
      float y = height - i * blockSize - 10;
      fill(baseColor);
      rect(x, y, blockSize, blockSize);
    }
  }
}

class Fish {
  float x, y, speed, size, offset;

  Fish() {
    x = random(width);
    y = random(height/2, height * 0.9);
    speed = random(1, 2.5);
    size = random(30, 50);
    offset = random(TWO_PI);
  }

  void update() {
    x += speed;
    y += sin(t * 2 + offset) * 0.5;
    if (x > width + 50) x = -50;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(sin(t + offset) * 0.3);
    fill(255, 100, 100);
    ellipse(0, 0, size, size/2);
    triangle(-size/2, 0, -size, -size/4, -size, size/4);
    popMatrix();
  }
}

class Drop {
  float x, y, size, vy, alpha;

  Drop(float x_, float y_, float s) {
    x = x_;
    y = y_;
    size = s;
    vy = map(s, 20, 80, 0.5, 1.5);
    alpha = 255;
  }

  void update() {
    y -= vy;
    alpha -= 2;
  }

  void display() {
    fill(150, 200, 255, alpha);
    noStroke();
    ellipse(x, y, size, size);
  }

  boolean finished() {
    return alpha <= 0;
  }
}
