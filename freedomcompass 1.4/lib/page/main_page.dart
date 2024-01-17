import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/style/sized_box.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/rriverpod/user_riverpod.dart';
import 'package:freedomcompass/style/chat_input_box.dart';


class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     // final user = ref.watch(uidProvider); // uidProvider를 감시하고 user 변수에 저장
   // final email = ref.watch(userEmailProvider).value;


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppBar(
        titleText: mainpage_lan.mainPageTitle,
      ),
      body: Container(
        color: AppColors.centerColor,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AdaptiveSizedBox(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ChatInputWidget(),
    );
  }
}


