import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entrypoint/main.dart';
import 'menu_button.dart';

class MyAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MyAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30.0,
        ),
      ),
      leading: Builder(
        builder: (BuildContext context) {
      return CustomMenu();
    },
    ),


    backgroundColor: Colors.deepPurpleAccent,
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          iconSize: 40,
          onSelected: (String value) async {
            ref.read(languageProvider.notifier).switchToLanguage(value);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('preferredLanguage', value);
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: null,
                child: SizedBox(
                  width: 170,
                  height: 400,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: ScrollController(),
                    thickness: 8.0,
                    child: ListView.builder(
                      itemCount: languages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final language = languages[index];
                        return PopupMenuItem<String>(
                          value: language['value'],
                          child: Text(language['name']!),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
        ),
      ],
      automaticallyImplyLeading: true, // 뒤로가기 버튼 자동 표시
    );
  }
}

final languages = <Map<String, String>>[
  {'value': 'en', 'name': 'English'},
  {'value': 'ko', 'name': 'Korean'},
  {'value': 'zh', 'name': 'Mandarin'},
  {'value': 'es', 'name': 'Spanish'},
  {'value': 'ja', 'name': 'Japanese'},
  {'value': 'ru', 'name': 'Russian'},
  {'value': 'pt', 'name': 'Portuguese'},
  {'value': 'de', 'name': 'German'},
  {'value': 'ar', 'name': 'Arabic'},
  {'value': 'hi', 'name': 'Hindi'},
  {'value': 'bn', 'name': 'Bengali'},
  {'value': 'fr', 'name': 'French'},
  {'value': 'it', 'name': 'Italian'},
  {'value': 'nl', 'name': 'Dutch'},
];

