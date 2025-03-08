import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/memo_list_page.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';

// 데이터베이스 서비스 프로바이더
final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: '메모 앱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MemoListPage(),
    );
  }
}
