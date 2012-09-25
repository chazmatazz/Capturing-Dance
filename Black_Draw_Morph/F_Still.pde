class Still {

  PVector[] stillPoints;

  boolean firstBreath, inhale;
  ArrayList<Float> breathX;
  float thisBreathX, distance;
  int theta;

  Still(ArrayList<PVector> live) {

    stillPoints = new PVector[live.size()];

    // create array of still points for this still in the still array by grabbing x,y,z locations from kinect
    for (int i = 0; i < live.size(); i++) {
      stillPoints[i] = live.get(i);
    }

    firstBreath = true;
    breathX = new ArrayList<Float>();
    thisBreathX = 0;
    distance = 1;
    inhale = true;
  }

  void render(int playGap, float strokeColor) {
    for(int i=0; i < stillPoints.length; i++) {
      noFill();
      stroke(strokeColor, strokeColor, strokeColor);
      point(stillPoints[i].x,stillPoints[i].y, stillPoints[i].z);
    }
  }

  void render_breath(float strokeColor) {

    PVector center = new PVector(0, 0, 0);
    float count = 0;

    for(int i=0; i < stillPoints.length; i++) {
      PVector thisPoint = (PVector)stillPoints[i].get();
      center = PVector.add(center, thisPoint);
    }
    
    center.div(stillPoints.length);
        center.add(0, -100, 0);


  if(firstBreath) {
    for(int i=0; i < stillPoints.length; i++) { 
      breathX.add(new Float(0));
    }
    firstBreath = false;
  }

  else {
    /*noStroke();
    fill(255,0,0);
    ellipse(center.x, center.y, 50, 50);*/

    for(int i=0; i < stillPoints.length; i++) { 

      PVector thisPoint = (PVector)stillPoints[i];
      thisBreathX = (float)breathX.get(i);
      PVector bulge = PVector.sub(thisPoint, center);
      distance = dist(center.x, center.y, center.z, thisPoint.x,thisPoint.y,thisPoint.z);

      if (inhale) {
        thisBreathX += (150)/(distance);

        breathX.set(i, thisBreathX);
        
        if (thisBreathX > 100) {
          inhale = false;

        }
      }
      else {
        thisBreathX -= (150)/(distance);

        breathX.set(i, thisBreathX);
        if (thisBreathX < 0) {
          inhale = true;
        }
      }
            
      bulge.normalize();
      bulge.mult(thisBreathX);
      PVector newPoint = PVector.add(thisPoint, bulge);
      
      stroke(strokeColor, strokeColor, strokeColor);

      point(newPoint.x, newPoint.y, newPoint.z);
    }
  }
}
}
