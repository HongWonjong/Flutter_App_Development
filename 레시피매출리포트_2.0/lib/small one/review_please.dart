import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void checkAndShowRatingDialog(BuildContext context, Function incrementLaunchCount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int launchCount = prefs.getInt('launchCount') ?? 0;
  if (launchCount != 0 && launchCount % 200 == 0) {
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.dialogTitle),
          content: Text(AppLocalizations.of(context)!.dialogContent),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.giveStar),
              onPressed: () {
                // TODO: Implement your function
                Navigator.of(context).pop();
                incrementLaunchCount();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.notNow),
              onPressed: () {
                incrementLaunchCount();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } else {
    incrementLaunchCount();
  }
}
