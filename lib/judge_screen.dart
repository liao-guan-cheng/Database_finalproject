import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class JudgeScreen extends StatefulWidget {
  final ConnectionSettings connSettings;

  JudgeScreen(this.connSettings);

  @override
  _JudgeScreenState createState() => _JudgeScreenState();
}

class _JudgeScreenState extends State<JudgeScreen> {
  late MySqlConnection connection;
  List<Map<String, dynamic>> judges = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // 初始化資料庫連接
  Future<void> _initDatabase() async {
    connection = await MySqlConnection.connect(widget.connSettings);
    await _fetchJudges();
  }

  // 從資料庫獲取評審資料
  Future<void> _fetchJudges() async {
    var results = await connection.query('SELECT * FROM judges ORDER BY name');
    setState(() {
      judges = results.map((row) {
        return {
          'id': row[0],
          'name': row[1],
          'email': row[2],
          'assigned_event': row[3],
          'score': row[4],
        };
      }).toList();
    });
  }

  // 顯示評審清單
  Widget _buildJudgeList() {
    return ListView.builder(
      itemCount: judges.length,
      itemBuilder: (context, index) {
        var judge = judges[index];
        return ListTile(
          title: Text(judge['name']),
          subtitle: Text('活動: ${judge['assigned_event']} - 分數: ${judge['score'] ?? "尚未評分"}'),
          onTap: () {
            _showJudgeDetails(judge['id']);
          },
        );
      },
    );
  }

  // 顯示評審詳細資料
  Future<void> _showJudgeDetails(int judgeId) async {
    var result = await connection.query('SELECT * FROM judges WHERE id = ?', [judgeId]);
    var judge = result.first;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(judge[1]),  // 顯示評審名稱
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('電子郵件: ${judge[2]}'),
              Text('指派活動: ${judge[3]}'),
              Text('分數: ${judge[4] ?? "尚未評分"}'),
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

  // 顯示新增評審的對話框
  void _showAddJudgeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final assignedEventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新增評審'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '評審姓名'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: '評審電子郵件'),
              ),
              TextField(
                controller: assignedEventController,
                decoration: InputDecoration(labelText: '指派活動'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 新增評審到資料庫
                _addJudge(
                  nameController.text,
                  emailController.text,
                  assignedEventController.text,
                );
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

  // 新增評審到資料庫
  Future<void> _addJudge(String name, String email, String assignedEvent) async {
    await connection.query(
      'INSERT INTO judges (name, email, assigned_event) VALUES (?, ?, ?)',
      [name, email, assignedEvent],
    );
    _fetchJudges(); // 重新載入評審清單
  }

  // 顯示評分的對話框
  void _showScoreDialog(int judgeId, String assignedEvent) {
    final scoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('為活動 "$assignedEvent" 評分'),
          content: Column(
            children: [
              TextField(
                controller: scoreController,
                decoration: InputDecoration(labelText: '評分 (0-10)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 更新評分到資料庫
                _submitScore(judgeId, scoreController.text);
                Navigator.of(context).pop();
              },
              child: Text('提交'),
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

  // 提交評分到資料庫
  Future<void> _submitScore(int judgeId, String score) async {
    await connection.query(
      'UPDATE judges SET score = ? WHERE id = ?',
      [score, judgeId],
    );
    _fetchJudges(); // 重新載入評審清單
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('評審與評分'),
      ),
      body: judges.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _buildJudgeList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddJudgeDialog,
        child: Icon(Icons.add),
        tooltip: '新增評審',
      ),
    );
  }
}
