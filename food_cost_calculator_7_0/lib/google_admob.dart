import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdManager {
  static const String adUnitId = '<ca-app-pub-2047502466332917~5139215141>';

  // Add a property to hold the BannerAd instance
  static late BannerAd myBanner;

  // Method to create a BannerAd
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
        onAdWillDismissScreen: (Ad ad) => print('Left application.'),
      ),
    );
  }

  // Method to load the BannerAd
  static void loadBanner() {
    myBanner = createBannerAd();
    myBanner.load();
  }

  static Widget getBannerWidget() {
    return Container(
      height: 50.0, // Set as per your requirement
      child: AdWidget(ad: myBanner),
    );
  }
}



