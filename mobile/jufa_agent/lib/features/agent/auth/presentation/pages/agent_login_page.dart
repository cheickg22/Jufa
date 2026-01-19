import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/services/agent_api_service.dart';
import '../../../../../core/theme/agent_colors.dart';

class AgentLoginPage extends StatefulWidget {
  const AgentLoginPage({super.key});

  @override
  State<AgentLoginPage> createState() => _AgentLoginPageState();
}

class _AgentLoginPageState extends State<AgentLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+223 ');
  final _passwordController = TextEditingController();
  final AgentApiService _agentApiService = AgentApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _hasCheckedRejection = false;

  @override
  void initState() {
    super.initState();
    _checkLastPhoneRejection();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLastPhoneRejection() async {
    try {
      // Récupérer le dernier numéro de téléphone utilisé
      final prefs = await SharedPreferences.getInstance();
      final lastPhone = prefs.getString('last_agent_phone');
      
      if (lastPhone != null && lastPhone.isNotEmpty) {
        final result = await _agentApiService.checkRejectionByPhone(lastPhone);
        
        if (result['success'] == true && result['is_rejected'] == true) {
          _hasCheckedRejection = true;
          final reason = result['data']['rejection_reason'] ?? 'Aucun motif spécifié';
          
          if (mounted) {
            // Attendre que le widget soit complètement construit
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showRejectionModal(reason, result['data']['rejected_at']);
              }
            });
          }
        }
      }
    } catch (e) {
      print('❌ Erreur vérification rejet au démarrage: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.replaceAll(' ', '');
      
      // Sauvegarder le numéro de téléphone pour la prochaine fois
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_agent_phone', phone);
      
      // Authentification via API
      final response = await _agentApiService.login(
        phone: phone,
        password: _passwordController.text,
      );

      if (mounted) {
        context.go('/agent/dashboard');
      }
    } on DioException catch (e) {
      if (mounted) {
        // Vérifier si c'est une erreur de rejet
        if (e.response?.statusCode == 403 && 
            e.response?.data['status'] == 'rejected') {
          _showRejectionModal(
            e.response?.data['rejection_reason'] ?? 'Aucun motif spécifié',
            e.response?.data['rejected_at'],
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.response?.data['message'] ?? 'Erreur de connexion'),
              backgroundColor: AgentColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AgentColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRejectionModal(String reason, String? rejectedAt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: AgentColors.error, size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Demande rejetée',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre demande d\'agent a été rejetée pour le motif suivant :',
              style: TextStyle(
                fontSize: 14,
                color: AgentColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AgentColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AgentColors.error.withOpacity(0.3)),
              ),
              child: Text(
                reason,
                style: const TextStyle(
                  fontSize: 14,
                  color: AgentColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vous pouvez soumettre une nouvelle demande en corrigeant les points mentionnés.',
              style: TextStyle(
                fontSize: 12,
                color: AgentColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AgentColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AgentColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Agent
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AgentColors.cardShadow,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: AgentColors.primary,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AgentColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.swap_horiz,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Titre
                  const Text(
                    'JUFA Agent',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Espace Agent',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Formulaire
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AgentColors.cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Téléphone
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              hintText: '+223 90 00 00 00',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('🇲🇱', style: TextStyle(fontSize: 24)),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              // Empêcher la suppression de +223
                              if (!value.startsWith('+223 ')) {
                                _phoneController.text = '+223 ';
                                _phoneController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _phoneController.text.length),
                                );
                                return;
                              }

                              // Extraire uniquement les chiffres après +223
                              String digits = value.substring(5).replaceAll(RegExp(r'[^0-9]'), '');
                              
                              // Limiter à 8 chiffres
                              if (digits.length > 8) {
                                digits = digits.substring(0, 8);
                              }

                              // Formater: 90 00 00 00
                              String formatted = '+223 ';
                              for (int i = 0; i < digits.length; i++) {
                                if (i > 0 && i % 2 == 0) {
                                  formatted += ' ';
                                }
                                formatted += digits[i];
                              }

                              if (formatted != value) {
                                _phoneController.text = formatted;
                                _phoneController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: formatted.length),
                                );
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty || value == '+223 ') {
                                return 'Veuillez entrer votre numéro';
                              }
                              final digits = value.substring(5).replaceAll(' ', '');
                              if (digits.length != 8) {
                                return 'Le numéro doit contenir 8 chiffres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock, color: AgentColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: AgentColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Bouton connexion
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AgentColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Lien inscription
                  TextButton(
                    onPressed: () {
                      context.push('/agent/register');
                    },
                    child: const Text(
                      'Devenir agent JUFA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
