void setup() {
    size(400, 400);
    pixelDensity(1); 
}

void draw() {
    loadPixels();

    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            float v = sin(x * 0.05 + frameCount * 0.05) +
                    sin(y * 0.05 + frameCount * 0.05) +
                    sin((x + y) * 0.05 + frameCount * 0.05) +
                    sin(dist(x, y, width/2, height/2) * 0.05 - frameCount * 0.05);
            
            float normalized = (v + 4) / 8.0;

            color c = lerpColor(color(0, 0, 255), color(255, 100, 0), normalized);
            
            int index = x + y * width;
            pixels[index] = c;
        }
    }

    updatePixels();
}
