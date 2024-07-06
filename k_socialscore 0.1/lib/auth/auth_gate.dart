import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:k_socialscore/homepage/quiz_list_page.dart';
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return LoginPage();
        } else {
          return const QuizListPage();
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, trace) => Center(child: Text(e.toString())),
    );
  }
}

