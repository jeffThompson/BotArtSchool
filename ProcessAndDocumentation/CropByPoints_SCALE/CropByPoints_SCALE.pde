
/*
CROP BY POINTS
 Jeff Thompson | 2016 | www.jeffreythompson.org
 
 A little utility program that loads in an image and lets
 the user set 4 crop points. This bounding box is saved to
 a text file, which is used to run ImageMagick to perform
 the crop and distortion. (We don't run the IM script here
 because... it doesn't work for some reason <sad face>.)
 
 */


//String imageFilename = "temp.jpg";    // image file to load
String imageFilename = "/Users/JeffThompson/Pictures/Eyefi/IMG_9337.JPG";
int menuBarHeight = 120;              // offset for height of window
color red = color(243, 86, 69, 200);  // a nice red to match everything else

PVector[] pts = new PVector[0];       // store x/y coords of crop points
int index = 0;                        // which crop point we're at
int closest = 0;                      // which point is closest? (for adjusting)
boolean cropReady = false;            // do we have 4 points yet?
PImage img;
int origWidth, origHeight;
PFont font;
float rotAngle = 0;


void setup() {
  surface.setTitle("Crop");
  noCursor();

  // font
  font = createFont("BellMT", 36);
  textFont(font, 18);

  // load last data (set of points, rotation, etc) from file
  String[] pointFile = loadStrings(sketchPath("") + "bbox.txt");


  // load image, rotate if specified, record original dims
  //PImage ti = loadImage(sketchPath("") + imageFilename);
  PImage ti = loadImage(imageFilename);
  if (pointFile != null) {
    rotAngle = Float.parseFloat(pointFile[1].trim());
  }
  PGraphics temp = createGraphics(ti.width, ti.height);
  temp.beginDraw();
  temp.pushMatrix();
  temp.translate(ti.width/2, ti.height/2);
  temp.rotate(radians(rotAngle));
  temp.imageMode(CENTER);
  temp.image(ti, 0, 0);
  temp.popMatrix();
  temp.endDraw();
  img = temp.get();

  origWidth = img.width;
  origHeight = img.height;

  // resize image
  img.resize(0, displayHeight-menuBarHeight);
  surface.setSize(img.width, img.height);

  // get previous points
  if (pointFile != null) {
    String[] prev = pointFile[0].split(",");
    pts = new PVector[4];

    pts[0] = new PVector(Float.parseFloat(prev[0]), Float.parseFloat(prev[1]));
    pts[0].x = map(pts[0].x, 0, origWidth, 0, img.width);
    pts[0].y = map(pts[0].y, 0, origHeight, 0, img.height);

    pts[1] = new PVector(Float.parseFloat(prev[4]), Float.parseFloat(prev[5]));
    pts[1].x = map(pts[1].x, 0, origWidth, 0, img.width);
    pts[1].y = map(pts[1].y, 0, origHeight, 0, img.height);

    pts[2] = new PVector(Float.parseFloat(prev[8]), Float.parseFloat(prev[9]));
    pts[2].x = map(pts[2].x, 0, origWidth, 0, img.width);
    pts[2].y = map(pts[2].y, 0, origHeight, 0, img.height);

    pts[3] = new PVector(Float.parseFloat(prev[12]), Float.parseFloat(prev[13]));
    pts[3].x = map(pts[3].x, 0, origWidth, 0, img.width);
    pts[3].y = map(pts[3].y, 0, origHeight, 0, img.height);
    cropReady = true;
  }
}


