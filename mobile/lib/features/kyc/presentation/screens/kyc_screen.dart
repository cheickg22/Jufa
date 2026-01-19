import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/kyc_document_entity.dart';
import '../providers/kyc_provider.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  DocumentType? _selectedType;
  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final kycStatusAsync = ref.watch(kycStatusProvider);
    final uploadState = ref.watch(kycUploadNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vérification KYC'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: kycStatusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(kycStatusProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (status) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentLevelCard(status),
              const SizedBox(height: AppSpacing.lg),
              _buildLimitsCard(status),
              const SizedBox(height: AppSpacing.lg),
              _buildSubmittedDocuments(status),
              const SizedBox(height: AppSpacing.lg),
              _buildUploadSection(uploadState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLevelCard(KycStatusEntity status) {
    final levelInfo = _getLevelInfo(status.kycLevel);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelInfo['color'] as Color, (levelInfo['color'] as Color).withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(levelInfo['icon'] as IconData, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveau actuel',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  status.kycLevelLabel,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsCard(KycStatusEntity status) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Limites de transaction', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          _buildLimitRow(
            'Limite journalière',
            status.dailyUsed,
            status.dailyLimit,
            status.dailyProgress,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLimitRow(
            'Limite mensuelle',
            status.monthlyUsed,
            status.monthlyLimit,
            status.monthlyProgress,
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String label, double used, double limit, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text(
              '${_formatAmount(used)} / ${_formatAmount(limit)} XOF',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0, 1),
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation(
            progress > 0.8 ? AppColors.error : AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ],
    );
  }

  Widget _buildSubmittedDocuments(KycStatusEntity status) {
    if (status.submittedDocuments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Icon(Icons.folder_open, size: 48, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aucun document soumis',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Documents soumis', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        ...status.submittedDocuments.map((doc) => _buildDocumentTile(doc)),
      ],
    );
  }

  Widget _buildDocumentTile(KycDocumentEntity doc) {
    final statusColor = _getStatusColor(doc.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(_getDocumentIcon(doc.documentType), color: statusColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.documentTypeLabel, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    doc.statusLabel,
                    style: AppTextStyles.caption.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(KycUploadState uploadState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajouter un document', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<DocumentType>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Type de document',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              filled: true,
              fillColor: AppColors.background,
            ),
            items: _getAvailableDocumentTypes().map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getDocumentTypeLabel(type)),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border, width: 2, style: BorderStyle.solid),
              ),
              child: _selectedFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.file(_selectedFile!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 48, color: AppColors.textHint),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Appuyez pour sélectionner une image',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
            ),
          ),
          if (uploadState.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(uploadState.error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canUpload(uploadState) ? _uploadDocument : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: uploadState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Soumettre le document', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<DocumentType> _getAvailableDocumentTypes() {
    return [
      DocumentType.nationalId,
      DocumentType.passport,
      DocumentType.driverLicense,
      DocumentType.voterCard,
      DocumentType.selfie,
      DocumentType.proofOfAddress,
      DocumentType.rccm,
      DocumentType.nif,
      DocumentType.bankStatement,
    ];
  }

  String _getDocumentTypeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
        return "Carte d'identité";
      case DocumentType.passport:
        return 'Passeport';
      case DocumentType.driverLicense:
        return 'Permis de conduire';
      case DocumentType.voterCard:
        return "Carte d'électeur";
      case DocumentType.selfie:
        return 'Photo selfie';
      case DocumentType.proofOfAddress:
        return 'Justificatif de domicile';
      case DocumentType.rccm:
        return 'RCCM';
      case DocumentType.nif:
        return 'NIF';
      case DocumentType.bankStatement:
        return 'Relevé bancaire';
      case DocumentType.other:
        return 'Autre';
    }
  }

  Map<String, dynamic> _getLevelInfo(String level) {
    switch (level) {
      case 'LEVEL_1':
        return {'color': AppColors.info, 'icon': Icons.verified_user_outlined};
      case 'LEVEL_2':
        return {'color': AppColors.success, 'icon': Icons.verified_user};
      case 'LEVEL_3':
        return {'color': AppColors.warning, 'icon': Icons.workspace_premium};
      default:
        return {'color': AppColors.textSecondary, 'icon': Icons.person_outline};
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return AppColors.warning;
      case DocumentStatus.underReview:
        return AppColors.info;
      case DocumentStatus.approved:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
      case DocumentStatus.expired:
        return AppColors.textSecondary;
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
      case DocumentType.passport:
      case DocumentType.driverLicense:
      case DocumentType.voterCard:
        return Icons.badge;
      case DocumentType.selfie:
        return Icons.face;
      case DocumentType.proofOfAddress:
        return Icons.home;
      case DocumentType.rccm:
      case DocumentType.nif:
        return Icons.business;
      case DocumentType.bankStatement:
        return Icons.account_balance;
      case DocumentType.other:
        return Icons.description;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  bool _canUpload(KycUploadState state) {
    return !state.isLoading && _selectedType != null && _selectedFile != null;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1920);
    if (image != null) {
      setState(() => _selectedFile = File(image.path));
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedType == null || _selectedFile == null) return;

    final success = await ref.read(kycUploadNotifierProvider.notifier).uploadDocument(
          filePath: _selectedFile!.path,
          fileName: _selectedFile!.path.split('/').last,
          documentType: _selectedType!,
        );

    if (success && mounted) {
      setState(() {
        _selectedType = null;
        _selectedFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document soumis avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
