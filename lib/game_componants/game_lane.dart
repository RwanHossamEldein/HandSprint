import 'package:flame/components.dart';

enum LanePosition { left, center, right }
class GameLane{
  final Vector2 screenSize;
  GameLane(this.screenSize){
   _calculateLanes();
  }
  late double leftLaneX;
  late double centerLaneX;
  late double rightLaneX;
  void _calculateLanes() {
    double width = screenSize.x; 
    centerLaneX = width / 2;
    double offset = width * 0.30; 
    leftLaneX = centerLaneX - offset;
    rightLaneX = centerLaneX + offset;
  }
  double getXForLane(LanePosition lane) {
    switch (lane) {
      case LanePosition.left:
        return leftLaneX;
      case LanePosition.center:
        return centerLaneX;
      case LanePosition.right:
        return rightLaneX;
    }
}}