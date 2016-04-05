
/*
CROP BY POINTS
 Jeff Thompson | 2016 | www.jeffreythompson.org
 
 A little utility program that loads in an image and lets
 the user set 4 crop points. This bounding box is saved to
 a text file, which is used to run ImageMagick to perform
 the crop and distortion. (We don't run the IM script here
 because... it doesn't work for some reason <sad face>.)
 
 */


String imageFilename = "temp.jpg";                // image file to load
//String imageFilename = "/Users/JeffThompson/Pictures/Eyefi/IMG_9337.JPG";

int maxWidth =          900;                      // max size of image
color red =             color(243, 86, 69, 200);  // a nice red to match everything else

PVector[] pts = new PVector[0];       // store x/y coords of crop points
int index = 0;                        // which crop point we're at
int closest = 0;                      // which point is closest? (for adjusting)
boolean cropReady = false;            // do we have 4 points yet?
PImage img;
int origWidth, origHeight;
PFont font;
float rotAngle = 0;
boolean positionSet = false;


void setup() {
  surface.setTitle("Crop");
  noCursor();

  // font
  //font = createFont("BellMT", 36);
  font = loadFont("BellMT-36.vlw");
  textFont(font, 18);

  // load last data (set of points, rotation, etc) from file
  String[] pointFile = loadStrings(sketchPath("") + "bbox.txt");

  // load image, rotate if specified
  PImage ti = loadImage(sketchPath("") + imageFilename);
  //PImage ti = loadImage(imageFilename);
  if (pointFile != null) {
    rotAngle = Float.parseFloat(pointFile[1].trim());
  }
  if (rotAngle != 0.0) {
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
  } else {
    img = ti.get();
  }

  // resize image
  img.resize(maxWidth, 0);
  surface.setSize(img.width, img.height);

  // get previous points
  if (pointFile != null) {
    String[] prev = pointFile[0].split(",");
    String[] offset = pointFile[2].split(",");
    float offsetX = Float.parseFloat(offset[0]);
    float offsetY = Float.parseFloat(offset[1]);
  
    pts = new PVector[4];
    pts[0] = new PVector(Float.parseFloat(prev[0])+offsetX, Float.parseFloat(prev[1])+offsetY);
    pts[1] = new PVector(Float.parseFloat(prev[4])+offsetX, Float.parseFloat(prev[5])+offsetY);
    pts[2] = new PVector(Float.parseFloat(prev[8])+offsetX, Float.parseFloat(prev[9])+offsetY);
    pts[3] = new PVector(Float.parseFloat(prev[12])+offsetX, Float.parseFloat(prev[13])+offsetY);
    cropReady = true;
  }
}


void draw() {
  if (!positionSet) {
    surface.setLocation(0,0);
    positionSet = true;
  }
  
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