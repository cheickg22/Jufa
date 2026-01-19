import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/agent.dart';

class AgentAuthService {
  static const String _tokenKey = 'agent_token';
  static const String _agentKey = 'agent_data';

  // Sauvegarder le token et les données de l'agent
  static Future<void> saveAuth(String token, Agent agent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_agentKey, jsonEncode({
      'id': agent.id,
      'agent_code': agent.agentCode,
      'first_name': agent.firstName,
      'last_name': agent.lastName,
      'phone': agent.phone,
      'email': agent.email,
      'status': agent.status,
      'balance': agent.balance,
      'commission_rate': agent.commissionRate,
      'deposit_commission_rate': agent.depositCommissionRate,
      'withdrawal_commission_rate': agent.withdrawalCommissionRate,
      'address': agent.address,
      'city': agent.city,
      'id_card_type': agent.idCardType,
      'id_card_number': agent.idCardNumber,
      'secret_code': agent.secretCode,
    }));
  }

  // Sauvegarder uniquement les données de l'agent (sans token)
  static Future<void> saveAgent(Agent agent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_agentKey, jsonEncode({
      'id': agent.id,
      'agent_code': agent.agentCode,
      'first_name': agent.firstName,
      'last_name': agent.lastName,
      'phone': agent.phone,
      'email': agent.email,
      'status': agent.status,
      'balance': agent.balance,
      'commission_rate': agent.commissionRate,
      'deposit_commission_rate': agent.depositCommissionRate,
      'withdrawal_commission_rate': agent.withdrawalCommissionRate,
      'address': agent.address,
      'city': agent.city,
      'id_card_type': agent.idCardType,
      'id_card_number': agent.idCardNumber,
      'secret_code': agent.secretCode,
    }));
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Récupérer les données de l'agent
  static Future<Agent?> getAgent() async {
    final prefs = await SharedPreferences.getInstance();
    final agentJson = prefs.getString(_agentKey);
    if (agentJson == null) return null;
    
    final data = jsonDecode(agentJson);
    return Agent.fromJson(data);
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_agentKey);
  }

  // Vérifier si l'agent est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
