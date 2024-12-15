import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    runApp(CreativityContestApp());
  } catch (e) {
    debugPrint('應用程式啟動失敗: $e');
  }
}


class CreativityContestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '創意競賽管理系統',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
