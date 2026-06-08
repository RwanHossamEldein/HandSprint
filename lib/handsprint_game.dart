import 'package:flame/events.dart'; 
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:handsprint/game_componants/game_background.dart';
import 'package:handsprint/game_componants/game_lane.dart';
import 'package:handsprint/game_componants/player_component.dart';


class HandsprintGame extends FlameGame with HasKeyboardHandlerComponents {
  late GameLane gameLane;
  late PlayerComponent player;

  @override
  Future<void> onLoad() async {
    super.onLoad();


    gameLane = GameLane(size);

   
    await add(GameBackground());


    player = PlayerComponent(gameLane);
    
    
    await add(player);
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
      }
      else if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
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