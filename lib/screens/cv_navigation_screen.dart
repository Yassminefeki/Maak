import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/notification_service.dart';
import '../widgets/cv_overlay_painter.dart';
import '../widgets/queue_status_card.dart';

class CVNavigationScreen extends StatefulWidget {
  final String targetGuichet; // e.g. "Guichet 3" — passed from optimizer
  final int userQueueNumber;  // user's ticket number

  const CVNavigationScreen({
    super.key,
    required this.targetGuichet,
    required this.userQueueNumber,
  });

  @override
  State<CVNavigationScreen> createState() => _CVNavigationScreenState();
}

class _CVNavigationScreenState extends State<CVNavigationScreen>
    with SingleTickerProviderStateMixin {

  CameraController? _camera;
  final _recognizer = TextRecognizer();
  final _tts = FlutterTts();

  bool _isProcessing = false;
  bool _hasSpoken = false;
  bool _notificationSent = false;

  List<DetectedSign> _signs = [];
  int _currentQueueNumber = 0;

  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_pulse);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _camera = CameraController(cameras.first, ResolutionPreset.medium);
    await _camera!.initialize();
    if (!mounted) return;

    setState(() {});
    _camera!.startImageStream(_onFrame);
  }

  void _onFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _cameraImageToInputImage(image);
      final result = await _recognizer.processImage(inputImage);
      _processRecognizedText(result);
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 500));
    _isProcessing = false;
  }

  void _processRecognizedText(RecognizedText result) {
    final List<DetectedSign> signs = [];
    int detectedQueue = 0;

    for (final block in result.blocks) {
      final text = block.text.trim();
      final box = _mlKitRectToScreenRect(block.boundingBox);

      // Detect queue number display — big standalone number
      if (RegExp(r'^\d{1,3}$').hasMatch(text)) {
        final num = int.tryParse(text) ?? 0;
        if (num > 0 && num < 999) detectedQueue = num;
      }

      // Check if this block matches the target guichet
      final isTarget = text.toLowerCase().contains(
        widget.targetGuichet.toLowerCase());

      signs.add(DetectedSign(
        text: text,
        boundingBox: box,
        isTarget: isTarget,
      ));

      // Speak once when target is found
      if (isTarget && !_hasSpoken) {
        _hasSpoken = true;
        _tts.speak("\${widget.targetGuichet} détecté. Avancez vers ce guichet.");
      }
    }

    // Update queue number and fire notification if close
    if (detectedQueue > 0) {
      final ahead = widget.userQueueNumber - detectedQueue;
      if (ahead <= 3 && ahead >= 0 && !_notificationSent) {
        _notificationSent = true;
        NotificationService.showTurnAlert(ahead);
      }
      if (mounted) setState(() => _currentQueueNumber = detectedQueue);
    }

    if (mounted) setState(() => _signs = signs);
  }

  // Convert ML Kit Rect to screen Rect — simplified version
  // In production: scale using image size vs screen size ratio
  Rect _mlKitRectToScreenRect(dynamic rect) {
    return Rect.fromLTRB(
      rect.left.toDouble(),
      rect.top.toDouble(),
      rect.right.toDouble(),
      rect.bottom.toDouble(),
    );
  }

  // Convert CameraImage to InputImage for ML Kit
  InputImage _cameraImageToInputImage(CameraImage image) {
    final bytes = image.planes.first.bytes;
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.yuv420,
      bytesPerRow: image.planes.first.bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  @override
  void dispose() {
    _camera?.dispose();
    _recognizer.close();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _camera != null && _camera!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('Navigation vers ${widget.targetGuichet}'),
      ),
      body: isReady
        ? Stack(
            children: [
              // Live camera feed
              SizedBox.expand(child: CameraPreview(_camera!)),

              // AR overlay — bounding boxes + arrows
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => CustomPaint(
                  painter: CVOverlayPainter(
                    signs: _signs,
                    pulseValue: _pulseAnim.value,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),

              // Scanning indicator when nothing detected yet
              if (_signs.isEmpty)
                const Center(
                  child: Text(
                    'Pointez la caméra vers les panneaux…',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),

              // Queue status card — bottom center
              if (_currentQueueNumber > 0)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: QueueStatusCard(
                      currentNumber: _currentQueueNumber,
                      userNumber: widget.userQueueNumber,
                    ),
                  ),
                ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
