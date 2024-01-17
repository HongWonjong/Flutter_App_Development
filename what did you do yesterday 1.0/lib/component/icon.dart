import 'package:flutter/material.dart';

class AdaptiveIcons {
  static Widget homeIcon({VoidCallback? onTap, Size? size}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.home,
        size: size != null ? 20 : 0.0,
      ),
    );
  }

  static Widget locationSearching({VoidCallback? onTap, Size? size}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.location_searching,
        size: size != null ? 20 : 0.0,
      ),
    );
  }

  static Widget searchIcon({VoidCallback? onTap, Size? size}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.search,
        size: size != null ? 20 : 0.0,
      ),
    );
  }

  static Widget favoriteIcon({VoidCallback? onTap, Size? size}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.favorite,
        size: size != null ? 20 : 0.0,
      ),
    );
  }

  static Widget notificationsIcon({VoidCallback? onTap, Size? size}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.notifications,
        size: size != null ? 20 : 0.0,
      ),
    );
  }

  static Widget settingsIcon({VoidCallback? onTap, Size? size}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.settings,
        size: size != null ? 20 : 0.0,
      ),
    );
  }
}



