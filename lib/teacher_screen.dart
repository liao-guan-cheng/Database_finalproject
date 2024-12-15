import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class TeacherScreen extends StatefulWidget {
  final ConnectionSettings connSettings;

  TeacherScreen(this.connSettings);

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  late MySqlConnection connection;
  List<Map<String, dynamic>> teachers = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // 初始化資料庫連線
  Future<void> _initDatabase() async {
    connection = await MySqlConnection.connect(widget.connSettings);
    await _fetchTeachers();
  }

  // 從資料庫獲取教師資料
  Future<void> _fetchTeachers() async {
    var results = await connection.query('SELECT * FROM teachers');
    setState(() {
      teachers = results.map((row) {
        return {
          'id': row[0],
          'name': row[1],
          'subject': row[2],
        };
      }).toList();
    });
  }

  // 顯示教師清單
  Widget _buildTeacherList() {
    return ListView.builder(
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        var teacher = teachers[index];
        return ListTile(
          title: Text(teacher['name']),
          subtitle: Text('科目: ${teacher['subject']}'),
          onTap: () {
            // 點擊教師可以執行某些操作（如編輯教師資料）
            _showTeacherDetails(teacher['id']);
          },
        );
      },
    );
  }

  // 顯示教師詳細資料（範例）
  Future<void> _showTeacherDetails(int teacherId) async {
    var result = await connection.query('SELECT * FROM teachers WHERE id = ?', [teacherId]);
    var teacher = result.first;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('教師詳細資料'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('姓名: ${teacher[1]}'),
              Text('科目: ${teacher[2]}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  // 顯示新增教師的對話框
  void _showAddTeacherDialog() {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新增教師'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '教師姓名'),
              ),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: '科目'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 將資料插入資料庫
                _addTeacher(nameController.text, subjectController.text);
                Navigator.of(context).pop();
              },
              child: Text('新增'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
          ],
        );
      },
    );
  }

  // 新增教師到資料庫
  Future<void> _addTeacher(String name, String subject) async {
    await connection.query(
      'INSERT INTO teachers (name, subject) VALUES (?, ?)',
      [name, subject],
    );
    _fetchTeachers(); // 重新載入教師清單
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('教師管理'),
      ),
      body: teachers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _buildTeacherList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTeacherDialog,
        child: Icon(Icons.add),
        tooltip: '新增教師',
      ),
    );
  }
}
