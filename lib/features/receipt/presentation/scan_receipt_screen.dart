// lib/features/receipt/presentation/scan_receipt_screen.dart

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart'; 
import 'receipt_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../../theme/app_colors.dart';
import '../../../core/constants/spacing.dart';

class ScanReceiptScreen extends ConsumerStatefulWidget {
  final bool startInGallery;
  const ScanReceiptScreen({super.key, this.startInGallery = false});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isFlashOn = false;

  final List<String> _capturedPages = [];
  final List<String> _ocrResults = [];
  Map<String, dynamic>? _lastParsedData;

  @override
  void initState() {
    super.initState();
    _initializeLiveCamera();
    if (widget.startInGallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _capturePage(source: ImageSource.gallery));
    }
  }

  Future<void> _capturePage({required ImageSource source}) async {
    if (_isProcessing) return;
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      await _handleImageFile(File(pickedFile.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to analyze image: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _handleImageFile(File file) async {
    setState(() => _isProcessing = true);
    try {
      final isFirebase = ref.read(firebaseAvailableProvider);
      final parsedData = await ref.read(receiptControllerProvider.notifier).processReceiptImage(file, isFirebase);

      if (!mounted) return;
      
      setState(() {
        _capturedPages.add(file.path);
        _ocrResults.add(parsedData['ocrText'] ?? 'Page ${_capturedPages.length} OCR');
        final prev = _lastParsedData;
        _lastParsedData = prev == null ? parsedData : {
          ...parsedData,
          'merchant': prev['merchant'],
          'merchantCandidates': prev['merchantCandidates'],
          'merchantKey': prev['merchantKey'],
          'invoiceNumber': prev['invoiceNumber'],
          'products': [...?(prev['products'] as List?), ...?(parsedData['products'] as List?)],
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process receipt: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _initializeLiveCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false);

        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Live camera initialization failed: $e');
    }
  }

  Future<void> _captureLiveViewfinderPage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) return;

    try {
      final XFile capturedFile = await _cameraController!.takePicture();
      await _handleImageFile(File(capturedFile.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture receipt: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _importFromGallery() async {
    await _capturePage(source: ImageSource.gallery);
  }

  void _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Flash controller error: $e');
    }
  }

  void _finishAndGoToPreview() {
    if (_capturedPages.isEmpty) return;
    context.pushReplacement(
      '/preview',
      extra: {
        'imagePath': _capturedPages.first,
        'imagePaths': _capturedPages,
        'ocrText': _ocrResults.join('\n\n--- Next Page ---\n\n'),
        'parsedData': _lastParsedData,
      });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Edge-to-Edge Live Camera Preview Viewfinder ──
          _isCameraInitialized && _cameraController != null
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!))))
              : Container(color: Colors.black),

          // ── Top Bar Action Controls ──
          Positioned(
            top: topPadding + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24)),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 22)))),

          Positioned(
            top: topPadding + 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleFlash,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isFlashOn ? AppColors.warningBorder.withValues(alpha: 0.3) : Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                  border: _isFlashOn ? Border.all(color: AppColors.warningBorder, width: 1.5) : Border.all(color: Colors.white24)),
                child: Icon(
                  _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _isFlashOn ? AppColors.warningBorder : Colors.white,
                  size: 22)))),

          // ── Floating Multi-page Roll Preview Tray ──
          if (_capturedPages.isNotEmpty)
            Positioned(
              bottom: bottomPadding + 130,
              left: spaceLg,
              right: spaceLg,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B18).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryMid, width: 1.5)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_capturedPages.last),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover)),
                    const SizedBox(width: spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_capturedPages.length} ${_capturedPages.length == 1 ? 'Page' : 'Pages'} Captured',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          Text(
                            'Tap shutter for next page section',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70)),
                        ])),
                    GestureDetector(
                      onTap: _finishAndGoToPreview,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          'Review →',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.w800)))),
                  ]))),

          // ── Bottom Action Control Deck ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF1A1A1A),
              padding: EdgeInsets.only(
                left: spaceXl, right: spaceXl, top: spaceLg,
                bottom: bottomPadding + spaceLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _importFromGallery,
                    child: const _ControlBtn(icon: Icons.photo_library_outlined, label: 'Gallery')),
                  GestureDetector(
                    onTap: _captureLiveViewfinderPage,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4)),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)))),
                  GestureDetector(
                    onTap: () {
                      if (_capturedPages.isNotEmpty) {
                        _finishAndGoToPreview();
                      } else {
                        context.pushReplacement('/preview');
                      }
                    },
                    child: const _ControlBtn(icon: Icons.edit_note_rounded, label: 'Manual')),
                ]))),

          // Processing Pipeline Overlay
          if (_isProcessing)
            _ProcessingOverlay(
              isFirebaseAvailable: ref.watch(firebaseAvailableProvider),
            ),
        ]));
  }
}

class _ProcessingOverlay extends StatefulWidget {
  final bool isFirebaseAvailable;
  const _ProcessingOverlay({required this.isFirebaseAvailable});

  @override
  State<_ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<_ProcessingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Timer _fallbackTimer;
  bool _showFallbackMessage = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fallbackTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showFallbackMessage = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fallbackTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final stage = ref.watch(receiptScanStageProvider);
        
        // Define stage text and progress
        String message = "Analyzing Layout…";
        double progress = 0.1;
        
        // Total stages: 2 (if local only) or 3 (if Gemini AI is available)
        final int totalStages = widget.isFirebaseAvailable ? 3 : 2;
        int currentStageNum = 1;

        switch (stage) {
          case ReceiptScanStage.readingText:
            message = "Reading receipt...";
            currentStageNum = 1;
            progress = 1.0 / totalStages;
            break;
          case ReceiptScanStage.enhancingWithAi:
            message = "Enhancing with AI...";
            currentStageNum = 2;
            progress = 2.0 / totalStages;
            break;
          case ReceiptScanStage.organizingDetails:
            message = "Organizing details...";
            currentStageNum = widget.isFirebaseAvailable ? 3 : 2;
            progress = 1.0; // 100%
            break;
          default:
            message = "Reading receipt...";
            currentStageNum = 1;
            progress = 0.1;
        }

        return Container(
          color: Colors.black.withValues(alpha: 0.75),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: spaceLg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(spaceLg),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.surfaceDark 
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.outlineDark 
                    : AppColors.outlineLight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Soft pulsing neonCyan document icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(spaceMd),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan.withValues(alpha: 0.1 + (_pulseController.value * 0.15)),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.neonCyan,
                        size: 40 + (_pulseController.value * 4),
                      ),
                    );
                  },
                ),
                const SizedBox(height: spaceLg),
                
                // Stage Text
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: spaceSm),
                
                // Stage indicator index (e.g. Stage 1 of 3)
                Text(
                  "Stage $currentStageNum of $totalStages",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: spaceMd),

                // Determinate progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.softLightFill,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                    ),
                  ),
                ),
                
                // Timeout Fallback Alert
                if (_showFallbackMessage) ...[
                  const SizedBox(height: spaceMd),
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(spaceSm),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        "Still working — this can take a few extra seconds for tricky receipts",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ControlBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 26),
        const SizedBox(height: spaceXs),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, fontWeight: FontWeight.w500)),
      ]);
  }
}