void draw() {
  image(img, 0, 0, width, height);

  // if done, darken crop area
  if (cropReady) {    
    if (mousePressed) stroke(0);
    else noStroke();
    fill(0, 150);

    beginShape();
    vertex(-1, -1);
    vertex(width+1, -1);
    vertex(width+1, height+1);
    vertex(-1, height+1);
    beginContour();
    for (int i=pts.length-1; i>=0; i-=1) {
      vertex(pts[i].x, pts[i].y);
    }
    endContour();
    endShape(CLOSE);

    if (!mousePressed) {
      fill(255);
      //noStroke();
      stroke(0);
      rectMode(CENTER);
      for (int i=pts.length-1; i>=0; i-=1) {
        rect(pts[i].x, pts[i].y, 4, 4);
      }
      rectMode(CORNER);
    } else {
      drawDot(pts[closest]);
    }
  }

  // otherwise, draw corner points
  else {
    
    // line from current mouse position to
    // prev point and first
    if (pts.length > 0) {
      stroke(0, 200);
      line(pts[pts.length-1].x, pts[pts.length-1].y, mouseX, mouseY);
      if (pts.length > 1) line(pts[0].x, pts[0].y, mouseX, mouseY);
    }

    for (int i=0; i<pts.length; i++) {
      if (i > 0) {
        stroke(0, 200);
        line(pts[i].x, pts[i].y, pts[i-1].x, pts[i-1].y);
      }
      drawDot(pts[i]);
    }
  }

  // show coords
  fill(255);
  noStroke();
  text("CURRENT:\nORIGINAL:", 25, 40);
  String s = mouseX + " x\n" + int(map(mouseX, 0, width, 0, origWidth)) + " x";
  text(s, 135, 40);
  s = mouseY + " y\n" + int(map(mouseY, 0, height, 0, origHeight)) + " y";
  text(s, 205, 40);

  // crosshairs
  stroke(0, 100);
  line(mouseX, 0, mouseX, height);
  line(0, mouseY, width, mouseY);
}


void drawDot(PVector p) {
  float x = p.x;
  float y = p.y;
  noStroke();
  fill(red);
  ellipse(x, y, 20, 20);
  stroke(0, 200);
  line(x-5, y, x+5, y);
  line(x, y-5, x, y+5);
}


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

    float scale = max((maxX-minX) * (origWidth/float(maxX-minX)), (maxY-minY) * (origHeight/float(maxY-minY))); 
    PImage output = createImage(int((maxX-minX) * scale), int((maxY-minY) * scale), RGB); 
    output.copy(img, minX, minY, maxX-minX, maxY-minY, 0, 0, output.width, output.height);
    output.save("temp.jpg");

    // convert to original image dims, save to txt file
    String b = map(pts[0].x-minX, 0, output.width, 0, output.width*scale) + "," + map(pts[0].y-minY, 0, output.height, 0, output.height*scale) + ",0,0," +
      map(pts[1].x-minX, 0, output.width, 0, output.width*scale) + "," + map(pts[1].y-minY, 0, output.height, 0, output.height*scale) + "," + output.width*scale + ",0," +
      map(pts[2].x-minX, 0, output.width, 0, output.width*scale) + "," + map(pts[2].y-minY, 0, output.height, 0, output.height*scale) + "," + output.width*scale + "," + output.height*scale + "," +
      map(pts[3].x-minX, 0, output.width, 0, output.width*scale) + "," + map(pts[3].y-minY, 0, output.height, 0, output.height*scale) + ",0," + output.height*scale;
    //String b = map(pts[0].x-minX, 0, img.width, 0, origWidth) + "," + map(pts[0].y-minY, 0, img.height, 0, origHeight) + ",0,0," +
    //           map(pts[1].x-minX, 0, img.width, 0, origWidth) + "," + map(pts[1].y-minY, 0, img.height, 0, origHeight) + "," + origWidth + ",0," +
    //           map(pts[2].x-minX, 0, img.width, 0, origWidth) + "," + map(pts[2].y-minY, 0, img.height, 0, origHeight) + "," + origWidth + "," + origHeight + "," +
    //           map(pts[3].x-minX, 0, img.width, 0, origWidth) + "," + map(pts[3].y-minY, 0, img.height, 0, origHeight) + ",0," + origHeight;
    String[] bbox = {
      b, str(rotAngle)
    };
    saveStrings(sketchPath("") + "bbox.txt", bbox);
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