import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:handsprint/input/hand_gesture.dart';


class HandGestureController {
  bool isFingerUp(
    List<Landmark> landmarks,
    int tip,
    int pip,
  ) {
    return landmarks[tip].y < landmarks[pip].y;
  }

  HandGesture detect(List<Landmark> landmarks) {
    if (landmarks.length < 21) {
      return HandGesture.none;
    }

    final indexUp = isFingerUp(landmarks, 8, 6);
    final middleUp = isFingerUp(landmarks, 12, 10);
    final ringUp = isFingerUp(landmarks, 16, 14);
    final pinkyUp = isFingerUp(landmarks, 20, 18);

    if (!(indexUp && !middleUp && !ringUp && !pinkyUp)) {
      return HandGesture.none;
    }

    final indexTip = landmarks[8];

    if (indexTip.x < 0.3) {
      return HandGesture.left;
    }

    if (indexTip.x > 0.7) {
      return HandGesture.right;
    }

    if (indexTip.y < 0.3) {
      return HandGesture.jump;
    }

    if (indexTip.y > 0.7) {
      return HandGesture.slide;
    }

    return HandGesture.none;
  }
}