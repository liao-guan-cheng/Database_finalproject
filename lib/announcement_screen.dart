import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class AnnouncementScreen extends StatefulWidget {
  final ConnectionSettings connSettings;

  AnnouncementScreen(this.connSettings);

  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late MySqlConnection connection;
  List<Map<String, dynamic>> announcements = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // 初始化資料庫連線
  Future<void> _initDatabase() async {
    connection = await MySqlConnection.connect(widget.connSettings);
    await _fetchAnnouncements();
  }

  // 從資料庫獲取公告資料
  Future<void> _fetchAnnouncements() async {
    var results = await connection.query('SELECT * FROM announcements ORDER BY created_at DESC');
    setState(() {
      announcements = results.map((row) {
        return {
          'id': row[0],
          'title': row[1],
          'content': row[2],
          'created_at': row[3],
          'updated_at': row[4],
        };
      }).toList();
    });
  }

  // 顯示公告清單
  Widget _buildAnnouncementList() {
    return ListView.builder(
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        var announcement = announcements[index];
        return ListTile(
          title: Text(announcement['title']),
          subtitle: Text('創建時間: ${announcement['created_at']}'),
          onTap: () {
            _showAnnouncementDetails(announcement['id']);
          },
        );
      },
    );
  }

  // 顯示公告詳細內容
  Future<void> _showAnnouncementDetails(int announcementId) async {
    var result = await connection.query('SELECT * FROM announcements WHERE id = ?', [announcementId]);
    var announcement = result.first;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(announcement[1]), // 顯示公告標題
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('內容: ${announcement[2]}'),  // 顯示公告內容
              SizedBox(height: 10),
              Text('創建時間: ${announcement[3]}'),
              Text('更新時間: ${announcement[4]}'),
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

  // 顯示新增公告的對話框
  void _showAddAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新增公告'),
          content: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '公告標題'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: '公告內容'),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 新增公告到資料庫
                _addAnnouncement(titleController.text, contentController.text);
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

  // 新增公告到資料庫
  Future<void> _addAnnouncement(String title, String content) async {
    await connection.query(
      'INSERT INTO announcements (title, content) VALUES (?, ?)',
      [title, content],
    );
    _fetchAnnouncements(); // 重新載入公告清單
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('公告管理'),
      ),
      body: announcements.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _buildAnnouncementList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAnnouncementDialog,
        child: Icon(Icons.add),
        tooltip: '新增公告',
      ),
    );
  }
}
