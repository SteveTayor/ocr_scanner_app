import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkChecker {
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
