import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/qr_payment_entity.dart';
import '../providers/qr_payment_provider.dart';

class GenerateQrScreen extends ConsumerStatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  ConsumerState<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends ConsumerState<GenerateQrScreen> {
  QrCodeType _selectedType = QrCodeType.static_;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _expiresInMinutes = 30;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generateState = ref.watch(qrGenerateNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Générer QR Code'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: generateState.generatedCode != null
          ? _buildGeneratedQr(generateState.generatedCode!)
          : _buildForm(generateState),
    );
  }

  Widget _buildForm(QrGenerateState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type de QR Code', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _TypeCard(
                  icon: Icons.qr_code_2,
                  title: 'Statique',
                  subtitle: 'Réutilisable',
                  isSelected: _selectedType == QrCodeType.static_,
                  onTap: () => setState(() => _selectedType = QrCodeType.static_),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _TypeCard(
                  icon: Icons.timer,
                  title: 'Dynamique',
                  subtitle: 'Usage unique',
                  isSelected: _selectedType == QrCodeType.dynamic,
                  onTap: () => setState(() => _selectedType = QrCodeType.dynamic),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Montant (optionnel pour statique)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Ex: 5000',
              prefixIcon: const Icon(Icons.money),
              suffixText: 'XOF',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Description (optionnel)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Ex: Paiement boutique',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          if (_selectedType == QrCodeType.dynamic) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Expiration', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<int>(
              value: _expiresInMinutes,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 minutes')),
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
                DropdownMenuItem(value: 30, child: Text('30 minutes')),
                DropdownMenuItem(value: 60, child: Text('1 heure')),
                DropdownMenuItem(value: 1440, child: Text('24 heures')),
              ],
              onChanged: (v) => setState(() => _expiresInMinutes = v ?? 30),
            ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(state.error!, style: TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _generateQrCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: state.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Générer le QR Code', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedQr(QrCodeEntity qrCode) {
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'XOF', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrCode.qrToken,
                  version: QrVersions.auto,
                  size: 250,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (qrCode.amount != null) ...[
                  Text(currencyFormat.format(qrCode.amount), style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (qrCode.description != null)
                  Text(qrCode.description!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: qrCode.qrType == QrCodeType.dynamic
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    qrCode.qrTypeLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: qrCode.qrType == QrCodeType.dynamic ? AppColors.warning : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: qrCode.qrToken));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token copié!'), backgroundColor: AppColors.success),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copier'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(qrGenerateNotifierProvider.notifier).reset();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour'),
            ),
          ),
        ],
      ),
    );
  }

  void _generateQrCode() {
    double? amount;
    if (_amountController.text.isNotEmpty) {
      amount = double.tryParse(_amountController.text);
    }

    ref.read(qrGenerateNotifierProvider.notifier).generateQrCode(
          qrType: _selectedType,
          amount: amount,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          expiresInMinutes: _selectedType == QrCodeType.dynamic ? _expiresInMinutes : null,
        );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
