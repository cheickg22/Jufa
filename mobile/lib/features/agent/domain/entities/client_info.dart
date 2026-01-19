class ClientInfo {
  final String phone;
  final String? name;
  final String? walletNumber;
  final double? balance;

  const ClientInfo({
    required this.phone,
    this.name,
    this.walletNumber,
    this.balance,
  });
}
