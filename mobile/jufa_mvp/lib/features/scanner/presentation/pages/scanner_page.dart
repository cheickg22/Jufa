import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('scanner_qr_codes')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.qr_code_scanner), text: l10n.translate('scanner')),
            Tab(icon: Icon(Icons.qr_code_2), text: l10n.translate('my_qr_codes')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ScannerTab(),
          _MyQRCodesTab(),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
    );
  }
}

// Onglet Scanner
class _ScannerTab extends StatefulWidget {
  const _ScannerTab();

  @override
  State<_ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<_ScannerTab> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _showResultDialog(barcode.rawValue!);
        break;
      }
    }
  }

  void _showResultDialog(String result) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('qr_code_scanned')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('content')),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                result,
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.translate('close')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processQRResult(result);
            },
            child: Text(l10n.translate('use')),
          ),
        ],
      ),
    );
  }

  void _processQRResult(String result) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.translate('qr_code_processed').replaceAll('{content}', result.substring(0, result.length > 50 ? 50 : result.length))),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: _onDetect,
              ),
              // Overlay avec cadre de scan
              Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: AppColors.primary,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
              ),
              // Contrôles
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'flash',
                      onPressed: () {
                        setState(() => _isFlashOn = !_isFlashOn);
                        cameraController.toggleTorch();
                      },
                      backgroundColor: Colors.black54,
                      child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'camera',
                      onPressed: () {
                        setState(() => _isFrontCamera = !_isFrontCamera);
                        cameraController.switchCamera();
                      },
                      backgroundColor: Colors.black54,
                      child: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 28,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).translate('place_qr_in_frame'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).translate('scan_automatic'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Onglet Mes QR Codes avec sous-onglets
class _MyQRCodesTab extends StatefulWidget {
  const _MyQRCodesTab();

  @override
  State<_MyQRCodesTab> createState() => _MyQRCodesTabState();
}

class _MyQRCodesTabState extends State<_MyQRCodesTab> with SingleTickerProviderStateMixin {
  TabController? _subTabController;
  String? _userId;
  String? _phone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _subTabController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await UserService.getUserId();
      final phone = await UserService.getPhone();
      setState(() {
        _userId = userId;
        _phone = phone;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _subTabController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Sous-onglets Dépôt / Retrait
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _subTabController!,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: AppLocalizations.of(context).translate('deposit')),
              Tab(text: AppLocalizations.of(context).translate('withdrawal')),
            ],
          ),
        ),
        // Contenu des sous-onglets
        Expanded(
          child: TabBarView(
            controller: _subTabController!,
            children: [
              // Onglet Dépôt
              _buildQRCodeView(
                title: AppLocalizations.of(context).translate('receive_money_qr'),
                subtitle: AppLocalizations.of(context).translate('show_qr_to_receive'),
                icon: Icons.arrow_downward,
                iconColor: AppColors.success,
                qrData: 'JUFA:DEPOSIT:$_userId:$_phone',
                actionLabel: AppLocalizations.of(context).translate('deposit'),
              ),
              // Onglet Retrait
              _buildQRCodeView(
                title: AppLocalizations.of(context).translate('withdraw_money'),
                subtitle: AppLocalizations.of(context).translate('show_qr_to_withdraw'),
                icon: Icons.arrow_upward,
                iconColor: AppColors.error,
                qrData: 'JUFA:WITHDRAW:$_userId:$_phone',
                actionLabel: AppLocalizations.of(context).translate('withdrawal'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeView({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String qrData,
    required String actionLabel,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildQRCodeCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        qrData: qrData,
        actionLabel: actionLabel,
      ),
    );
  }

  Widget _buildQRCodeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String qrData,
    required String actionLabel,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                  // Logo JUFA au centre
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'JUFA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Info utilisateur
            if (_phone != null)
              Text(
                _phone!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Classe pour créer l'overlay du scanner
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
  }) : cutOutSize = cutOutSize ?? 250;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize < width && cutOutSize < height
        ? cutOutSize
        : (width < height ? width : height) - borderWidthSize;
    final _cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(_cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Dessiner les coins du cadre
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();

    // Coin supérieur gauche
    path.moveTo(_cutOutRect.left - borderOffset, _cutOutRect.top + borderLength);
    path.lineTo(_cutOutRect.left - borderOffset, _cutOutRect.top + borderRadius);
    path.quadraticBezierTo(_cutOutRect.left - borderOffset, _cutOutRect.top - borderOffset,
        _cutOutRect.left + borderRadius, _cutOutRect.top - borderOffset);
    path.lineTo(_cutOutRect.left + borderLength, _cutOutRect.top - borderOffset);

    // Coin supérieur droit
    path.moveTo(_cutOutRect.right - borderLength, _cutOutRect.top - borderOffset);
    path.lineTo(_cutOutRect.right - borderRadius, _cutOutRect.top - borderOffset);
    path.quadraticBezierTo(_cutOutRect.right + borderOffset, _cutOutRect.top - borderOffset,
        _cutOutRect.right + borderOffset, _cutOutRect.top + borderRadius);
    path.lineTo(_cutOutRect.right + borderOffset, _cutOutRect.top + borderLength);

    // Coin inférieur droit
    path.moveTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom - borderLength);
    path.lineTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom - borderRadius);
    path.quadraticBezierTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom + borderOffset,
        _cutOutRect.right - borderRadius, _cutOutRect.bottom + borderOffset);
    path.lineTo(_cutOutRect.right - borderLength, _cutOutRect.bottom + borderOffset);

    // Coin inférieur gauche
    path.moveTo(_cutOutRect.left + borderLength, _cutOutRect.bottom + borderOffset);
    path.lineTo(_cutOutRect.left + borderRadius, _cutOutRect.bottom + borderOffset);
    path.quadraticBezierTo(_cutOutRect.left - borderOffset, _cutOutRect.bottom + borderOffset,
        _cutOutRect.left - borderOffset, _cutOutRect.bottom - borderRadius);
    path.lineTo(_cutOutRect.left - borderOffset, _cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
