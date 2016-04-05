
import processing.pdf.*;
import java.nio.file.Files;

/*
WORKSHEET GENERATOR
 Jeff Thompson | 2016 | jeffreythompson.org
 
 A worksheet generator for Bot Art School, presented at
 Abandon Normal Devices festival 2016. Creates randomized
 drawing prompts.
 
 TO DO/THINK ABOUT
 + add id number for assignment (easier upload later?)
 
 */

String artistName =      "Jeff Thompson";
String twitterHandle =   "jeffthompson_";

int additionalOfs =       20;          // num of additional "of", essentially weighted random for verbs
float chanceNoTopic =     0.5;         // ex: make a painting using horns
float chanceUseApproach = 0.3;         // ex: make a painting about your relationship to horns
float chanceSecondThing = 0.5;         // ex: make a painting with tears and whispers

int res =                 72;          // resolution (dpi)
int pageWidth =           9;           // page size (inches)
int pageHeight =          12;
float margin =            1 * res;     // margin (inches)
float gradeBoxSize =      1.5 * res;   // box for grade to go in (inches)
int lineSpacing =         30;          // spacing between prompt/artist/handle lines (px)

float lineOffset =        2;          // vertival offset for form lines
color lineColor =         color(0, 150);
float strokeWeight =      0.5;

String promptsFile = "AssignmentsGiven.txt";
int index = 0;


