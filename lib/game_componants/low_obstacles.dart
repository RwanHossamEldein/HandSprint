import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:handsprint/const/game_images/game_images.dart';
import 'package:handsprint/game_componants/game_lane.dart';
import 'package:handsprint/game_componants/player_component.dart';
import 'package:handsprint/handsprint_game.dart';

// ignore: deprecated_member_use
class LowObstacles extends SpriteComponent with HasGameRef<HandsprintGame>,CollisionCallbacks {
  late LanePosition currentLane;
  final GameLane gameLane;
  
  final double scrollSpeed = 230.0; 
  late double targetX;


  double currentScale = 0.15; 

  LowObstacles(this.gameLane) : super(size: Vector2(100, 65));

  @override
  Future<void> onLoad() async {
    super.onLoad();
add(CircleHitbox()..collisionType = CollisionType.passive);

    final lanes = [LanePosition.left, LanePosition.center, LanePosition.right];
    currentLane = lanes[Random().nextInt(lanes.length)];

    final spriteSheet = await gameRef.images.load(GameImages.jumpObstacle);
    
 
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
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      gameRef.gameOver(); 
    }
  }
}