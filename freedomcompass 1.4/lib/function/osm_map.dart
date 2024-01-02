import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
// init the position using the user location
  final controller = MapController(
    initMapWithUserPosition:  const UserTrackingOption()
  );

  Future<void> getLocationAndUpdateMap(MapController controller) async {
    // 비동기 함수 내에서 await 사용
    await controller.currentLocation();
  }

  MapController get mapController => controller;
  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
        controller:controller,

        osmOption: OSMOption(
          userTrackingOption: const UserTrackingOption(
            enableTracking: true,
            unFollowUser: false,
          ),
          zoomOption: const ZoomOption(
            initZoom: 8,
            minZoomLevel: 2,
            // 이거는 축소시키는 최소 속도를 말하는거다. 높이면 축소가 힘듬.
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: const MarkerIcon(
              icon: Icon(
                Icons.personal_injury,
                color: Colors.black,
                size: 48,
              ),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(
                Icons.location_on,
                color: Colors.black,
                size: 48,
              ),
            ),
          ),
          roadConfiguration: const RoadOption(
            roadColor: Colors.blueGrey,
            roadWidth: 20,
          ),
          markerOption: MarkerOption(
              defaultMarker: const MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 56,
                ),
              )
          ),
        )
    );
  }
}