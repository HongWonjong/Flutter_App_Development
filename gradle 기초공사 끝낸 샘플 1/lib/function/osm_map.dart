import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter/material.dart';
import 'package:freedomcompass/page/main_page.dart';

class Map_Widget extends StatefulWidget {


  Map_Widget({super.key});

  @override
  State<Map_Widget> createState() => _Map_WidgetState();
}

class _Map_WidgetState extends State<Map_Widget> {
// init the position using the user location
final controller = MapController.withUserPosition(
    trackUserLocation: const UserTrackingOption(
      enableTracking: true,
      unFollowUser: false,
    )
);

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(useMaterial3: true),
    initialRoute: "/home",
    routes: {
      "/home": (context) => MainPage(),
      "/old-home": (context) => MainPage(),
      "/hook": (context) => MainPage(),
      //"/adv-home": (ctx) => AdvandedMainExample(),
      // "/nav": (ctx) => MyHomeNavigationPage(
      //       map: Container(),
      // ),
      "/second": (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/old-home");
            },
            child: Text("another page"),
          ),
        ),
      ),
      "/picker-result": (context) => MainPage(),
      "/search": (context) => MainPage(),
    },
  );
}
}