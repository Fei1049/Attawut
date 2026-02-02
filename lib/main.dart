import 'package:flutter/material.dart';
// 1. Import ไฟล์หน้าหลักของเพื่อนแต่ละคน
import 'member1/member1_home.dart';
import 'member2/member2_home.dart';
import 'member3/member3_home.dart';

void main() => runApp(const TeamApp());

class TeamApp extends StatelessWidget {
  const TeamApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('รวมผลงาน Flutter ทีม A')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Member1Screen())),
              child: const Text('ผลงานของคนที่ 1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Member2Screen())),
              child: const Text('ผลงานของคนที่ 2'),
            ),
            // เพิ่มปุ่มของสมาชิกคนอื่นๆ ตามต้องการ
          ],
        ),
      ),
    );
  }
}
