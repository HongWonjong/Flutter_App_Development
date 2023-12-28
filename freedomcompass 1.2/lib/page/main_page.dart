import 'package:flutter/material.dart';
import 'package:freedomcompass/style/bottom_bar.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/function/osm_map.dart';


class MainPage extends StatelessWidget {
  const MainPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 사용자 정의된 CustomAppBar로 교체
      appBar: CustomAppBar(),
      body:  Center(
        child: Map_Widget(),
      ),
      bottomNavigationBar: const Material(
        child: CustomBottomBar(),
      ),
    );
  }
}
