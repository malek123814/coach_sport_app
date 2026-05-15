import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';

class ClientMessagesScreen extends StatefulWidget {
  const ClientMessagesScreen({super.key});

  @override
  State<ClientMessagesScreen> createState() => _ClientMessagesScreenState();
}

class _ClientMessagesScreenState extends State<ClientMessagesScreen> {
  //final String baseUrl = "http://127.0.0.1:8000/api";
  final String baseUrl = "http://10.0.2.2:8000/api";

  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  bool loading = true;
  int? clientId;
  List conversations = [];

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    clientId = prefs.getInt("user_id");

    if (clientId == null) {
      setState(() => loading = false);
      return;
    }

    final res = await http.get(
      Uri.parse("$baseUrl/chat/client/$clientId/"),
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
    return messages.last["text"]?.toString() ?? "";
  }

  void openChat(dynamic conv) {
    if (clientId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          clientId: conv["client"],
          coachId: conv["coach"],
          currentUserId: clientId!,
        ),
      ),
    ).then((_) => loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Mes conversations"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: loadConversations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: green))
          : conversations.isEmpty
          ? Center(
        child: Text(
          "Aucune conversation",
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
                    radius: 26,
                    backgroundColor: const Color(0xFF123C3B),
                    child: Icon(Icons.sports_martial_arts, color: green),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Coach ${conv["coach"]}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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