import 'package:url_launcher/url_launcher.dart';

void launchXProfile() async {
  final Uri url = Uri.parse('https://x.com/woddykorros9699');
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}
