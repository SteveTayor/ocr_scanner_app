import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _networkController =
      StreamController<bool>.broadcast();

  NetworkChecker() {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _networkController.add(results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none));
    });
  }

  /// Check current internet connection
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Stream for real-time connection status
  Stream<bool> get networkStatusStream => _networkController.stream;

  /// Dispose the controller when not needed
  void dispose() {
    _networkController.close();
  }
}
