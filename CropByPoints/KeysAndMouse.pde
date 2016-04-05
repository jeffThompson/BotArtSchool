
void keyPressed() {

  // esc to clear points
  if (key == 27) {
    key = 0;                // disable quit on esc
    pts = new PVector[0];
    index = 0;
    cropReady = false;
  }

  // return/enter key to save bounding box and quit
  if (cropReady && (keyCode == RETURN || keyCode == ENTER)) {

    // crop to nearest square (since drawing area is square and photo is not :)
    int minX = MAX_INT;
    int maxX = 0;
    int minY = MAX_INT;
    int maxY = 0;
    for (int i=0; i<pts.length; i++) {
      float x = pts[i].x;
      float y = pts[i].y;
      if (x < minX) minX = floor(x);
      if (x > maxX) maxX = ceil(x);
      if (y < minY) minY = floor(y);
      if (y > maxY) maxY = ceil(y);
    } 
    PImage output = createImage(maxX-minX, maxY-minY, RGB); 
    output.copy(img, minX, minY, maxX-minX, maxY-minY, 0, 0, output.width, output.height);
    output.save("temp.jpg");

    // get bounding box/rotation angle, save to txt file
    String bbox = 
      (pts[0].x-minX) + "," + (pts[0].y-minY) + ",0,0," +
      (pts[1].x-minX) + "," + (pts[1].y-minY) + "," + output.width + ",0," +
      (pts[2].x-minX) + "," + (pts[2].y-minY) + "," + output.width + "," + output.height + "," +
      (pts[3].x-minX) + "," + (pts[3].y-minY) + ",0," + output.height;
    String[] settings = {
      bbox, str(rotAngle), minX + "," + minY
    };
    saveStrings(sketchPath("") + "bbox.txt", settings);
    exit();
  }
}


void mousePressed() {

  // if all points set, let us adjust crop
  if (cropReady) {
    float minDist = MAX_FLOAT;
    for (int i=0; i<pts.length; i++) {
      float d = dist(mouseX, mouseY, pts[i].x, pts[i].y);
      if (d < minDist) {
        closest = i;
        minDist = d;
      }
    }
  }

  // if not done, add another point
  else {
    PVector p = new PVector(mouseX, mouseY);
    pts = (PVector[]) append(pts, p);
    index += 1;

    // if all 4 set, we're done
    if (index == 4) {
      cropReady = true;
    }
  }
}


// move closest point
void mouseDragged() {
  if (cropReady) {
    pts[closest].x = mouseX;
    pts[closest].y = mouseY;
  }
}