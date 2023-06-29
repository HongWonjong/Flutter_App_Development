import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../big one/sales_report_page.dart';
import '../big one/ai_analysis_page.dart';
import '../logic/auth_service.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_cost_calculator_3_0/big one/help_page.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = Provider<AuthService>((ref) => AuthService(ref));
    User? currentUser = ref.watch(loggedInUserProvider.notifier).state;

    String formatEmail(String email) {
      if (email.length > 8) {
        return '${email.substring(0, 8)}...';
      } else {
        return email;
      }
    }

    return Drawer(
      child: Container(
        color: Colors.deepPurpleAccent,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
              ),
              accountName: Text(currentUser?.displayName ?? 'Guest',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              accountEmail: Text(currentUser?.email ?? 'Login',
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(currentUser?.displayName?.substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(fontSize: 40, color: Colors.deepPurpleAccent),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.white),
                    title: const Text(
                      '매출보고서',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SalesReportPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics, color: Colors.white),
                    title: const Text(
                      'AI 분석 내역(공사중...)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AIAnalysisPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.white),
                    title: const Text(
                      '도움말 & 사용방법',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(currentUser == null ? Icons.login : Icons.logout, color: Colors.white),
              title: Text(
                currentUser == null
                    ? '로그인'
                    : '로그아웃',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
              ),
              onTap: () async {
                if (currentUser == null) {
                  // 로그인되어 있지 않은 경우, Google 로그인 실행
                  UserCredential userCredential = await ref.read(authService).signInWithGoogle();
                  User? user = userCredential.user;
                  if (user != null && user.displayName != null) {
                    ref.read(loggedInUserProvider.notifier).state = user;
                  }
                } else {
                  // 로그인되어 있는 경우, 로그아웃 수행
                  await FirebaseAuth.instance.signOut();
                  ref.read(loggedInUserProvider.notifier).state = null;
                }
                // Drawer를 닫음
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}







