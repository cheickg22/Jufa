import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../storage/secure_storage_service.dart';
import '../network/api_client.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return BiometricService(storage);
});

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final SecureStorageService _storage;
  
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserPhoneKey = 'biometric_user_phone';
  static const String _biometricUserPasswordKey = 'biometric_user_password';
  
  BiometricService(this._storage);
  
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }
  
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }
  
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }
  
  Future<bool> isBiometricAvailable() async {
    final isSupported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    final biometrics = await getAvailableBiometrics();
    return isSupported && canCheck && biometrics.isNotEmpty;
  }
  
  Future<bool> authenticate({String reason = 'Authentifiez-vous pour accéder à JUFA'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
  
  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(_biometricEnabledKey);
    return enabled == 'true';
  }
  
  Future<void> enableBiometric(String phone, String password) async {
    await _storage.write(_biometricEnabledKey, 'true');
    await _storage.write(_biometricUserPhoneKey, phone);
    await _storage.write(_biometricUserPasswordKey, password);
  }
  
  Future<void> disableBiometric() async {
    await _storage.delete(_biometricEnabledKey);
    await _storage.delete(_biometricUserPhoneKey);
    await _storage.delete(_biometricUserPasswordKey);
  }
  
  Future<Map<String, String>?> getBiometricCredentials() async {
    final phone = await _storage.read(_biometricUserPhoneKey);
    final password = await _storage.read(_biometricUserPasswordKey);
    
    if (phone != null && password != null) {
      return {'phone': phone, 'password': password};
    }
    return null;
  }
  
  Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Empreinte digitale';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biométrie';
  }
}

class BiometricState {
  final bool isAvailable;
  final bool isEnabled;
  final String biometricTypeName;
  final bool isLoading;
  
  const BiometricState({
    this.isAvailable = false,
    this.isEnabled = false,
    this.biometricTypeName = 'Biométrie',
    this.isLoading = false,
  });
  
  BiometricState copyWith({
    bool? isAvailable,
    bool? isEnabled,
    String? biometricTypeName,
    bool? isLoading,
  }) {
    return BiometricState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      biometricTypeName: biometricTypeName ?? this.biometricTypeName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricService _service;
  
  BiometricNotifier(this._service) : super(const BiometricState()) {
    _init();
  }
  
  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final isAvailable = await _service.isBiometricAvailable();
    final isEnabled = await _service.isBiometricEnabled();
    final typeName = await _service.getBiometricTypeName();
    
    state = BiometricState(
      isAvailable: isAvailable,
      isEnabled: isEnabled,
      biometricTypeName: typeName,
      isLoading: false,
    );
  }
  
  Future<bool> authenticate() async {
    return await _service.authenticate();
  }
  
  Future<void> enable(String phone, String password) async {
    await _service.enableBiometric(phone, password);
    state = state.copyWith(isEnabled: true);
  }
  
  Future<void> disable() async {
    await _service.disableBiometric();
    state = state.copyWith(isEnabled: false);
  }
  
  Future<Map<String, String>?> getCredentials() async {
    return await _service.getBiometricCredentials();
  }
}

final biometricNotifierProvider = StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  final service = ref.watch(biometricServiceProvider);
  return BiometricNotifier(service);
});
