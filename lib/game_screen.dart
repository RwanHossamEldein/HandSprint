import 'package:flame/game.dart' hide Plane;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:handsprint/handsprint_game.dart';
import 'package:handsprint/overlays/game_over_overlay.dart';

enum HandState { left, center, right }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late HandsprintGame game;
  bool isReady = false;

  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  // Calibration and gesture thresholds
  double? _baselineX;
  double? _baselineY;
  final double _xThreshold = 60.0;     // Horizontal movement sensitivity
  final double _jumpThreshold = 70.0;  // Upward movement sensitivity (smaller Y is up)
  final double _slideThreshold = 70.0; // Downward movement sensitivity (larger Y is down)

  HandState _currentHandState = HandState.center;
  DateTime? _lastVerticalActionTime;
  final Duration _verticalCooldown = const Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    game = HandsprintGame();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    try {
      // 1. Get list of available cameras
      final cameras = await availableCameras();
      
      // 2. Select front camera for gesture tracking
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      // 3. Initialize CameraController with Low resolution for fast processing
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      // 4. Initialize ML Kit Pose Detector
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
        ),
      );

      // 5. Start camera image stream
      _cameraController!.startImageStream((CameraImage image) {
        _processCameraImage(image);
      });

      setState(() {
        isReady = true;
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Error initializing tracking/camera: $e");
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _poseDetector == null) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector!.processImage(inputImage);
      if (poses.isNotEmpty) {
        final pose = poses.first;
        _analyzePose(pose);
      }
    } catch (e) {
      debugPrint("Error processing frame: $e");
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    if (_cameraController == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final sensorOrientation = _cameraController!.description.sensorOrientation;
    final imageRotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (imageRotation == null) return null;

    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return null;

    final inputImageData = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageData,
    );
  }

  void _analyzePose(Pose pose) {
    // Extract wrists to track movement
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftWrist == null && rightWrist == null) return;

    // Pick the wrist with higher tracking confidence
    final double leftScore = leftWrist?.likelihood ?? 0.0;
    final double rightScore = rightWrist?.likelihood ?? 0.0;
    final activeWrist = (leftScore > rightScore) ? leftWrist : rightWrist;

    if (activeWrist == null || activeWrist.likelihood < 0.5) return;

    final double currentX = activeWrist.x;
    final double currentY = activeWrist.y;

    // Auto-calibrate baseline position on the first successful detection
    _baselineX ??= currentX;
    _baselineY ??= currentY;

    final now = DateTime.now();

    // --- 1. Lane Movement Detection (Left/Right) with State Machine ---
    if (_currentHandState == HandState.center) {
      // Front camera is mirrored: Moving hand to player's right decreases X in frame
      if (currentX < _baselineX! - _xThreshold) {
        _currentHandState = HandState.right;
        game.onHandSwipeRight();
      } 
      // Moving hand to player's left increases X in frame
      else if (currentX > _baselineX! + _xThreshold) {
        _currentHandState = HandState.left;
        game.onHandSwipeLeft();
      }
    } 
    // Hysteresis: Must return towards the baseline center to reset state
    else if (_currentHandState == HandState.right) {
      if (currentX > _baselineX! - (_xThreshold * 0.5)) {
        _currentHandState = HandState.center;
      }
    } 
    else if (_currentHandState == HandState.left) {
      if (currentX < _baselineX! + (_xThreshold * 0.5)) {
        _currentHandState = HandState.center;
      }
    }

    // --- 2. Vertical Movement Detection (Jump/Slide) with Cooldown ---
    if (_lastVerticalActionTime == null || 
        now.difference(_lastVerticalActionTime!) > _verticalCooldown) {
      
      // Jump: Raising hand decreases Y coordinate in image space
      if (currentY < _baselineY! - _jumpThreshold) {
        game.onHandSwipeUp();
        _lastVerticalActionTime = now;
      } 
      // Slide: Lowering hand increases Y coordinate in image space
      else if (currentY > _baselineY! + _slideThreshold) {
        game.onHandSwipeDown();
        _lastVerticalActionTime = now;
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady || _cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. The Flame Game Widget
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, HandsprintGame gameInstance) => GameOverOverlay(gameInstance)
            },
          ),

          // 2. Floating Circular Camera Preview Overlay (Top-Right)
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(color: const Color.fromARGB(255, 22, 130, 192), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: ClipOval(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize!.height,
                    height: _cameraController!.value.previewSize!.width,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}