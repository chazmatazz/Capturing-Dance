class Stage {

  ArrayList<Sequence> sequences = new ArrayList<Sequence>();
  ArrayList<PVector> closests = new ArrayList<PVector>();
  ArrayList<PVector> farthests = new ArrayList<PVector>();

  Morpher morpher;
  Pathway path = new Pathway(100);

  float a = 0; 
  float fadeAttenuator = fadeAttenuator = (255-bgColor)/255;  //attenuate fade rate to whatever background color we have
  String modeName = "";

  int eraseCounter = 0;

  Stage() {
  }

  void run(ArrayList<PVector> live) { //choose a mode
      
      if(rotateOn) {
      a += 0.015 + freq_aver/500;
    }

    if(freeze3D) {
      rotateY(a);
    }
    
    if(kill) {
      println("KILL ALL");
      killall();
    }
    
    //Auto-erase background
    if(autoErase) {
        eraseCounter++;
        if(eraseCounter > eraseTH) {
          erase();
          eraseCounter = 0;
          if(eraseTHRandomize) {
            eraseTH = int(random(0,100));
          }
       }
    }

    //in straight playback mode, display the live point cloud
    if(mirrorOn) {
      mirror(live);
    }

    //in sequence mode, display live point cloud AND record, capture and move sequences
    if(mode == 'c') { //enter capture mode

      if(record) {
        //println("RECORD!"); 
        record(live);
      }

      if(somethingCapturing()) {
        capture(live);
        //println("SOMETHINGCAPTURING? " + somethingCapturing);
      }

      if(submode == 'o' && somethingMoving() && !somethingCapturing()) {
        move();
        //println("SOMETHINGMOVING? " + somethingMoving);
      }
      else if(submode == 'p' || submode == 'f' || submode == 'b') {
        play();
      }

      if(sequences.size() > 0) {
        checkfordead();
      }
    }
    //in morph mode, morph on top of the live point cloud, set angle to be straight ahead
    else if(mode == 'm') {
      a = 0;
      morph(live);
    }
    else if(mode == 'd') {
     drawPath(live);      
    }
    
    displayModeName();
  }
  
  void displayModeName() {
    
      println(modeName);
    
      // Display Mode Name
      pushMatrix(); 
      rotate(0);     
      fill(255);
      text(modeName, (width/2), (height/2));
      popMatrix();
  }
  
  void erase() {
    background(bgColor);
  }

  // display live point cloud
  void mirror(ArrayList<PVector> live) {

    for(int i=0; i < live.size(); i++) { 
      PVector thisPoint = (PVector)live.get(i); 
      pushMatrix();
      translate(thisPoint.x,thisPoint.y,thisPoint.z);

      // Draw a point
      stroke(255);
      point(0,0);
      popMatrix();

    }
  }

  void record(ArrayList live) {  //Create a new sequence and record    
    int numberStills = 0;
    int durationPlay = 0;
    int repeatPlay = 0;
    float fadeRate = 0;
    int timeRecord = millis();

    if(submode == 'p') {
      numberStills = 7;
      repeatPlay = 10;
      durationPlay = int(random(100,200));
      fadeRate = (15000 / (numberStills*durationPlay*repeatPlay));
    }
    if(submode == 'o') {
      numberStills = 3;
      fadeRate = .1*numberStills;
    }   

    else if(submode == 'b' || submode == 'f') {
      numberStills = 1;
      durationPlay = int(random(10000,15000));
      repeatPlay = 1;
      fadeRate = 13000 / (numberStills*durationPlay*repeatPlay);
    }  
    
    fadeRate *= fadeAttenuator;
    sequences.add(new Sequence(live, numberStills, durationPlay, repeatPlay, fadeRate, timeRecord));
    record = false;
  }

  boolean somethingCapturing() {
    boolean somethingCapturing = false;
    for(int i = 0; i < sequences.size(); i++) {
      Sequence thisSequence = (Sequence)sequences.get(i);
      if(thisSequence.isCapturing()) {
        somethingCapturing = true;
      }
    }
    //println("SOMETHING IS CAPTURING! " + somethingCapturing);
    return somethingCapturing;
  }

  void capture(ArrayList<PVector> live) {  //capture the stills
    for(int i = 0; i < sequences.size(); i++) {
      Sequence thisSequence = (Sequence)sequences.get(i);
      if(thisSequence.ready()) { //load the latest point cloud array from the kinect into the new sequence's still objects
        thisSequence.capture(live);
      }
    }
  }


  void play() {
    for(int i = 0; i < sequences.size(); i++) {
      Sequence thisSequence = (Sequence)sequences.get(i);
      thisSequence.play();
      //println("SOMETHING IS PLAYING!");
    }
  } 

  boolean somethingMoving() {
    boolean somethingMoving = false;
    for(int i = 0; i < sequences.size(); i++) {
      Sequence thisSequence = (Sequence)sequences.get(i);
      if(thisSequence.isMoving) {
        somethingMoving = true;
      }
    }
    //println("SOMETHING IS MOVING! " + somethingMoving);
    return somethingMoving;
  }

  void move() {
    for(int i = 0; i < sequences.size(); i++) {
      Sequence thisSequence = (Sequence)sequences.get(i);
      if(thisSequence.isMoving) {
        thisSequence.move();
      }
    }
    //println("SOMETHING IS MOVING!" + somethingMoving);
  }

  void checkfordead() {
    for(int i = 0; i < sequences.size(); i++) {
      Sequence thisSequence = (Sequence)sequences.get(i);
      if(thisSequence.isDead()) {
        sequences.remove(thisSequence);
      }
    }
  }

  void killall() {
    for(int i = 0; i < sequences.size(); i++) {
      Sequence thisSequence = (Sequence)sequences.get(i);
      sequences.remove(thisSequence);
    }
  }
  
  void morph(ArrayList live) {
    PVector[] extremes = findExtremes(live);
   
    PVector closest = extremes[0];
    PVector farthest = extremes[1];
    
    //(Re-)Initialize the first Morpher mass around the closest point and pass it the closest point and the closestNeighbors array
    morpher = new Morpher(live);
    morpher.run(closest, farthest, 600, 300);
  }
  
  void drawPath(ArrayList live) {
     PVector[] extremes = findExtremes(live);
     path.run(live, extremes[0]);
  }

  PVector[] findExtremes(ArrayList<PVector> live) { 
    int closestsMax = 20;
    int farthestsMax = 20;
    int closestBound = -1000;
    int farthestBound = 200;
    a = 0;

    PVector closest = new PVector(0,0,closestBound);
    PVector farthest = new PVector(0,0,farthestBound);

    for (int i = 0; i < live.size()-1; i++) {
      PVector thisLive = (PVector)live.get(i);

      if(thisLive.z < farthestBound && thisLive.z > closestBound) {
        if(thisLive.z >= closest.z) {  //compare z-locations to find the closest and farthest points
          closest = thisLive.get();
        }
        if(thisLive.z <=farthest.z) {
          farthest = thisLive.get();
        }
      }
    }

    // Avergage the last 20 closest values to smooth it out
    if(closests.size() < closestsMax) {
      closests.add(closest);
    }
    else {
      PVector oldestClosest = (PVector)closests.get(0);
      closests.remove(oldestClosest);
    } 

    PVector closestSum = new PVector(0,0,0);    
    for(int i = 0; i < closests.size(); i++) {
      closestSum.add(closests.get(i));
    }

    closestSum.div(closests.size());   
    closest = closestSum.get();

    // Avergage the last 20 farthest values to smooth it out
    if(farthests.size() < farthestsMax) {
      farthests.add(farthest);
    }
    else {
      PVector oldestFarthest = (PVector)farthests.get(0);
      farthests.remove(oldestFarthest);
    } 

    PVector farthestSum = new PVector(0,0,0);    
    for(int i = 0; i < farthests.size(); i++) {
      farthestSum.add(farthests.get(i));
    }

    farthestSum.div(farthests.size());   
    farthest = farthestSum.get();

    //println("CLOSEST: " + closest.z + "\t" + "FARTHEST: " + farthest.z);
    
    // Package up closest and farthest into an array
    PVector[] extremes = new PVector[2];
    extremes[0] = closest;
    extremes[1] = farthest;
    
    return extremes;
  }
}


