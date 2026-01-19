import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/services/agent_api_service.dart';
import '../../../../../core/theme/agent_colors.dart';

class AgentRegisterPage extends StatefulWidget {
  const AgentRegisterPage({super.key});

  @override
  State<AgentRegisterPage> createState() => _AgentRegisterPageState();
}

class _AgentRegisterPageState extends State<AgentRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+223 ');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idCardNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  
  final AgentApiService _agentApiService = AgentApiService();
  final ImagePicker _imagePicker = ImagePicker();
  
  String? _selectedIdCardType;
  XFile? _idCardFrontImage;
  XFile? _idCardBackImage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idCardNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _pickIdCardImage(bool isFront) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          if (isFront) {
            _idCardFrontImage = image;
          } else {
            _idCardBackImage = image;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: AgentColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: AgentColors.error,
        ),
      );
      return;
    }
    
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: AgentColors.error,
        ),
      );
      return;
    }
    
    if (_selectedIdCardType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un type de pièce d\'identité'),
          backgroundColor: AgentColors.error,
        ),
      );
      return;
    }
    
    if (_idCardFrontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter la photo recto de votre pièce d\'identité'),
          backgroundColor: AgentColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Lire les bytes des images
      final frontImageBytes = _idCardFrontImage != null ? await _idCardFrontImage!.readAsBytes() : null;
      final backImageBytes = _idCardBackImage != null ? await _idCardBackImage!.readAsBytes() : null;
      
      final phone = _phoneController.text.replaceAll(' ', '');
      
      await _agentApiService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: phone,
        email: '', // Email optionnel
        password: _passwordController.text,
        idCardType: _selectedIdCardType ?? 'nina',
        idCardNumber: _idCardNumberController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        idCardFrontImageBytes: frontImageBytes,
        idCardBackImageBytes: backImageBytes,
      );
      
      // Sauvegarder le numéro de téléphone pour la vérification du rejet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_agent_phone', phone);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Inscription envoyée'),
            content: const Text(
              'Votre demande d\'inscription a été envoyée avec succès.\n\n'
              'Elle sera examinée par notre équipe. Vous recevrez une notification '
              'une fois votre compte validé.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/agent/login');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AgentColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Devenir Agent JUFA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AgentColors.primaryLight, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Agent
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
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
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Inscription Agent',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AgentColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Remplissez le formulaire pour devenir agent JUFA',
                    style: TextStyle(
                      fontSize: 14,
                      color: AgentColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Formulaire
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AgentColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations personnelles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AgentColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Prénom
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            prefixIcon: const Icon(Icons.person, color: AgentColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre prénom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Nom
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            prefixIcon: const Icon(Icons.person_outline, color: AgentColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        const SizedBox(height: 24),
                        
                        // Pièce d'identité
                        const Text(
                          'Pièce d\'identité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AgentColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Type de pièce
                        DropdownButtonFormField<String>(
                          value: _selectedIdCardType,
                          decoration: InputDecoration(
                            labelText: 'Type de pièce *',
                            hintText: 'Sélectionnez un type de pièce',
                            prefixIcon: const Icon(Icons.badge, color: AgentColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'nina', child: Text('Carte NINA')),
                            DropdownMenuItem(value: 'biometric', child: Text('Carte Biométrique')),
                            DropdownMenuItem(value: 'passport', child: Text('Passeport')),
                            DropdownMenuItem(value: 'driving_license', child: Text('Permis de conduire')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedIdCardType = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Numéro de pièce
                        TextFormField(
                          controller: _idCardNumberController,
                          decoration: InputDecoration(
                            labelText: 'Numéro de pièce',
                            prefixIcon: const Icon(Icons.numbers, color: AgentColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le numéro de pièce';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Photos de la pièce
                        Row(
                          children: [
                            Expanded(
                              child: _buildImagePicker(
                                'Photo Recto *',
                                _idCardFrontImage,
                                () => _pickIdCardImage(true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildImagePicker(
                                'Photo Verso (si applicable)',
                                _idCardBackImage,
                                () => _pickIdCardImage(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Localisation
                        const Text(
                          'Localisation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AgentColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Adresse
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Adresse',
                            prefixIcon: const Icon(Icons.location_on, color: AgentColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Ville
                        TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'Ville',
                            prefixIcon: const Icon(Icons.location_city, color: AgentColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Région
                        TextFormField(
                          controller: _regionController,
                          decoration: InputDecoration(
                            labelText: 'Région',
                            prefixIcon: const Icon(Icons.map, color: AgentColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Sécurité
                        const Text(
                          'Sécurité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AgentColors.primary,
                          ),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Confirmation mot de passe
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline, color: AgentColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                color: AgentColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AgentColors.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer le mot de passe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Bouton inscription
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
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
                                    'S\'inscrire',
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
                  const SizedBox(height: 16),
                  
                  // Accepter les conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                        activeColor: AgentColors.primary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptedTerms = !_acceptedTerms;
                            });
                          },
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: AgentColors.textSecondary,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: 'J\'accepte les '),
                                TextSpan(
                                  text: 'conditions d\'utilisation',
                                  style: TextStyle(
                                    color: AgentColors.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' et la '),
                                TextSpan(
                                  text: 'politique de confidentialité',
                                  style: TextStyle(
                                    color: AgentColors.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Retour connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Déjà agent ? '),
                      TextButton(
                        onPressed: () => context.go('/agent/login'),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: AgentColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePicker(String label, XFile? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: image != null ? AgentColors.success.withOpacity(0.1) : AgentColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null ? AgentColors.success : AgentColors.border,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              image != null ? Icons.check_circle : Icons.add_a_photo,
              size: 40,
              color: image != null ? AgentColors.success : AgentColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: image != null ? AgentColors.success : AgentColors.textSecondary,
                fontWeight: image != null ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            if (image != null)
              const Text(
                'Ajoutée ✓',
                style: TextStyle(
                  fontSize: 10,
                  color: AgentColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
