class Pathway {
  PVector[] pos;
  PVector previousPos;
  PVector currentPos;
  ArrayList<PVector> closests = new ArrayList<PVector>();

  float velocity =0;
  float radius = 10;
  boolean still;
  int stillCounter = 0;
  float dotAlpha = 0;

  Pathway(int n) {  // n= number of points in the drawn pathway
    pos = new PVector[n];
    for(int i = 0; i<pos.length; i++) {
      pos[i] = new PVector(0,0,0);
    }
    previousPos = new PVector();
    currentPos = new PVector();
    background(0);
  }

  void run(ArrayList live, PVector closest) {
    if(bgColor > 200) {
      drawLine(closest);
      if(dotAlpha > 10) trace();
      else dotAlpha++;
    }
    else {
      bgColor++;
      background(bgColor);
    }
  }
  
  void drawLine(PVector closest) {
    //shift all line elements down one spot pos[0] is oldest
    for (int i = 0; i < pos.length-1; i++ ) {
      pos[i] = pos[i+1];
    }

    // Update the last spot in the array with the avg spot location.
    pos[pos.length-1] = closest.get();
    //println("Pos: " + pos[pos.length-1]);


    //name the last two positions, for motion analysis
    currentPos =  pos[pos.length-1];
    previousPos = pos[pos.length-2]; 
  }
  

  float motion() {
    float d = PVector.dist(previousPos,currentPos);
    return d;
  }

  void trace() {
    // Draw the lines
    for(int i = 0; i < pos.length-1; i++) {
      fill(0,0,0, 5);
      noStroke();
      ellipse(pos[i].x, pos[i].y,radius,radius);  
      //println("Pos: " + pos[i]);

      //check velocity of motion.  more motion = bigger radius.
      velocity = motion();
      //println("velocity " + velocity);
      radius = velocity/2;

      // Check for stillness.  3 sec of stillness = erase background.
      if (velocity < 5) {
        stillCounter++;
        if(stillCounter > 5000){        
          stage.erase();
          stillCounter = 0;
        }
      }
    }
  }
}

