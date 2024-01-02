import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/bottom_bar.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/function/osm_map.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/sized_box.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/rriverpod/user_riverpod.dart';
import 'package:freedomcompass/rriverpod/map_controller_riverpod.dart';
import 'package:freedomcompass/style/icon.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     // final user = ref.watch(uidProvider); // uidProvider를 감시하고 user 변수에 저장
    final email = ref.watch(userEmailProvider).value;


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppBar(
        titleText: mainpage_lan.mainPageTitle,
      ),
      body: Container(
        color: AppColors.centerColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AdaptiveSizedBox(),
              SizedBox(
                width: screenWidth * 0.95,
                height: screenHeight * 0.8,
                child: MapWidget(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Material(
        child: CustomBottomBar(),
      ),
    );
  }
}


