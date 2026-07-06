import 'package:flame/game.dart' hide Plane;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:handsprint/handsprint_game.dart';
import 'package:handsprint/overlays/game_over_overlay.dart';
import 'package:handsprint/services/pose_detector_service.dart';
import 'package:handsprint/services/image_converter.dart';
import 'package:handsprint/widgets/camera_preview_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  DateTime? _lastProcessedFrameTime;
final Duration _throttleDuration = const Duration(milliseconds: 200);
  late HandsprintGame game;
  bool isReady = false;
  late PoseDetectorService poseDetectorService;

  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    game = HandsprintGame();
    game.onReset = () {
      // Delay calibration by 1 second to give the player time to get in position
      Future.delayed(const Duration(milliseconds: 1000), () {
        poseDetectorService.triggerCalibration();
      });
    };
    poseDetectorService = PoseDetectorService(
      onSwipeLeft: () => game.onHandSwipeLeft(),
      onSwipeRight: () => game.onHandSwipeRight(),
      onSwipeUp: () => game.onHandSwipeUp(),
      onSwipeDown: () => game.onHandSwipeDown(),
    );
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    try {
  
      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

  
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

  
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
        ),
      );


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
  final now = DateTime.now();
  

  if (_lastProcessedFrameTime != null && 
      now.difference(_lastProcessedFrameTime!) < _throttleDuration) {
    return;
  }


  if (_isProcessing || _poseDetector == null || _cameraController == null) return;
  

  _lastProcessedFrameTime = now;
  _isProcessing = true;

  try {
   
    final inputImage = ImageConverter.cameraImageToInputImage(
      image: image,
      controller: _cameraController!,
    );
    if (inputImage == null) return;

    final poses = await _poseDetector!.processImage(inputImage);
    if (poses.isNotEmpty) {
      final pose = poses.first;
      poseDetectorService.analyzePose(pose);
    }
  } catch (e) {
    debugPrint("Error processing frame: $e");
  } finally {
    _isProcessing = false;
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
            child: CameraPreviewWidget(controller: _cameraController!),
          ),
        ],
      ),
    );
  }
}