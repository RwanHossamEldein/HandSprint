import 'dart:async';
import 'package:flame/components.dart' as flame_comp; 
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

class HandsprintGame extends FlameGame with HasKeyboardHandlerComponents {
  late GameLane gameLane;
  late PlayerComponent player;
  
 
  late flame_comp.Timer coinSpawnTimer;
  late flame_comp.Timer lowObstacleSpawnTimer;
  late flame_comp.Timer highObstacleSpawnTimer;
  @override
  Future<void> onLoad() async {
    super.onLoad();

    gameLane = GameLane(size);

    await add(GameBackground());

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
  
    coinSpawnTimer.update(dt);
    lowObstacleSpawnTimer.update(dt);
    highObstacleSpawnTimer.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
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
}