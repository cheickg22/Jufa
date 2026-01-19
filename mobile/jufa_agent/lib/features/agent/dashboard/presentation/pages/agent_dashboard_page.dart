import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/agent_colors.dart';
import '../../../../../core/services/agent_api_service.dart';
import '../../../../../core/services/agent_auth_service.dart';
import '../../../../../core/models/agent.dart';

class AgentDashboardPage extends StatefulWidget {
  const AgentDashboardPage({super.key});

  @override
  State<AgentDashboardPage> createState() => _AgentDashboardPageState();
}

class _AgentDashboardPageState extends State<AgentDashboardPage> {
  final AgentApiService _agentApiService = AgentApiService();
  Agent? _agent;
  bool _isLoading = true;
  bool _balanceVisible = false;
  double _todayDeposits = 0;
  double _todayWithdrawals = 0;
  double _todayCommission = 0;

  @override
  void initState() {
    super.initState();
    _loadAgentData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les données quand on revient sur la page
    _loadAgentData();
  }

  Future<void> _loadAgentData() async {
    setState(() => _isLoading = true);
    
    try {
      final token = await AgentAuthService.getToken();
      
      if (token != null) {
        // Recharger le profil depuis l'API pour avoir le solde à jour
        final profileData = await _agentApiService.getProfile(token);
        if (profileData.isNotEmpty) {
          final updatedAgent = Agent.fromJson(profileData);
          await AgentAuthService.saveAgent(updatedAgent);
        }
        
        // Charger l'agent depuis le cache (maintenant à jour)
        final agent = await AgentAuthService.getAgent();
        
        // Charger les statistiques
        final stats = await _agentApiService.getStats(token);
        if (stats.isNotEmpty) {
          // Les données sont directement dans stats (pas dans stats['data'])
          final deposits = stats['deposits'] as List? ?? [];
          final withdrawals = stats['withdrawals'] as List? ?? [];
          
          if (mounted) {
            setState(() {
              _agent = agent;
              // Calculer les totaux du jour à partir des listes
              _todayDeposits = deposits.fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0) as num).toDouble());
              _todayWithdrawals = withdrawals.fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0) as num).toDouble());
              _todayCommission = (stats['total_commissions'] ?? 0).toDouble();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _agent = agent;
              _isLoading = false;
            });
          }
        }
      } else {
        final agent = await AgentAuthService.getAgent();
        if (mounted) {
          setState(() {
            _agent = agent;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Erreur chargement données: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSecretCodeDialog() async {
    final codeController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Code secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre code secret pour voir le solde',
              style: TextStyle(color: AgentColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Code secret',
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
              if (codeController.text.length != 4) {
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
                final result = await _agentApiService.verifySecretCode(codeController.text);
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
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _balanceVisible = true);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AgentColors.error),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AgentAuthService.logout();
      if (mounted) {
        context.go('/agent/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_agent == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Erreur de chargement'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AgentColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAgentData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header avec nom et déconnexion
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AgentColors.primaryGradient,
                  ),
                  child: Row(
                    children: [
                      // Bienvenue + Nom
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bienvenue',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _agent!.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                      
                      // Profil et Déconnexion
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () => context.push('/agent/profile'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Solde UV au milieu
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AgentColors.cardShadow,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Solde UV',
                              style: TextStyle(
                                color: AgentColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _balanceVisible
                                      ? '${NumberFormat('#,###', 'fr_FR').format(_agent!.balance).replaceAll(',', ' ')} FCFA'
                                      : '••••• FCFA',
                                  style: const TextStyle(
                                    color: AgentColors.primary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: Icon(
                                    _balanceVisible ? Icons.visibility : Icons.visibility_off,
                                    color: AgentColors.primary,
                                  ),
                                  onPressed: () async {
                                    if (_balanceVisible) {
                                      setState(() => _balanceVisible = false);
                                    } else {
                                      // Vérifier si le code secret est configuré
                                      if (_agent!.secretCode == null || _agent!.secretCode!.isEmpty) {
                                        // Rediriger vers le profil pour configurer le code
                                        final result = await context.push('/agent/profile');
                                        if (result == true) {
                                          // Recharger les données après configuration
                                          await _loadAgentData();
                                        }
                                      } else {
                                        // Demander le code secret
                                        _showSecretCodeDialog();
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Commission dépôt
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_upward,
                                      color: AgentColors.success,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_agent!.depositCommissionRate}%',
                                      style: const TextStyle(
                                        color: AgentColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                // Commission retrait
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_downward,
                                      color: AgentColors.warning,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_agent!.withdrawalCommissionRate}%',
                                      style: const TextStyle(
                                        color: AgentColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Transactions d'aujourd'hui
                      const Text(
                        'Transactions d\'aujourd\'hui',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AgentColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cartes Dépôt, Retrait et Commission
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Dépôt',
                              _todayDeposits > 0 
                                  ? '${NumberFormat('#,###', 'fr_FR').format(_todayDeposits).replaceAll(',', ' ')} FCFA'
                                  : '0 FCFA',
                              Icons.arrow_downward,
                              AgentColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Retrait',
                              _todayWithdrawals > 0
                                  ? '${NumberFormat('#,###', 'fr_FR').format(_todayWithdrawals).replaceAll(',', ' ')} FCFA'
                                  : '0 FCFA',
                              Icons.arrow_upward,
                              AgentColors.error,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Commission',
                              _todayCommission > 0
                                  ? '${NumberFormat('#,###', 'fr_FR').format(_todayCommission).replaceAll(',', ' ')} FCFA'
                                  : '0 FCFA',
                              Icons.monetization_on,
                              AgentColors.warning,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Actions rapides
                      const Text(
                        'Actions rapides',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AgentColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cartes d'actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              'Dépôt',
                              Icons.add_circle_outline,
                              AgentColors.success,
                              () => context.push('/agent/deposit'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              'Retrait',
                              Icons.remove_circle_outline,
                              AgentColors.error,
                              () => context.push('/agent/withdrawal'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        'Historique des transactions',
                        Icons.history,
                        AgentColors.primary,
                        () => context.push('/agent/transactions'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AgentColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgentColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AgentColors.cardShadow,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
