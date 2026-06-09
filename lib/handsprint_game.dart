import 'dart:async';
import 'package:flame/components.dart' as flame_comp;
import 'package:flame/components.dart'; 
import 'package:flame/events.dart'; 
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:handsprint/game_componants/game_background.dart';
import 'package:handsprint/game_componants/game_lane.dart';
import 'package:handsprint/game_componants/high_obstacles.dart';
import 'package:handsprint/game_componants/low_obstacles.dart';
import 'package:handsprint/game_componants/player_component.dart';
import 'package:handsprint/game_componants/coins.dart';
import 'package:handsprint/game_componants/player_state.dart'; 

class HandsprintGame extends FlameGame with HasKeyboardHandlerComponents,HasCollisionDetection {
  late GameLane gameLane;
  late PlayerComponent player;
 late TextComponent scoreText;
int score = 0;
  
 
  late flame_comp.Timer coinSpawnTimer;
  late flame_comp.Timer lowObstacleSpawnTimer;
  late flame_comp.Timer highObstacleSpawnTimer;
  @override
  Future<void> onLoad() async {
    super.onLoad();

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
  if (overlays.isActive('GameOver')) return;
    coinSpawnTimer.update(dt);
    lowObstacleSpawnTimer.update(dt);
    highObstacleSpawnTimer.update(dt);
    scoreText.text = 'Score: $score';
  }
 
  void reset() {
  
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

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if(overlays.isActive('GameOver')){
      if (event is KeyDownEvent && keysPressed.contains(LogicalKeyboardKey.enter)) {
        reset();
        return KeyEventResult.handled;
      }
    }
    super.onKeyEvent(event, keysPressed);
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        player.moveToLeft();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        player.moveToRight();
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        player.jump(); 
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        player.slide(); 
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
  // ignore: non_constant_identifier_names
  void gameOver() {
    pauseEngine();
    overlays.add('GameOver');
  }
}