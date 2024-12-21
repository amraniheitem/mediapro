import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> notifications = [
    {'title': 'Notification 1', 'isRead': false},
    {'title': 'Notification 2', 'isRead': false},
    {'title': 'Notification 3', 'isRead': false},
    {'title': 'Notification 4', 'isRead': false},
    {'title': 'Notification 5', 'isRead': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFB993D6),
                      Color(0xFF8CA6DB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Notifications',
                    style: GoogleFonts.lobster(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['isRead'];

                  return Card(
                    elevation: 3,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    color: isRead ? Colors.grey[200] : Colors.white,
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: isRead ? Colors.grey : Colors.blue,
                      ),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          color: isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(isRead ? 'Read' : 'Unread'),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: isRead ? Colors.grey : Colors.blue,
                      ),
                      onTap: () {
                        setState(() {
                          notifications[index]['isRead'] = true;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
