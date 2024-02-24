import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../big one/sales_report_page.dart';
import '../big one/ai_analysis_page.dart';
import '../logic/auth_service.dart';
import 'package:food_cost_calculator_3_0/big one/help_page.dart';
import 'package:food_cost_calculator_3_0/logic/user_riverpod.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.maybeWhen(
      data: (user) => user != null, // User 객체가 null이 아니면 로그인한 것으로 간주
      orElse: () => false, // 그 외의 경우에는 로그인하지 않은 것으로 간주
    );
    final currentEmail = ref.watch(userEmailProvider).value;
    final currentDisplayName = ref.watch(userDisplayNameProvider).value;
    AuthFunctions authFunctions = AuthFunctions();

    String formatEmail(String? email) {
      if (email != null && email.length > 8) {
        return '${email.substring(0, 8)}...';
      } else {
        return email ?? "No Email";
      }
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white, width: 5)),
      ),
      child: Drawer(
        child: Container(
          color: Colors.deepPurpleAccent,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.deepPurpleAccent,
                ),
                accountName: Text(currentDisplayName ?? "?",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                accountEmail: Text(formatEmail(currentEmail).toString(),
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(currentDisplayName?.substring(0, 1).toUpperCase() ?? '?',
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
                        'AI 분석 내역',
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
                        '도움말',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.unsubscribe, color: Colors.white),
                      title: const Text(
                        '회원탈퇴',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      onTap: () {
                        // Call the handleUnsubscribe method here
                        authFunctions.deleteUser(ref);
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(isLoggedIn == false ? Icons.login : Icons.logout, color: Colors.white),
                title: Text(
                  isLoggedIn == false
                      ? '로그인'
                      : '로그아웃',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                ),
                onTap: ()  {
                  if (isLoggedIn == false) {
                    authFunctions.signInWithGoogle(ref);
                  } else {
                    // 로그인되어 있는 경우, 로그아웃 수행
                    authFunctions.signOut(ref);
                    Navigator.pushReplacementNamed(context, "/login");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}








