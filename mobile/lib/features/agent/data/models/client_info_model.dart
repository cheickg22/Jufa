import '../../domain/entities/client_info.dart';

class ClientInfoModel extends ClientInfo {
  const ClientInfoModel({
    required super.phone,
    super.name,
    super.walletNumber,
    super.balance,
  });

  factory ClientInfoModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final wallet = json['wallet'] as Map<String, dynamic>? ?? {};
    
    String? name;
    if (user['name'] != null) {
      name = user['name'] as String;
    } else {
      final firstName = user['firstName'] ?? user['first_name'] ?? '';
      final lastName = user['lastName'] ?? user['last_name'] ?? '';
      name = '$firstName $lastName'.trim();
      if (name.isEmpty) name = null;
    }
    
    return ClientInfoModel(
      phone: user['phone'] as String? ?? json['phone'] as String? ?? '',
      name: name,
      walletNumber: wallet['walletNumber'] ?? wallet['wallet_number'] as String?,
      balance: (wallet['balance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'name': name,
      'walletNumber': walletNumber,
      'balance': balance,
    };
  }
}
