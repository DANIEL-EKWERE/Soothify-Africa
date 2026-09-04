import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Tracks connectivity for the whole app. Offline is a normal state here,
/// not an error — screens read from the local store either way.
class NetworkInfo extends GetxService {
  final Connectivity _connectivity = Connectivity();

  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  /// True when the only connection is mobile data — used to honour the
  /// "download over Wi-Fi only" preference.
  bool get isOnMobileData => connectionType.value == ConnectivityResult.mobile;

  bool get isOnWifi => connectionType.value == ConnectivityResult.wifi;

  Future<NetworkInfo> init() async {
    _apply(await _connectivity.checkConnectivity());
    _connectivity.onConnectivityChanged.listen(_apply);
    return this;
  }

  void _apply(List<ConnectivityResult> results) {
    final active = results.firstWhere(
      (r) => r != ConnectivityResult.none,
      orElse: () => ConnectivityResult.none,
    );
    connectionType.value = active;
    isConnected.value = active != ConnectivityResult.none;
  }
}
