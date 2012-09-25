class Morpher {
  MorpherPoint[] morpherPoints;

  Morpher(ArrayList live) {
    
    morpherPoints = new MorpherPoint[live.size()];
    for (int i = 0; i < live.size(); i++) {
    PVector location = (PVector)live.get(i);
    morpherPoints[i] = new MorpherPoint(location);
    }
  }
  
  void run(PVector bulgeCenter, PVector sinkCenter, float bulgeMult, float sinkMult) {
    for (int i = 0; i < morpherPoints.length; i++) {
      morpherPoints[i].run(bulgeCenter, sinkCenter, bulgeMult, sinkMult);
    }
  }
}
