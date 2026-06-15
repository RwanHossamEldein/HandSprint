import 'package:camera/camera.dart';

class CameraServices {
  CameraController? _cameraController;

  CameraController? get controller => _cameraController;

  Future<CameraController?> initCamera() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) return null;

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();

    return _cameraController;
  }

  void dispose() {
    _cameraController?.dispose();
    _cameraController = null;
  }
}