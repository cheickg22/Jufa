import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_theme.dart';
import '../providers/qr_payment_provider.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;
  bool _torchEnabled = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(qrScanNotifierProvider);

    ref.listen<QrScanState>(qrScanNotifierProvider, (previous, next) {
      if (next.scannedCode != null && previous?.scannedCode == null) {
        context.push('/qr/confirm', extra: next.scannedCode);
      }
      if (next.error != null && previous?.error == null) {
        _showError(next.error!);
        _isProcessing = false;
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          _buildOverlay(),
          _buildTopBar(),
          _buildBottomBar(scanState),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.5),
        BlendMode.srcOut,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
              ),
            ),
            IconButton(
              onPressed: _toggleTorch,
              icon: Icon(
                _torchEnabled ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(QrScanState state) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scanner un QR Code',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Placez le code QR dans le cadre',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isLoading || _isProcessing)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: () => _showManualEntryDialog(),
              icon: const Icon(Icons.keyboard, color: Colors.white70),
              label: Text(
                'Saisir le code manuellement',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);
    _processQrCode(code);
  }

  void _processQrCode(String qrToken) {
    ref.read(qrScanNotifierProvider.notifier).scanQrCode(qrToken);
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: () {
            ref.read(qrScanNotifierProvider.notifier).reset();
            setState(() => _isProcessing = false);
          },
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saisir le code'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Entrez le code QR',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                setState(() => _isProcessing = true);
                _processQrCode(controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
