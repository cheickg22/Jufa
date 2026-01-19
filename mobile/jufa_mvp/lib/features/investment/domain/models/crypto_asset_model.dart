class CryptoAsset {
  final String id;
  final String symbol;
  final String name;
  final String iconUrl;
  final double currentPrice;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double marketCap;
  final double volume24h;
  final int marketCapRank;
  final DateTime lastUpdated;

  const CryptoAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.iconUrl,
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.volume24h,
    required this.marketCapRank,
    required this.lastUpdated,
  });

  factory CryptoAsset.fromJson(Map<String, dynamic> json) {
    return CryptoAsset(
      id: json['id'] ?? '',
      symbol: json['symbol']?.toString().toUpperCase() ?? '',
      name: json['name'] ?? '',
      iconUrl: json['image'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      priceChange24h: (json['price_change_24h'] ?? 0.0).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] ?? 0.0).toDouble(),
      marketCap: (json['market_cap'] ?? 0.0).toDouble(),
      volume24h: (json['total_volume'] ?? 0.0).toDouble(),
      marketCapRank: json['market_cap_rank'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Méthodes utilitaires
  bool get isPriceUp => priceChangePercentage24h > 0;
  String get formattedPrice => '\$${currentPrice.toStringAsFixed(currentPrice < 1 ? 6 : 2)}';
  String get formattedPriceChange => '${isPriceUp ? '+' : ''}${priceChangePercentage24h.toStringAsFixed(2)}%';
  String get formattedMarketCap => _formatLargeNumber(marketCap);
  String get formattedVolume => _formatLargeNumber(volume24h);

  String _formatLargeNumber(double number) {
    if (number >= 1e12) return '\$${(number / 1e12).toStringAsFixed(2)}T';
    if (number >= 1e9) return '\$${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '\$${(number / 1e6).toStringAsFixed(2)}M';
    if (number >= 1e3) return '\$${(number / 1e3).toStringAsFixed(2)}K';
    return '\$${number.toStringAsFixed(2)}';
  }
}

class CryptoPortfolio {
  final String id;
  final String userId;
  final String assetId;
  final String symbol;
  final double quantity;
  final double averageBuyPrice;
  final double currentPrice;
  final double totalValue;
  final double totalInvested;
  final double unrealizedPnl;
  final double unrealizedPnlPercentage;
  final DateTime firstPurchaseDate;
  final DateTime lastUpdated;

  const CryptoPortfolio({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.symbol,
    required this.quantity,
    required this.averageBuyPrice,
    required this.currentPrice,
    required this.totalValue,
    required this.totalInvested,
    required this.unrealizedPnl,
    required this.unrealizedPnlPercentage,
    required this.firstPurchaseDate,
    required this.lastUpdated,
  });

  factory CryptoPortfolio.fromJson(Map<String, dynamic> json) {
    return CryptoPortfolio(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      assetId: json['asset_id'] ?? '',
      symbol: json['symbol']?.toString().toUpperCase() ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      averageBuyPrice: (json['average_buy_price'] ?? 0.0).toDouble(),
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      totalValue: (json['total_value'] ?? 0.0).toDouble(),
      totalInvested: (json['total_invested'] ?? 0.0).toDouble(),
      unrealizedPnl: (json['unrealized_pnl'] ?? 0.0).toDouble(),
      unrealizedPnlPercentage: (json['unrealized_pnl_percentage'] ?? 0.0).toDouble(),
      firstPurchaseDate: DateTime.parse(json['first_purchase_date'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Méthodes utilitaires
  bool get isProfit => unrealizedPnl > 0;
  String get formattedQuantity => quantity.toStringAsFixed(quantity < 1 ? 8 : 4);
  String get formattedTotalValue => '\$${totalValue.toStringAsFixed(2)}';
  String get formattedPnl => '${isProfit ? '+' : ''}\$${unrealizedPnl.toStringAsFixed(2)}';
  String get formattedPnlPercentage => '${isProfit ? '+' : ''}${unrealizedPnlPercentage.toStringAsFixed(2)}%';
}

// Cryptomonnaies populaires
enum PopularCrypto {
  bitcoin('bitcoin', 'BTC', 'Bitcoin', '₿'),
  ethereum('ethereum', 'ETH', 'Ethereum', 'Ξ'),
  usdt('tether', 'USDT', 'Tether', '₮'),
  usdc('usd-coin', 'USDC', 'USD Coin', '\$'),
  bnb('binancecoin', 'BNB', 'BNB', 'BNB'),
  cardano('cardano', 'ADA', 'Cardano', '₳'),
  solana('solana', 'SOL', 'Solana', '◎'),
  polkadot('polkadot', 'DOT', 'Polkadot', '●');

  const PopularCrypto(this.id, this.symbol, this.name, this.symbolIcon);
  final String id;
  final String symbol;
  final String name;
  final String symbolIcon;
}

class CryptoTransaction {
  final String id;
  final String userId;
  final String assetId;
  final String symbol;
  final TransactionType type;
  final double quantity;
  final double price;
  final double totalAmount;
  final double fees;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;

  const CryptoTransaction({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.fees,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.metadata = const {},
  });

  factory CryptoTransaction.fromJson(Map<String, dynamic> json) {
    return CryptoTransaction(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      assetId: json['asset_id'] ?? '',
      symbol: json['symbol']?.toString().toUpperCase() ?? '',
      type: TransactionType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => TransactionType.buy,
      ),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      fees: (json['fees'] ?? 0.0).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      metadata: json['metadata'] ?? {},
    );
  }

  // Méthodes utilitaires
  String get formattedAmount => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedQuantity => quantity.toStringAsFixed(quantity < 1 ? 8 : 4);
  String get typeDisplayName => type.displayName;
  String get statusDisplayName => status.displayName;
}

enum TransactionType {
  buy('buy', 'Achat', '📈'),
  sell('sell', 'Vente', '📉'),
  stake('stake', 'Staking', '🔒'),
  unstake('unstake', 'Unstaking', '🔓');

  const TransactionType(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

enum TransactionStatus {
  pending('pending', 'En attente', '⏳'),
  processing('processing', 'En cours', '⚡'),
  completed('completed', 'Terminé', '✅'),
  failed('failed', 'Échoué', '❌'),
  cancelled('cancelled', 'Annulé', '🚫');

  const TransactionStatus(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}
