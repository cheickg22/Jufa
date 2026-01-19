import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final offlineCacheServiceProvider = Provider<OfflineCacheService>((ref) {
  return OfflineCacheService();
});

class OfflineCacheService {
  static const String _userBox = 'user_cache';
  static const String _walletBox = 'wallet_cache';
  static const String _transactionsBox = 'transactions_cache';
  static const String _settingsBox = 'settings_cache';
  
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_userBox);
    await Hive.openBox(_walletBox);
    await Hive.openBox(_transactionsBox);
    await Hive.openBox(_settingsBox);
  }
  
  Future<void> cacheUser(Map<String, dynamic> userData) async {
    final box = Hive.box(_userBox);
    await box.put('current_user', userData);
    await box.put('cached_at', DateTime.now().toIso8601String());
  }
  
  Map<String, dynamic>? getCachedUser() {
    final box = Hive.box(_userBox);
    final data = box.get('current_user');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
  
  Future<void> cacheWallet(Map<String, dynamic> walletData) async {
    final box = Hive.box(_walletBox);
    await box.put('current_wallet', walletData);
    await box.put('cached_at', DateTime.now().toIso8601String());
  }
  
  Map<String, dynamic>? getCachedWallet() {
    final box = Hive.box(_walletBox);
    final data = box.get('current_wallet');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
  
  Future<void> cacheTransactions(List<Map<String, dynamic>> transactions) async {
    final box = Hive.box(_transactionsBox);
    await box.put('transactions', transactions);
    await box.put('cached_at', DateTime.now().toIso8601String());
  }
  
  List<Map<String, dynamic>>? getCachedTransactions() {
    final box = Hive.box(_transactionsBox);
    final data = box.get('transactions');
    if (data != null) {
      return List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return null;
  }
  
  DateTime? getLastCacheTime(String boxName) {
    final box = Hive.box(boxName);
    final cachedAt = box.get('cached_at');
    if (cachedAt != null) {
      return DateTime.parse(cachedAt);
    }
    return null;
  }
  
  bool isCacheValid(String boxName, {Duration maxAge = const Duration(hours: 24)}) {
    final lastCached = getLastCacheTime(boxName);
    if (lastCached == null) return false;
    return DateTime.now().difference(lastCached) < maxAge;
  }
  
  Future<void> clearUserCache() async {
    final box = Hive.box(_userBox);
    await box.clear();
  }
  
  Future<void> clearWalletCache() async {
    final box = Hive.box(_walletBox);
    await box.clear();
  }
  
  Future<void> clearTransactionsCache() async {
    final box = Hive.box(_transactionsBox);
    await box.clear();
  }
  
  Future<void> clearAllCache() async {
    await clearUserCache();
    await clearWalletCache();
    await clearTransactionsCache();
  }
  
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }
  
  T? getSetting<T>(String key) {
    final box = Hive.box(_settingsBox);
    return box.get(key) as T?;
  }
}
