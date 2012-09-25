class MovingPoint {
  PVector location, velocity, acceleration   ;
  float maxforce;
  float maxspeed;
  float arriveDamp;
  boolean arrived;

  MovingPoint(PVector location_, float maxforce_, float maxspeed_, float arriveDamp_) {
    velocity = new PVector(0, 0, 0);
    acceleration = new PVector(0,0,0);
    location = location_.get();
    //location = new PVector(int(random(width)),int(random(height)),int(random(-100,100)));
    maxforce = maxforce_;
    maxspeed = maxspeed_;
    arriveDamp = arriveDamp_;
    arrived = false;
  }

  void run(PVector target, float strokeColor) {
    arrive(target);
    //seek(target);
    update();
    render(strokeColor);
  }


  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  void applyForces(PVector force) {
    acceleration.add(force);
  }

  void seek(PVector target) {    
    acceleration.add(steer(target, false));
  }

  void arrive(PVector target) {
    acceleration.add(steer(target, true));
  }

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  PVector steer(PVector target, boolean slowdown) {
    PVector steer;  // The steering vector
    PVector desired = PVector.sub(target,location);  // A vector pointing from the location to the target
    float d = desired.mag(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    
    if(d < arriveDamp) {
      arrived = true;
      //println("ARRIVED" + d);
    }

    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < arriveDamp)) desired.mult(maxspeed*(d/arriveDamp)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = PVector.sub(desired,velocity);
      steer.limit(maxforce);  // Limit to maximum steering force
    } 
    else {
      steer = new PVector(0,0);
    }
    return steer;
  }

  void render(float strokeColor) {
    noStroke();
    stroke(strokeColor + int(random(-10, 10)));
    point(location.x, location.y, location.z);
  }
}

