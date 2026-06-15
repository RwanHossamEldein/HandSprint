import 'package:handsprint/input/hand_gesture.dart';
import 'package:handsprint/handsprint_game.dart';

class HandInputManager {
  final HandsprintGame game;

  HandInputManager(this.game);

  HandGesture _lastGesture = HandGesture.none;

  double _cooldown = 0;

  final double cooldownDuration = 0.4;

  void update(double dt) {
    if (_cooldown > 0) {
      _cooldown -= dt;
    }
  }

  void processGesture(HandGesture gesture) {
    if (gesture == HandGesture.none) {
      _lastGesture = HandGesture.none;
      return;
    }

    if (_cooldown > 0) return;

    if (gesture == _lastGesture) return;

    _lastGesture = gesture;
    _cooldown = cooldownDuration;

    switch (gesture) {
      case HandGesture.left:
        game.onHandSwipeLeft();
        break;

      case HandGesture.right:
        game.onHandSwipeRight();
        break;

      case HandGesture.jump:
        game.onHandSwipeUp();
        break;

      case HandGesture.slide:
        game.onHandSwipeDown();
        break;

      case HandGesture.none:
        break;
    }
  }
}