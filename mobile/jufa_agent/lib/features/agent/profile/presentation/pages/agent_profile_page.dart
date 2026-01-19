import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/agent_colors.dart';
import '../../../../../core/services/agent_auth_service.dart';
import '../../../../../core/services/agent_api_service.dart';
import '../../../../../core/models/agent.dart';

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({super.key});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  final AgentApiService _apiService = AgentApiService();
  Agent? _agent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final agent = await AgentAuthService.getAgent();
      if (mounted) {
        setState(() {
          _agent = agent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgentColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agent == null
              ? const Center(child: Text('Erreur de chargement'))
              : CustomScrollView(
                  slivers: [
                    // AppBar avec gradient
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      backgroundColor: AgentColors.primary,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: AgentColors.primaryGradient,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Avatar avec badge
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const CircleAvatar(
                                        radius: 38,
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.person, size: 38, color: AgentColors.primary),
                                      ),
                                    ),
                                    // Badge vérifié
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AgentColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _agent!.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Code: ${_agent!.agentCode}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Contenu
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Badge Approuvé
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AgentColors.success.withOpacity(0.1),
                                    AgentColors.success.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AgentColors.success, width: 2),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.verified_user,
                                    color: AgentColors.success,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Approuvé agent Jufa',
                                    style: TextStyle(
                                      color: AgentColors.success,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Informations personnelles
                            const Text(
                              'Informations personnelles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AgentColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AgentColors.cardShadow,
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow('Téléphone', _agent!.phone, Icons.phone),
                                  const Divider(height: 24),
                                  _buildInfoRow('Email', _agent!.email ?? 'Non renseigné', Icons.email),
                                  const Divider(height: 24),
                                  _buildInfoRow('Adresse', _agent!.address ?? 'Non renseigné', Icons.location_on),
                                  const Divider(height: 24),
                                  _buildInfoRow('Ville', _agent!.city ?? 'N/A', Icons.location_city),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Informations professionnelles
                            const Text(
                              'Informations professionnelles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AgentColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AgentColors.cardShadow,
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow('Statut', _agent!.status.toUpperCase(), Icons.info),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Solde',
                                    '${NumberFormat('#,###', 'fr_FR').format(_agent!.balance).replaceAll(',', ' ')} FCFA',
                                    Icons.account_balance_wallet,
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Commission dépôt',
                                    '${_agent!.depositCommissionRate}%',
                                    Icons.arrow_downward,
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Commission retrait',
                                    '${_agent!.withdrawalCommissionRate}%',
                                    Icons.arrow_upward,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Configuration du code secret
                            if (_agent!.secretCode == null || _agent!.secretCode!.isEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AgentColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AgentColors.warning),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning, color: AgentColors.warning),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Configurez un code secret pour protéger votre solde',
                                        style: TextStyle(
                                          color: AgentColors.textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _configureSecretCode,
                                  icon: const Icon(Icons.lock),
                                  label: const Text('Configurer le code secret'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AgentColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AgentColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AgentColors.success),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AgentColors.success),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Code secret configuré',
                                        style: TextStyle(
                                          color: AgentColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: _changeSecretCode,
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Modifier le code secret'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AgentColors.primary,
                                    side: const BorderSide(color: AgentColors.primary, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _changeSecretCode() async {
    final oldCodeController = TextEditingController();
    
    // D'abord vérifier l'ancien code
    final oldCodeVerified = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vérification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre code secret actuel',
              style: TextStyle(color: AgentColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: oldCodeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Code secret actuel',
                border: OutlineInputBorder(),
                counterText: '',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (oldCodeController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le code doit contenir 4 chiffres'),
                    backgroundColor: AgentColors.error,
                  ),
                );
                return;
              }
              
              // Vérifier le code via l'API
              try {
                final result = await _apiService.verifySecretCode(oldCodeController.text);
                if (result['success'] == true) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Code secret incorrect'),
                      backgroundColor: AgentColors.error,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur de vérification'),
                    backgroundColor: AgentColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AgentColors.primary),
            child: const Text('Vérifier', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (oldCodeVerified != true) return;

    // Si l'ancien code est correct, demander le nouveau
    await _configureSecretCode();
  }

  Future<void> _configureSecretCode() async {
    final codeController = TextEditingController();
    final confirmController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Configurer le code secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ce code vous permettra de voir votre solde UV',
              style: TextStyle(color: AgentColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Code secret (4 chiffres)',
                border: OutlineInputBorder(),
                counterText: '',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le code',
                border: OutlineInputBorder(),
                counterText: '',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le code doit contenir 4 chiffres')),
                );
                return;
              }
              
              if (codeController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Les codes ne correspondent pas')),
                );
                return;
              }
              
              Navigator.pop(context, codeController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AgentColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Configurer'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        // Envoyer le code au backend
        await _apiService.updateSecretCode(result);
        
        // Mettre à jour l'agent local (marquer comme configuré)
        setState(() {
          _agent = Agent(
            id: _agent!.id,
            agentCode: _agent!.agentCode,
            firstName: _agent!.firstName,
            lastName: _agent!.lastName,
            phone: _agent!.phone,
            email: _agent!.email,
            status: _agent!.status,
            balance: _agent!.balance,
            commissionRate: _agent!.commissionRate,
            depositCommissionRate: _agent!.depositCommissionRate,
            withdrawalCommissionRate: _agent!.withdrawalCommissionRate,
            address: _agent!.address,
            city: _agent!.city,
            idCardType: _agent!.idCardType,
            idCardNumber: _agent!.idCardNumber,
            secretCode: 'configured',
          );
        });

        // Sauvegarder dans le stockage local
        await AgentAuthService.saveAgent(_agent!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code secret configuré avec succès'),
              backgroundColor: AgentColors.success,
            ),
          );
          // Retourner true pour indiquer que la configuration est terminée
          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: AgentColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AgentColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AgentColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AgentColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
