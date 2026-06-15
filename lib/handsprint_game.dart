import 'dart:async';
import 'package:flame/components.dart' as flame_comp;
import 'package:flame/components.dart'; 
import 'package:flame/events.dart'; 
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:handsprint/game_componants/game_background.dart';
import 'package:handsprint/game_componants/game_lane.dart';
import 'package:handsprint/game_componants/high_obstacles.dart';
import 'package:handsprint/game_componants/low_obstacles.dart';
import 'package:handsprint/game_componants/player_component.dart';
import 'package:handsprint/game_componants/coins.dart';
import 'package:handsprint/game_componants/player_state.dart';
import 'package:handsprint/input/gesture_controller.dart';
import 'package:handsprint/input/hand_gesture.dart';
import 'package:handsprint/input/hand_input_manager.dart'; 

class HandsprintGame extends FlameGame with HasKeyboardHandlerComponents,HasCollisionDetection {
  late GameLane gameLane;
  late PlayerComponent player;
 late TextComponent scoreText;
int score = 0;
  late HandInputManager handInputManager;
 final HandGestureController gestureController = HandGestureController();
HandGesture lastGesture = HandGesture.none;

double gestureCooldown = 0;
  late flame_comp.Timer coinSpawnTimer;
  late flame_comp.Timer lowObstacleSpawnTimer;
  late flame_comp.Timer highObstacleSpawnTimer;
  @override
  Future<void> onLoad() async {
    super.onLoad();
handInputManager = HandInputManager(this);
    gameLane = GameLane(size);

    await add(GameBackground());
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(20, 40),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 28, color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
      ),
    );
    await add(scoreText);

    player = PlayerComponent(gameLane);
    await add(player);

  
   coinSpawnTimer = flame_comp.Timer(
      2.0,
      onTick: () {
        final coin = Coins(gameLane); 
        add(coin);
      },
      repeat: true,
    );
    lowObstacleSpawnTimer = flame_comp.Timer(
      4,
      onTick: () {
        final lowObstacle = LowObstacles(gameLane); 
        add(lowObstacle);
      },
      repeat: true,
    );
      highObstacleSpawnTimer = flame_comp.Timer(
      6,
      onTick: () {
        final highObstacle = HighObstacles(gameLane); 
        add(highObstacle);
      },
      repeat: true,
    );
  }

 @override
void update(double dt) {
  super.update(dt);
handInputManager.update(dt);
  if (overlays.isActive('GameOver')) return;

  coinSpawnTimer.update(dt);
  lowObstacleSpawnTimer.update(dt);
  highObstacleSpawnTimer.update(dt);

  scoreText.text = 'Score: $score';

  if (gestureCooldown > 0) {
    gestureCooldown -= dt;
  }
}
 
  void reset() {
    overlays.remove('GameOver');
    score = 0;
    scoreText.text = 'Score: $score';
    player.position = Vector2(gameLane.getXForLane(LanePosition.center), size.y * 0.7);
    children.whereType<Coins>().forEach((coin) => coin.removeFromParent());
    children.whereType<LowObstacles>().forEach((obs) => obs.removeFromParent());
    children.whereType<HighObstacles>().forEach((obs) => obs.removeFromParent());
    player.currentLane = LanePosition.center;
    player.current = PlayerState.running;
    coinSpawnTimer.start();
    lowObstacleSpawnTimer.start();
    highObstacleSpawnTimer.start();
    resumeEngine();
  }


  void gameOver() {
    pauseEngine();
    overlays.add('GameOver');
  }

void onHandSwipeLeft() {
  if (!overlays.isActive('GameOver')) {
    player.moveToLeft();
  }
}

void onHandSwipeRight() {
  if (!overlays.isActive('GameOver')) {
    player.moveToRight();
  }
}

void onHandSwipeUp() {
  if (!overlays.isActive('GameOver')) {
    player.jump();
  }
}

void onHandSwipeDown() {
  if (!overlays.isActive('GameOver')) {
    player.slide();
  }
}
void onLandmarksUpdate(List<Landmark> landmarks) {
  final gesture = gestureController.detect(landmarks);

  if (gesture == HandGesture.none) return;

  if (gestureCooldown > 0) return;

  if (gesture == lastGesture) return;

  lastGesture = gesture;
  gestureCooldown = 0.4; // 400ms cooldown

  switch (gesture) {
    case HandGesture.left:
      onHandSwipeLeft();
      break;

    case HandGesture.right:
      onHandSwipeRight();
      break;

    case HandGesture.jump:
      onHandSwipeUp();
      break;

    case HandGesture.slide:
      onHandSwipeDown();
      break;

    case HandGesture.none:
      break;
  }
}

}