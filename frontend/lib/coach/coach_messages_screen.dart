import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../client/chat_screen.dart';

class CoachMessagesScreen extends StatefulWidget {
  const CoachMessagesScreen({super.key});

  @override
  State<CoachMessagesScreen> createState() => _CoachMessagesScreenState();
}

class _CoachMessagesScreenState extends State<CoachMessagesScreen> {
 // final String baseUrl = "http://127.0.0.1:8000/api";
  final String baseUrl = "http://10.0.2.2:8000/api";

  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  bool loading = true;
  int? coachId;
  List conversations = [];

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    coachId = prefs.getInt("user_id");

    if (coachId == null) {
      setState(() => loading = false);
      return;
    }

    final res = await http.get(
      Uri.parse("$baseUrl/chat/coach/$coachId/"),
    );

    if (res.statusCode == 200) {
      setState(() {
        conversations = jsonDecode(res.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  String lastMessage(dynamic conv) {
    final messages = conv["messages"] ?? [];
    if (messages.isEmpty) return "Aucun message";
    return messages.last["text"] ?? "";
  }

  String clientName(dynamic conv) {
    return "Client ${conv["client"]}";
  }

  void openChat(dynamic conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          clientId: conv["client"],
          coachId: conv["coach"],
          currentUserId: coachId!,
        ),
      ),
    ).then((_) => loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: green))
          : conversations.isEmpty
          ? Center(
        child: Text(
          "Aucun message reçu",
          style: TextStyle(color: muted),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conv = conversations[index];

          return GestureDetector(
            onTap: () => openChat(conv),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF123C3B),
                    child: Icon(Icons.person, color: green),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName(conv),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          lastMessage(conv),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}