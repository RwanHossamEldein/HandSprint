import 'package:flame/components.dart';

enum LanePosition { left, center, right }

class GameLane {

  final Vector2 screenSize;
  
  GameLane(this.screenSize);


  double get width => screenSize.x;
  double get centerLaneX => width / 2;
  double get offset => width * 0.30; 

  double get leftLaneX => centerLaneX - offset;
  double get rightLaneX => centerLaneX + offset;

  double getXForLane(LanePosition lane) {
    switch (lane) {
      case LanePosition.left:
        return leftLaneX;
      case LanePosition.center:
        return centerLaneX;
      case LanePosition.right:
        return rightLaneX;
    }
  }
}