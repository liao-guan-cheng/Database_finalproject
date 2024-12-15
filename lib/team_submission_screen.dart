import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class TeamSubmissionScreen extends StatefulWidget {
  final ConnectionSettings connSettings;

  TeamSubmissionScreen(this.connSettings);

  @override
  _TeamSubmissionScreenState createState() => _TeamSubmissionScreenState();
}

class _TeamSubmissionScreenState extends State<TeamSubmissionScreen> {
  final _teamNameController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _advisorController = TextEditingController();
  final _submissionDateController = TextEditingController();

  Future<void> _submitData() async {
    try {
      final conn = await MySqlConnection.connect(widget.connSettings);
      await conn.query(
        'INSERT INTO teams (team_name, member_name, advisor, submission_date) VALUES (?, ?, ?, ?)',
        [
          _teamNameController.text,
          _memberNameController.text,
          _advisorController.text,
          _submissionDateController.text,
        ],
      );
      await conn.close();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('報名資料已提交')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失敗: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('報名與作品提交')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(labelText: '隊伍名稱'),
            ),
            TextField(
              controller: _memberNameController,
              decoration: InputDecoration(labelText: '成員名稱'),
            ),
            TextField(
              controller: _advisorController,
              decoration: InputDecoration(labelText: '指導老師'),
            ),
            TextField(
              controller: _submissionDateController,
              decoration: InputDecoration(labelText: '報名日期'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}