void setup() {
  println("WELCOME TO BOT ART SCHOOL");
  println("[starting random assignment generator]");
  
  // set index based on previoustry {
  try {
    String[] prev = loadStrings(promptsFile);
    String[] last = split(prev[prev.length-1], ",");
    index = Integer.parseInt(last[0]) + 1;
  } catch (Exception e) {
    index = 0;
  }
  
  // load word lists
  println("\nLoading assignment corpus...");
  String[] mediaList = loadStrings("data/media.txt");
  String[] doList = loadStrings("data/do.txt");
  String[] ofs = new String[additionalOfs];
  for (int i=0; i<additionalOfs; i++) {
    ofs[i] = "of";
  }
  String[] verbs = concat(loadStrings("data/verbs.txt"), ofs); 
  String[] approaches = loadStrings("data/approaches.txt");
  String[] pluralNouns = loadStrings("data/pluralNouns.txt");
  String[] topics = loadStrings("data/topics.txt");
  topics = (String[]) concat(pluralNouns, topics);
  println("- loaded");

  // generate assignment terms
  println("\nGenerating assignment...");
  String media = randomItem(mediaList);
  String doWord = randomItem(doList);
  doWord = doWord.substring(0,1).toUpperCase() + doWord.substring(1, doWord.length());
  println("- do:       " + doWord);
  String verb = randomItem(verbs);
  println("- verb:     " + verb);  
  String approach = randomItem(approaches);
  println("- approach: " + approach);
  String topic = randomItem(topics);
  String topic2 = randomItem(topics);
  println("- topic:    " + topic);
  String material = randomItem(pluralNouns);
  String material2 = randomItem(pluralNouns);
  println("- material: " + material);
  String article = "a";
  if ("aeiou".indexOf(media.substring(0)) >= 0) {
    article = "an";
  }
  println("- article:  " + article);

  // build assignment string
  String assignment = "";
  
  // <do> <a/an> <media> using <material>
  // ie: Build a collage using practices.
  if (random(1) < chanceNoTopic) {
    println("- grammar: <do> <a/an> <media> using <material>");
    assignment = doWord + " " + article + " " + media;
    assignment += " with ";
    assignment += material;
    if (random(1) < chanceSecondThing) assignment += " and " + material2;
    assignment += ".";
  }
  else {
    // <do> <a/an> <media> <verb> <approach> <topic>.
    // ie: Create a drawing exploring your relationship to birds.
    if (random(1) < chanceUseApproach) {
      println("- grammar: <do> <a/an> <media> <verb> <approach> <topic>.");
      if (approach.equals("of")) approach = "";
      assignment = doWord + " " + article + " " + media + " " + verb + " " + approach + " " + topic + ".";
    }
    
    // <do> <a/an> <media> <verb> <topic>.
    // ie: Make a sculpture about pattern.
    else {
      println("- grammar: <do> <a/an> <media> <verb> <topic>.");
      assignment = doWord + " " + article + " " + media + " " + verb + " " + topic;
      if (random(1) < chanceSecondThing) assignment += " and " + topic2;
      assignment += ".";
    }
  }
  
  // a little cleanup
  // remove extra spaces
  println("Running string cleanup...");
  assignment = assignment.replaceAll("\\s+", " ");
  
  // done generating the prompt!
  println("\nAssignment:\n\"" + assignment + "\"");

  // create worksheet
  println("\nGenerating worksheet...");
  PGraphics w = createGraphics(pageWidth*res, pageHeight*res, PDF, "Worksheet.pdf");
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
  
  // id # below logo
  w.fill(150);
  w.noStroke();
  w.textFont(header, 13);
  w.textAlign(CENTER);
  w.text(nf(index, 5), w.width-margin-gradeBoxSize/2, w.height-margin+20);
  w.textAlign(LEFT);
  
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
  w.textFont(info, 13);
  String s = "";
  if (!artistName.equals("")) {              // if name present
    s = artistName;
    if (!twitterHandle.equals("")) {         // optional: add twitter handle
      s += " (@" + twitterHandle + ")";
    }
  }
  else if (!twitterHandle.equals("")) {      // no name, twitter only
    s = "@" + twitterHandle;
  }
  else {
    println("- ERROR: NO NAME!");            // no name = error
  }
  w.text(s, lineStart,y);
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
  
  // write in assignment
  w.textFont(info, 13);
  
  // if assignment fits on one line...
  w.noStroke();
  if (textWidth(assignment) < lineEnd-lineStart) {
    //println("  - assignment fits on one line!");
    w.text(assignment, lineStart,y);
  }
  
  // ...if it won't, split it into two lines
  else {
    //println("  - assignment too long, splitting!");
    String[] words = assignment.split(" ");
    String s1 = "";
    int splitPoint = 0;
    for (int i=0; i<words.length; i++) {
      if (textWidth(s1 + words[i]) > lineEnd-lineStart) {
        break;
      }
      s1 += words[i] + " ";
      splitPoint = i;
    }  
    String s2 = "";
    for (int j=splitPoint+1; j<words.length; j++) {
     s2 += words[j] + " ";
    }
    w.text(s1, lineStart + 2,y);
    w.text(s2, lineStart + 2,y+lineSpacing);
  }
  
  // save it
  println("- saving to PDF...");
  w.endDraw();
  w.dispose();
  
  // save copy for my records
  // via: http://stackoverflow.com/a/30327959/1167783
  println("- archiving PDF...");
  try {
    String a = assignment.replaceAll("\\s+", "_");
    File src = new File(sketchPath("") + "Worksheet.pdf");
    File dst = new File(sketchPath("") + "Worksheets/" + a + "pdf");
    dst.getParentFile().mkdirs();
    Files.copy(src.toPath(), dst.toPath());
  }
  catch (Exception e) {
    println("  - error archiving, sorry!");
  }
  
  // log assignment prompt
  println("- logging assigment prompt...");
  String entry = index + "," + assignment + "," + artistName + "," + twitterHandle;
  try {
    String[] prev = loadStrings(promptsFile);
    String[] output = append(prev, entry);
    saveStrings(promptsFile, output);
  } catch (Exception e) {
    String[] output = { entry };
    saveStrings(promptsFile, output);
  }

  // done!
  println("\nAssignment successfully generated. Good luck!");
  println("\"" + assignment + "\"");
  exit();
}


// return random item from an array
String randomItem(String[] l) {
  return l[int(random(l.length))];
}