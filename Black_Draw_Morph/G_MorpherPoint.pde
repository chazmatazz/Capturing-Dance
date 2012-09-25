class MorpherPoint {

  PVector location, distortion;
  float maxdistortion;

  MorpherPoint(PVector location_) {
    location = location_;
    distortion = new PVector(0,0,0);
    maxdistortion = width;
  }

  void run(PVector bulgeCenter, PVector sinkCenter, float bulgeMult, float sinkMult) {
    morph(bulgeCenter, sinkCenter, bulgeMult, sinkMult);
    render(bulgeCenter);
  }

  // We accumulate a new acceleration each time based on three rules
  void morph(PVector bulgeCenter, PVector sinkCenter, float bulgeMult, float sinkMult) {

    PVector blg = bulge(bulgeCenter);      // Bulge
    PVector snk = sink(sinkCenter);        // Sink
    // Arbitrarily weight these forces
    blg.mult(bulgeMult);
    snk.mult(sinkMult);
    // Add the force vectors to acceleration
    applyDistortion(blg);
    applyDistortion(snk);
  }

  // Method to update location
  void applyDistortion(PVector distortion) {
    // Limit distortion
    distortion.limit(maxdistortion);
    location.add(distortion);
  }

  PVector bulge(PVector bulgeCenter) {

    PVector bulge = PVector.sub(location, bulgeCenter);
    float distance = dist(bulgeCenter.x, bulgeCenter.y, bulgeCenter.z, location.x,location.y,location.z);
    bulge.div(distance*3);

    return bulge;
  }

  PVector sink(PVector sinkCenter) {

    PVector sink = PVector.sub(sinkCenter, location);
    float distance = dist(sinkCenter.x, sinkCenter.y, sinkCenter.z, location.x,location.y,location.z);
    sink.div(distance*3);

    return sink;
  }

  void render(PVector bulgeCenter) {
    noFill();
    stroke(255);
    point(location.x, location.y);
  }
}

