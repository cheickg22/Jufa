import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/legal_service.dart';
import '../../../../core/providers/locale_provider.dart';

class LegalDocumentPage extends StatefulWidget {
  final String type;
  final String title;

  const LegalDocumentPage({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  late LegalService _legalService;
  bool _isLoading = true;
  String _content = '';
  String _version = '';
  String _effectiveDate = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Récupérer la langue actuelle depuis le provider
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      _legalService = LegalService(localeProvider: localeProvider);

      final response = await _legalService.getLegalDocument(widget.type);

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _content = response['data']['content'] ?? '';
          _version = response['data']['version'] ?? '';
          _effectiveDate = response['data']['effective_date'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Document non disponible';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement du document';
        _isLoading = false;
      });
      print('❌ Erreur chargement document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadDocument,
                        icon: Icon(Icons.refresh),
                        label: Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contenu du document
                      Html(
                        data: _content,
                        style: {
                          "body": Style(
                            fontSize: FontSize(14),
                            lineHeight: LineHeight(1.6),
                            color: AppColors.textPrimary,
                          ),
                          "h1": Style(
                            fontSize: FontSize(20),
                            fontWeight: FontWeight.bold,
                            margin: Margins.only(top: 16, bottom: 8),
                          ),
                          "h2": Style(
                            fontSize: FontSize(18),
                            fontWeight: FontWeight.bold,
                            margin: Margins.only(top: 14, bottom: 6),
                          ),
                          "h3": Style(
                            fontSize: FontSize(16),
                            fontWeight: FontWeight.w600,
                            margin: Margins.only(top: 12, bottom: 4),
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 12),
                          ),
                          "ul": Style(
                            margin: Margins.only(left: 16, bottom: 12),
                          ),
                          "ol": Style(
                            margin: Margins.only(left: 16, bottom: 12),
                          ),
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
