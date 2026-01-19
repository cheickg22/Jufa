import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStreamProvider);
  return connectivity.when(
    data: (status) => status == ConnectivityStatus.online,
    loading: () => true,
    error: (_, __) => false,
  );
});

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  
  ConnectivityService() {
    _init();
  }
  
  void _init() {
    _connectivity.onConnectivityChanged.listen((results) {
      final status = _mapResultsToStatus(results);
      _controller.add(status);
    });
    
    checkConnectivity();
  }
  
  Stream<ConnectivityStatus> get connectivityStream => _controller.stream;
  
  Future<ConnectivityStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final status = _mapResultsToStatus(results);
    _controller.add(status);
    return status;
  }
  
  ConnectivityStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }
  
  void dispose() {
    _controller.close();
  }
}
