import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../big one/sales_report_page.dart';
import '../big one/ai_analysis_page.dart';
import '../logic/auth_service.dart';
import 'package:food_cost_calculator_3_0/big one/help_page.dart';
import 'package:food_cost_calculator_3_0/logic/user_riverpod.dart';
import 'package:food_cost_calculator_3_0/logic/upload_user_basic_data.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.maybeWhen(
      data: (user) => user != null, // User 객체가 null이 아니면 로그인한 것으로 간주
      orElse: () => false, // 그 외의 경우에는 로그인하지 않은 것으로 간주
    );
    AuthFunctions authFunctions = AuthFunctions();


    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white, width: 5)),
      ),
      child: Drawer(
        child: Container(
          color: Colors.deepPurpleAccent,
          child: Column(
            children: [
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
                        showDialog(
                          context: context,
                          //ButtonStyle(iconColor: Colors.deepPurpleAccent)
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.deepPurpleAccent,
                              title: const Text('회원 탈퇴'
                              ,style: TextStyle(color: Colors.white),),
                              content: const Text('정말로 회원 탈퇴를 진행하시겠습니까?',
                                style: TextStyle(color: Colors.white),),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('아니요'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 다이얼로그 닫기
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('네'),
                                  onPressed: () {
                                    // 회원 탈퇴 로직 진행
                                    authFunctions.deleteUser(ref);
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacementNamed(context, "/login");// 성공 시 다이얼로그 닫기
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(isLoggedIn == false ? Icons.login : Icons.logout, color: Colors.white),
                title: Text(
                  isLoggedIn == false
                      ? '회원가입/로그인'
                      : '로그아웃',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                ),
                onTap: ()  {
                  if (isLoggedIn == false) {
                    authFunctions.signInWithGoogle(ref);
                    UserDataUpload userDataUpload = UserDataUpload();
                    userDataUpload.addUserToFirestore();
                    UserDataUpload userDataUpload2 = UserDataUpload();
                    userDataUpload2.checkAndAddDefaultUserData();
                    Navigator.pushReplacementNamed(context, "/cost-input");
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








