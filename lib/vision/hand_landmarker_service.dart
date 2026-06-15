import 'package:camera/camera.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

class HandLandmarkerService {
  late final HandLandmarkerPlugin _landmarker;

  bool _isProcessing = false;

  void initialize() {
    _landmarker = HandLandmarkerPlugin.create(
      numHands: 1,
      minHandDetectionConfidence: 0.5,
    );
  }

Future<void> stopDetection(
  CameraController controller,
) async {
  await controller.stopImageStream();
}
  void dispose() {
    _landmarker.dispose();
  }
  void startDetection(
  CameraController controller,
  int sensorOrientation,
  onHandsDetected,
) {
  controller.startImageStream(
    (CameraImage image) {

      if (_isProcessing) return;

      _isProcessing = true;

      try {

        final hands = _landmarker.detect(
          image,
          sensorOrientation,
        );

        onHandsDetected(hands);

      } catch (e) {

        print('Hand Detection Error: $e');

      } finally {

        _isProcessing = false;

      }
    },
  );
}
}