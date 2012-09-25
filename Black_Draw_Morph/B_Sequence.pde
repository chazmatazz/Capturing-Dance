class Sequence {

  ArrayList<Still> stills = new ArrayList<Still>();
  int stillCount, stillMax, nextCount, thisStill, nextStill, pm, playTime, playHead, playGap, playRepeats, playMax, captureGap, cm, captureTime;
  float offset, strokeColor, strokeFade;
  boolean isMoving, lastStillArrived, lastStillPlayed;

  Mover mover;

  Sequence(ArrayList live, int numberStills, int durationPlay, int repeatPlay, float fadeRate, int timeRecord) {
    mover = new Mover(live);

    isMoving = false;
    lastStillArrived = false;
    lastStillPlayed = false;

    offset = 0;

    stillCount = 0;
    nextCount = 0;
    stillMax = numberStills;

    captureGap = 500;
    cm = timeRecord;
    captureTime = 0;

    playGap = durationPlay;
    pm = timeRecord;
    playTime = 0;
    playHead = 0;
    playRepeats = 0;
    playMax = repeatPlay;
    
    strokeColor = 255;
    strokeFade = fadeRate;
  }

  boolean ready() {
    boolean ready = false;
    captureTime = millis() - cm;

    if(isCapturing() && captureTime > captureGap) { 
      ready = true;
      cm = millis();
      captureTime = 0;
      stillCount++;
    }
    else {
      ready = false;
    } 
    return ready;
  }

  boolean isCapturing () {
    boolean capturing = false;
    if(stillCount < stillMax) {
      capturing = true;
    }
    else {
      capturing = false; //end of capture
    }

    return capturing;
  }

  void capture(ArrayList<PVector> live) {
    println("STILLS SIZE: " + stills.size());
    //take the points from the kinect and store them into the stills  
    if(stills.size() > 0) {
      stills.add(new Still(live));
      println("Still " + (stillCount-1) + " has been captured.");
    }
    else if(stills.size() == 0) {
      stills.add(new Still(live));
      println("First Still has been captured.");
      isMoving = true;
    }
  }


  void play() {
    if(stills.size() == stillMax) {

      if(playHead < stills.size()) {
        Still thisStill = (Still)stills.get(playHead);
        strokeColor -= strokeFade;
       
        strokeColor = constrain(strokeColor, bgColor, 255);
        
        if(submode == 'b') {
          thisStill.render_breath(strokeColor);
        }
        else {
          thisStill.render(playGap, strokeColor); 
        }       

        if(playTime > playGap) {
          playHead++;
          pm = millis();
          playTime = 0;
        }
        else {
          playTime = millis() - pm;
        }
      } 

      else if(playRepeats < playMax) {
        playRepeats++;   
        playHead = 0;
      }

      else {
        playRepeats = 0;
        lastStillPlayed = true;
      }
    }
  }

  void move() {
    if(nextCount < stillMax) {
      strokeColor -= strokeFade;       
      strokeColor = constrain(strokeColor, bgColor, 255);
      
      if(stills.size() > nextCount) {
        Still nextStill = (Still)stills.get(nextCount);

        if(mover.hasArrived) {
          println("Mover has arrived at " + nextCount);

          if(nextCount == stillMax-1) {
            lastStillArrived = true;
          }
          else {
            nextCount++;
            println("NEXT DESTINATION: Still " + nextCount);
          }

          mover.rationalize(nextStill.stillPoints);
          //mover.reorder();
          mover.hasArrived = false;
          isMoving = true;
        }

        if(!mover.hasArrived) {
          //println("Interpolating " + (nextCount-1));

          mover.interpolate(strokeColor, offset);
          mover.hasArrived();
          isMoving = true;
        }
        else {
          isMoving = false;
          println("MOVING? " + isMoving);
        }
      }
    }
  }

  boolean isDead() {   
    boolean isDead = false;

    if(lastStillArrived || lastStillPlayed) {
      isDead = true;
      println("DIE!!!");
    }
    else {  
      isDead = false;
    }

    return isDead;
  }
}

