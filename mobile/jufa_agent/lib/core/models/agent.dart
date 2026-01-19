class Agent {
  final int id;
  final String agentCode;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String status;
  final double balance;
  final double commissionRate;
  final double depositCommissionRate;
  final double withdrawalCommissionRate;
  final String? address;
  final String? city;
  final String? idCardType;
  final String? idCardNumber;
  final String? secretCode;

  Agent({
    required this.id,
    required this.agentCode,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    required this.status,
    required this.balance,
    required this.commissionRate,
    required this.depositCommissionRate,
    required this.withdrawalCommissionRate,
    this.address,
    this.city,
    this.idCardType,
    this.idCardNumber,
    this.secretCode,
  });

  String get fullName => '$firstName $lastName';

  factory Agent.fromJson(Map<String, dynamic> json) {
    print('🔍 Agent.fromJson - Données reçues:');
    print('   commission_rate: ${json['commission_rate']}');
    print('   deposit_commission_rate: ${json['deposit_commission_rate']}');
    print('   withdrawal_commission_rate: ${json['withdrawal_commission_rate']}');
    
    final depositRate = (json['deposit_commission_rate'] as num? ?? 1.0).toDouble();
    final withdrawalRate = (json['withdrawal_commission_rate'] as num? ?? 1.0).toDouble();
    
    print('✅ Taux parsés:');
    print('   depositCommissionRate: $depositRate');
    print('   withdrawalCommissionRate: $withdrawalRate');
    
    return Agent(
      id: json['id'],
      agentCode: json['agent_code'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      status: json['status'],
      balance: (json['balance'] as num).toDouble(),
      commissionRate: (json['commission_rate'] as num? ?? json['deposit_commission_rate'] as num? ?? 1.0).toDouble(),
      depositCommissionRate: depositRate,
      withdrawalCommissionRate: withdrawalRate,
      address: json['address'],
      city: json['city'],
      idCardType: json['id_card_type'],
      idCardNumber: json['id_card_number'],
      secretCode: json['secret_code'],
    );
  }
}
