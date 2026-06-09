import 'dart:math';
import 'package:flame/components.dart';
import 'package:handsprint/const/game_images/game_images.dart';
import 'package:handsprint/game_componants/game_lane.dart';

class HighObstacles extends SpriteComponent with HasGameRef {
  late LanePosition currentLane;
  final GameLane gameLane;
  
  final double scrollSpeed = 230.0; 
  late double targetX;

 
  double currentScale = 0.15; 

  HighObstacles(this.gameLane) : super(size: Vector2(100, 65));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final lanes = [LanePosition.left, LanePosition.center, LanePosition.right];
    currentLane = lanes[Random().nextInt(lanes.length)];

    final spriteSheet = await gameRef.images.load(GameImages.slideObstacle);
    
  
    sprite = Sprite(
      spriteSheet, 
      srcSize: Vector2(677, 369), 
      srcPosition: Vector2.zero(),
    );
    
    anchor = Anchor.center;
    targetX = gameLane.getXForLane(currentLane);
    
    position = Vector2(targetX, gameRef.size.y * 0.45);
    scale = Vector2.all(currentScale); 
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += scrollSpeed * dt;


    if (currentScale < 1.0) {
      currentScale += 0.7 * dt; 
      scale = Vector2.all(currentScale);
    }

    if (position.y > gameRef.size.y + 50) {
      removeFromParent();
    }
  }
}