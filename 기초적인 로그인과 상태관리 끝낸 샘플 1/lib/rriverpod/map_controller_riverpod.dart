import 'package:riverpod/riverpod.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';


final mapControllerProvider = Provider<MapController>((ref) {
  // MapController의 인스턴스를 생성하여 반환
  return MapController.withUserPosition(
    trackUserLocation: const UserTrackingOption(
      enableTracking: true,
      unFollowUser: false,
    ),
  );
});