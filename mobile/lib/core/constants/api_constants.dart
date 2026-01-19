class ApiConstants {
  ApiConstants._();
  
  static const String baseUrl = 'http://10.10.10.60:8080/api';
  static const String prodBaseUrl = 'https://api.jufa.ml/api';
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const String authRegister = '/v1/auth/register';
  static const String authVerifyOtp = '/v1/auth/verify-otp';
  static const String authLogin = '/v1/auth/login';
  static const String authRefreshToken = '/v1/auth/refresh-token';
  static const String authVerifyPin = '/v1/auth/verify-pin';
  static const String authLogout = '/v1/auth/logout';
  
  static const String usersMe = '/v1/users/me';
  static const String usersProfile = '/v1/users/me/profile';
  
  static const String wallets = '/v1/wallets';
  static String walletById(String id) => '/v1/wallets/$id';
  static String walletTransactions(String id) => '/v1/wallets/$id/transactions';
  
  static const String transactions = '/v1/transactions';
  static const String transactionsTransfer = '/v1/transactions/transfer';
  static String transactionById(String id) => '/v1/transactions/$id';

  static const String kycStatus = '/v1/kyc/status';
  static const String kycDocuments = '/v1/kyc/documents';

  static const String merchantProfile = '/v1/merchants/profile';
  static const String merchantDashboard = '/v1/merchants/dashboard';
  static const String merchantWholesalers = '/v1/merchants/wholesalers';
  static const String merchantRetailers = '/v1/merchants/retailers';
  static const String merchantMyWholesalers = '/v1/merchants/my-wholesalers';
  static String merchantRelation(String id) => '/v1/merchants/relations/$id';
  static String merchantRelationApprove(String id) => '/v1/merchants/relations/$id/approve';
  static String merchantRelationSuspend(String id) => '/v1/merchants/relations/$id/suspend';

  static const String qrGenerate = '/v1/qr/generate';
  static String qrScan(String token) => '/v1/qr/scan/$token';
  static const String qrPay = '/v1/qr/pay';
  static const String qrMyCodes = '/v1/qr/my-codes';
  static const String qrPayments = '/v1/qr/payments';
  static const String qrReceived = '/v1/qr/received';
  static String qrDeactivate(String id) => '/v1/qr/codes/$id';

  static const String notifications = '/v1/notifications';
  static const String notificationsUnreadCount = '/v1/notifications/unread-count';
  static String notificationMarkRead(String id) => '/v1/notifications/$id/read';
  static const String notificationsReadAll = '/v1/notifications/read-all';
  static const String notificationsFcmToken = '/v1/notifications/fcm-token';

  static const String momoProviders = '/v1/mobile-money/providers';
  static const String momoDeposit = '/v1/mobile-money/deposit';
  static const String momoDepositConfirm = '/v1/mobile-money/deposit/confirm';
  static const String momoWithdrawal = '/v1/mobile-money/withdrawal';
  static String momoCancelOperation(String ref) => '/v1/mobile-money/cancel/$ref';
  static String momoOperation(String ref) => '/v1/mobile-money/operations/$ref';
  static const String momoOperations = '/v1/mobile-money/operations';
  static const String momoDeposits = '/v1/mobile-money/deposits';
  static const String momoWithdrawals = '/v1/mobile-money/withdrawals';

  static String b2bCatalogCategories(String wholesalerId) => '/v1/b2b/catalog/categories/$wholesalerId';
  static const String b2bCreateCategory = '/v1/b2b/catalog/categories';
  static String b2bUpdateCategory(String categoryId) => '/v1/b2b/catalog/categories/$categoryId';
  static String b2bCatalogProducts(String wholesalerId) => '/v1/b2b/catalog/products/$wholesalerId';
  static String b2bCatalogProductsByCategory(String wholesalerId, String categoryId) => '/v1/b2b/catalog/products/$wholesalerId/category/$categoryId';
  static String b2bCatalogSearch(String wholesalerId) => '/v1/b2b/catalog/products/$wholesalerId/search';
  static String b2bCatalogFeatured(String wholesalerId) => '/v1/b2b/catalog/products/$wholesalerId/featured';
  static String b2bProduct(String id) => '/v1/b2b/catalog/product/$id';
  static const String b2bCreateProduct = '/v1/b2b/catalog/products';
  static String b2bUpdateProduct(String productId) => '/v1/b2b/catalog/products/$productId';
  static String b2bUpdateStock(String productId) => '/v1/b2b/catalog/products/$productId/stock';
  static const String b2bLowStockProducts = '/v1/b2b/catalog/products/low-stock';
  
  static const String b2bOrdersCreate = '/v1/b2b/orders';
  static const String b2bOrdersRetailer = '/v1/b2b/orders/retailer';
  static const String b2bOrdersWholesaler = '/v1/b2b/orders/wholesaler';
  static String b2bOrdersWholesalerById(String wholesalerId) => '/v1/b2b/orders/wholesaler/$wholesalerId';
  static String b2bOrdersPendingCount(String wholesalerId) => '/v1/b2b/orders/wholesaler/$wholesalerId/pending-count';
  static String b2bOrderConfirm(String orderId) => '/v1/b2b/orders/$orderId/confirm';
  static String b2bOrderStatus(String orderId) => '/v1/b2b/orders/$orderId/status';
  static String b2bOrderCancel(String orderId) => '/v1/b2b/orders/$orderId/cancel';

  static const String agentDashboard = '/v1/agent/dashboard';
  static const String agentCashIn = '/v1/agent/cash-in';
  static const String agentCashOut = '/v1/agent/cash-out';
  static String agentFeesCashIn(double amount) => '/v1/agent/fees/cash-in?amount=$amount';
  static String agentFeesCashOut(double amount) => '/v1/agent/fees/cash-out?amount=$amount';
  static const String agentTransactions = '/v1/agent/transactions';
  static const String agentTransactionsCashIn = '/v1/agent/transactions/cash-in';
  static const String agentTransactionsCashOut = '/v1/agent/transactions/cash-out';
  static const String agentReportsLast30Days = '/v1/agent/reports/last-30-days';
  static String agentReports(String startDate, String endDate) => '/v1/agent/reports?startDate=$startDate&endDate=$endDate';
  static const String agentProfile = '/v1/agent/profile';
  static const String agentVerifySecretCode = '/v1/agent/verify-secret-code';
  static const String agentUpdateSecretCode = '/v1/agent/update-secret-code';
  static String agentSearchClient(String phone) => '/v1/agent/search-client?phone=$phone';
}
