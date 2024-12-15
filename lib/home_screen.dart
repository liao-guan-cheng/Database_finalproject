import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'team_submission_screen.dart';
import 'judge_screen.dart';
import 'announcement_screen.dart';
import 'teacher_screen.dart';

class HomeScreen extends StatelessWidget {
  final connSettings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'test',
    password: 'stu123456789',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('創意競賽管理系統')),
      body: Column(
        children: [
          // 上半部包含兩個按鈕
          Expanded(
            child: Row(
              children: [
                _buildExpandedButton(
                  context,
                  '報名與作品提交',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeamSubmissionScreen(connSettings)),
                  ),
                  Colors.blue, // 設定顏色
                ),
                _buildExpandedButton(
                  context,
                  '評審與評分',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JudgeScreen(connSettings)),
                  ),
                  Colors.green, // 設定顏色
                ),
              ],
            ),
          ),
          // 下半部包含兩個按鈕
          Expanded(
            child: Row(
              children: [
                _buildExpandedButton(
                  context,
                  '公告管理',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnnouncementScreen(connSettings)),
                  ),
                  Colors.orange, // 設定顏色
                ),
                _buildExpandedButton(
                  context,
                  '教師管理',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherScreen(connSettings)),
                  ),
                  Colors.red, // 設定顏色
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 優化的按鈕建構函式，讓按鈕填滿空間並設定顏色
  Widget _buildExpandedButton(BuildContext context, String label, VoidCallback onPressed, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8.0), // 按鈕間距
        decoration: BoxDecoration(
          color: color, // 設定按鈕顏色
          borderRadius: BorderRadius.circular(12.0), // 可選：設置圓角
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(16.0), // 按鈕內部間距
            textStyle: TextStyle(fontSize: 16), // 字體大小
            backgroundColor: Colors.transparent, // 設置按鈕背景透明，使用 Container 的背景顏色
            foregroundColor: Colors.white, // 設置文字顏色
          ),
          onPressed: onPressed,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
