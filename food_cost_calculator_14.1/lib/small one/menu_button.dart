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
            Expanded(
              child: ListView(
                children: [
                  ListTile(
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
                    title: const Text(
                      'AI 분석(공사중...)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AIAnalysisPage()),
                      );
                    },
                  ),
                  ListTile(
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
              title: Text(
                currentUser == null
                    ? '로그인'
                    : '로그아웃 (${formatEmail(currentUser.email ?? '')})',
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






