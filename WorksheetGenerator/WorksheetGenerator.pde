
import processing.pdf.*;

/*
WORKSHEET GENERATOR
 Jeff Thompson | 2016 | jeffreythompson.org
 
 A worksheet generator for Bot Art School, presented at
 Abandon Normal Devices festival 2016. Creates randomized
 drawing prompts.
 
 */

String filename =         "BlankWorksheet.pdf";

int res =                 72;          // resolution (dpi)
float pageWidth =         8.3;         // page size (inches)
float pageHeight =        11.7;
float margin =            1 * res;     // margin (inches)
float gradeBoxSize =      1.5 * res;   // box for grade to go in (inches)
int lineSpacing =         30;          // spacing between prompt/artist/handle lines (px)

float lineOffset =        2;          // vertival offset for form lines
color lineColor =         color(0, 150);
float strokeWeight =      0.5;


void setup() {

  // create worksheet
  println("\nGenerating worksheet...");
  PGraphics w = createGraphics(ceil(pageWidth*res), ceil(pageHeight*res), PDF, filename);
  w.beginDraw();
  w.strokeWeight(0.5);
  
  // font
  PFont header = createFont("BellMT", 26);
  PFont info = createFont("BellMTItalic", 26);
  
  // box for drawing
  w.stroke(lineColor);
  w.noFill();
  float boxWidth = w.width - (margin * 2);
  float boxHeight = w.height - (margin * 4);
  w.rect(margin,margin, boxWidth,boxHeight);
  
  // logo
  PShape logo = loadShape("data/Logo.svg");
  logo.disableStyle();
  w.fill(244,89,69);
  w.noStroke();
  w.shape(logo, w.width-margin-gradeBoxSize, w.height-margin-gradeBoxSize, gradeBoxSize, gradeBoxSize);
  
  // info variables
  float y = w.height-margin;
  float lineStart = margin + textWidth("Assignment: ");
  float lineEnd = w.width-margin-gradeBoxSize-20;
  w.fill(0);
  
  // grade
  w.noStroke();
  w.textFont(header, 13);
  w.text("Grade:", margin, y);
  w.stroke(lineColor);
  w.line(lineStart,y+lineOffset, lineEnd/2,y+lineOffset);
  
  // artist name
  y -= lineSpacing;
  w.noStroke();
  w.textFont(header, 13);
  w.text("Artist:", margin, y);              // header
  w.stroke(lineColor);
  w.line(lineStart,y+lineOffset, lineEnd,y+lineOffset);
  
  // assignment
  //println("- assignment...");
  y -= lineSpacing;
  w.stroke(lineColor);
  w.line(lineStart,y+lineOffset, lineEnd,y+lineOffset);
  y -= lineSpacing;
  w.noStroke();
  w.textFont(header, 13);
  w.text("Assignment:", margin,y);
  w.stroke(lineColor);
  w.line(lineStart,y+lineOffset, lineEnd,y+lineOffset);
  
  // save it
  println("- saving to PDF...");
  w.endDraw();
  w.dispose();
  
  println("DONE!");
  exit();
}