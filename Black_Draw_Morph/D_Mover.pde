class Mover {

  ArrayList<MovingPoint> movingPoints = new ArrayList<MovingPoint>();
  PVector[] goals, orderedGoals;

  float maxforce, maxspeed, arriveDamp;
  float opacity, opacityRate;   // opacity of points
  int randomFactor, arrivalCount, arrivedFor, firstArrivedAt, arriveAndPauseFor;
  boolean almostArrived, hasArrived, timingArrival;

  float diagonal;

  int t, total;

  Mover(ArrayList live) {
    diagonal = sqrt(sq(width) + sq(height));
    noiseDetail(10, 0.75);
    t=0;
    total = live.size();
    randomFactor = int(noise(t)*50);

    for(int i = 0; i < live.size(); i++) {
      PVector location = (PVector)live.get(i);
      PVector randomize = new PVector(randomFactor, randomFactor, randomFactor);
      location.add(randomize);
      maxforce = noise(t)*5; // make this a function of depth
      maxspeed = noise(t); // make this a function of depth
      arriveDamp = noise(t)*10;
      movingPoints.add(new MovingPoint(location, maxforce, maxspeed, arriveDamp));
      t++;
    }

    arrivalCount = 0;
    almostArrived = false;
    hasArrived = true;
    firstArrivedAt = 0;
    timingArrival = false;
    arrivedFor = 0;
    arriveAndPauseFor = 500;

    opacity = 255; 
    opacityRate = maxspeed*arriveAndPauseFor*0.00005; // calc the rate of opacity change relative to the amount of time mover is moving for
  }

  //Rationalize different in number of points in point clouds and calculate steering vectors for moving points
  void rationalize(PVector[] nextStillPoints) {

    int pointsGap = nextStillPoints.length - movingPoints.size(); // Calculate the difference in # of points between thisStill and nextStill

    if(pointsGap > 0) {  // If there are more points in the next Still than the current one...add MovingPoints
      for(int i = 0; i < pointsGap; i++) {
        MovingPoint thismovingPoint = (MovingPoint)movingPoints.get(i);
        movingPoints.add(new MovingPoint(thismovingPoint.location, maxforce, maxspeed, arriveDamp));
      }
    }
    
    total = movingPoints.size();
    goals = new PVector[total]; // Create an array of goal vectors

    int j = 0;  // Index of nextPoints
    for(int i = 0; i < movingPoints.size(); i++) {
      MovingPoint thisMovingPoint = (MovingPoint)movingPoints.get(i);

      if(j < nextStillPoints.length-1) { // If there aren't enough destination points, goals wrap around to the beginning
        j++;
      }
      else {
        j = 0;
      }
      goals[i] = nextStillPoints[j].get();
    }
  }

  void reorder() {

    float closestGoal = diagonal; // Hypotenuse of the window. No 2 points can be farther apart than that!

    orderedGoals = new PVector[goals.length]; // Create an array of ordered goal vectors
    boolean[] taken = new boolean[goals.length];  // Keep track of which points have been claimed

    for(int i = 0; i < taken.length; i++) {
      taken[i] = false;
    }
    int takenBy = goals.length;

    // Iterate through the points in the Mover, compare each movingPoint to all the points in the next Still and find the "closest" point
    for (int i = 0; i < movingPoints.size(); i++) {
      PVector thisMPlocation = (PVector) movingPoints.get(i).location;
      for(int j = 0; j < goals.length; j++) {
        PVector distance = PVector.sub(thisMPlocation, goals[j]);
        float d = distance.mag();
        if(d < closestGoal && d > 10 && !taken[j]) {
          closestGoal = d;
          takenBy = j;
        }
      }
      orderedGoals[i] = goals[takenBy].get();
      taken[takenBy] = true;  // Record the "last closest point" was claimed 
      closestGoal = diagonal;
    }
  }


  void interpolate(float strokeColor, float offset) {
    // Change the opacity
    //opacity -= opacityRate;
    //opacity = constrain(opacity, 3, 255);
    //println("OPACITY: " + opacity);

    arrivalCount = 0;

    pushMatrix();
    translate(offset, 0, 0);

    for(int i = 0; i < movingPoints.size(); i++) {

      MovingPoint thisMovingPoint = (MovingPoint)movingPoints.get(i);
      thisMovingPoint.run(goals[i], strokeColor);      

      if(thisMovingPoint.arrived) {
        arrivalCount++;
      }
    }    
    popMatrix();
    
    if(arrivalCount > total*0.99 ) {
      almostArrived = true;
    }
  }

  void hasArrived() {
    // Pause between Stills
    if(timingArrival) {
      arrivedFor = millis() - firstArrivedAt;
    }
    else if(almostArrived) {
      for(int i = 0; i < movingPoints.size(); i++) {
        MovingPoint thisMovingPoint = (MovingPoint)movingPoints.get(i);
        thisMovingPoint.arrived = false;
      }

      almostArrived = false;
      firstArrivedAt = millis();
      timingArrival = true;
    }

    if(arrivedFor > arriveAndPauseFor) {
      timingArrival = false;
      arrivedFor = 0;
      hasArrived = true;
    }
    else {
      hasArrived = false;
    }
  }
}

