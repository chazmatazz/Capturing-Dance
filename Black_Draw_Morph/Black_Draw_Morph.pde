// draws on SimpleOpenNI DepthMap3d example

import SimpleOpenNI.*;

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;

Stage stage;

SimpleOpenNI context;

Minim minim;
AudioInput in;
FFT fft;

char mode, submode;
boolean mirrorOn, record, rotateOn, autoErase, freeze3D, kill;
int modeNumber;
int bgColor = 55;
int eraseTH = 50;
boolean eraseTHRandomize = false;

// Font for onscreen naming
PFont f;

// Size of kinect image
int w = 640;
int h = 480;

//Angle of rotation
float a = 0;

//Audio
float freq_aver=0;
boolean firstPeak;
int timePeak, gapPeak;

void setup() {
  size(1280,720, P3D);
  smooth();
  noCursor();
  
  f = loadFont("Helvetica-24.vlw");
  textFont(f, 24);
  textAlign(CENTER);
  
  stage = new Stage();
  context = new SimpleOpenNI(this);

  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }

  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO,1024);
  fft = new FFT(in.bufferSize(), in.sampleRate());


  mirrorOn = true;
  autoErase = true;
  
  record = false;
  rotateOn = false;
  freeze3D = true;
  autoErase = true;
  modeNumber = 1;
  mode = 'm';

  // Audio
  firstPeak = false;
  timePeak = 0;
  gapPeak = 1000;
  
  background(bgColor);
}


void draw() {
    // update the cam
  context.update();
  

  translate(width/2,height/2,-50);
  audio_anal();
  stage.run(capture());
}

void audio_anal() {
  fft.forward(in.left);
  int counter = 0;
  float sum = 0;
  float freq_sum = 0;
  for (int i = 0; i < fft.specSize(); i++) {
    if (fft.getBand(i)>10) {
      sum += fft.getBand(i);
      freq_sum += i;
      counter++;
    }
  }

  if(counter > 0 && gapPeak > 500 && !firstPeak) {
    firstPeak = true;
    timePeak = millis();
  }
  else if(counter > 0) {
    freq_aver=freq_sum/counter;
    firstPeak = false;
    timePeak = millis();
    gapPeak = 0;
  }
  else {
    gapPeak = millis() - timePeak;
    firstPeak = false;
  }

  if (firstPeak) {  
    record=true;
    println("RECORD!!");
  }
}
/*
return an ArrayList of points from the point cloud
*/
ArrayList capture() {
  ArrayList<PVector> ret = new ArrayList<PVector>();
  
    int[]   depthMap = context.depthMap();
  int     steps   = 10;
  int     index;
  PVector realWorldPoint;

  PVector[] realWorldMap = context.depthMapRealWorld();
  for(int y=0;y < context.depthHeight();y+=steps)
  {
    for(int x=0;x < context.depthWidth();x+=steps)
    {
      index = x + y * context.depthWidth();
      if(depthMap[index] > 0)
      { 
        // draw the projected point
        realWorldPoint = realWorldMap[index];
        ret.add(new PVector(realWorldPoint.x/4, -realWorldPoint.y/4, realWorldPoint.z/4));  // make realworld z negative, in the 3d drawing coordsystem +z points in the direction of the eye
      }
    }
  } 
  
  return ret;
}


void keyPressed() {

  /*Right and Left Arrow Keys cycle through mode numbers*/
  if (key == CODED) {
    if (keyCode == RIGHT) {
      modeNumber++;
      if (modeNumber > 5) modeNumber = 0;
    } 
    else if (keyCode == LEFT) {
      modeNumber--;
      if (modeNumber < 0) modeNumber = 4;
    }
  }

  if(key == 'c' || key == 'f') modeNumber = 0;
  else if(key == 'm') modeNumber = 1;  
  else if(key == 'b') modeNumber = 2;
  else if(key == 'p') modeNumber = 3;
  else if(key == 'o') modeNumber = 3;
  else if(key == 'd') modeNumber = 4;

  if(modeNumber == 0) {
    autoErase = true;
    eraseTH = 0;
    mirrorOn = true;
    mode = 'c'; //capture and play sequences from the past in various ways
    submode = 'f';
    stage.modeName = "Capture";
  }
  else if(modeNumber == 1) {
    autoErase = true;
    eraseTH = 90;
    bgColor = 55;
    mirrorOn = true;
    mode = 'm'; //morph playback
    stage.modeName = "Morph";
  }

  ////////////////////////////////


  if(modeNumber == 2) {
    autoErase = true;
    eraseTH = 0;
    mirrorOn = true;
    mode = 'c';
    submode = 'b';  //breathe single frame
    stage.modeName = "Breathe";
  } 

  else if(modeNumber == 3) {
    autoErase = true;
    eraseTH=0;
    mirrorOn=true;
    mode = 'c';
    submode = 'p';  //straight playback of multiple frames
    stage.modeName = "Playback";
  }

  else if(modeNumber == 4) {
    autoErase = true;
    eraseTH = 0;
    mirrorOn = true;
    mode = 'c';
    submode = 'o'; //flying points from still to still
    stage.modeName = "Fly";
  }
  else if(modeNumber == 5) {
    stage.path.dotAlpha = 0;
    autoErase = false;
    mirrorOn = true;
    mode = 'd'; //Draw
    stage.modeName = "Draw";
  }

  /*Playback functionality: Mirror and Rotate*/
  if(key == CODED && keyCode == SHIFT) {
    mirrorOn = !mirrorOn; //just live
  }

  if(key == ENTER || key == RETURN) {
    rotateOn = !rotateOn;
    if(rotateOn) {
      freeze3D = true;
    }
  }  

  /*RECORD*/
  if(key == 32 && mode == 'c') {  // Spacebar
    record = true;
    println("RECORD");
  }

  /*KILL*/
  if(key == CODED && keyCode == CONTROL) {
    kill = true;
  }
  else {
    kill = false;
  }
 

  /* erasing background or not*/
  if (key == CODED && keyCode == ALT) {
    autoErase=!autoErase;
  }
  
  if (key == 'k') {
      eraseTH++;
    } 
  else if (key == 'l') {
      eraseTH--;
    }
  
  /*Don't worry about this for now*/
  if(key == TAB) {
    freeze3D = !freeze3D;
    if(!freeze3D) {
      rotateOn = false;
    }
  }
  
}

