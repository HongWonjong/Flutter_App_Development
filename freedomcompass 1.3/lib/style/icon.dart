import 'package:flutter/material.dart';

class AdaptiveIcons {
  static Widget homeIcon({VoidCallback? onTap, BuildContext? context}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.home,
        size: context != null ? MediaQuery.of(context).size.height * 0.07 : 0.0,
      ),
    );
  }

  static Widget searchIcon({VoidCallback? onTap, BuildContext? context}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.search,
        size: context != null ? MediaQuery.of(context).size.height * 0.07 : 0.0,
      ),
    );
  }

  static Widget favoriteIcon({VoidCallback? onTap, BuildContext? context}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.favorite,
        size: context != null ? MediaQuery.of(context).size.height * 0.07 : 0.0,
      ),
    );
  }

  static Widget notificationsIcon({VoidCallback? onTap, BuildContext? context}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.notifications,
        size: context != null ? MediaQuery.of(context).size.height * 0.07 : 0.0,
      ),
    );
  }

  static Widget settingsIcon({VoidCallback? onTap, BuildContext? context}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.settings,
        size: context != null ? MediaQuery.of(context).size.height * 0.07 : 0.0,
      ),
    );
  }
}


