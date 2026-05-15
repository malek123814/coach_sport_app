import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final int clientId;
  final int coachId;
  final int currentUserId;

  const ChatScreen({
    super.key,
    required this.clientId,
    required this.coachId,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
 // final String baseUrl = "http://127.0.0.1:8000/api";
  final String baseUrl = "http://10.0.2.2:8000/api";
  final TextEditingController controller = TextEditingController();

  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  int? conversationId;
  List messages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initConversation();
  }

  Future<void> initConversation() async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/chat/create/"),
        body: {
          "client": widget.clientId.toString(),
          "coach": widget.coachId.toString(),
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        conversationId = data["id"];
        await loadMessages();
      } else {
        showMsg("Erreur création chat: ${res.body}");
      }
    } catch (e) {
      showMsg("Erreur connexion: $e");
    }

    setState(() => loading = false);
  }

  Future<void> loadMessages() async {
    if (conversationId == null) return;

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/chat/messages/$conversationId/"),
      );

      if (res.statusCode == 200) {
        setState(() {
          messages = jsonDecode(res.body);
        });
      }
    } catch (e) {
      showMsg("Erreur messages: $e");
    }
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty || conversationId == null) return;

    final text = controller.text.trim();
    controller.clear();

    try {
      await http.post(
        Uri.parse("$baseUrl/chat/send/"),
        body: {
          "conversation": conversationId.toString(),
          "sender": widget.currentUserId.toString(),
          "text": text,
        },
      );

      await loadMessages();
    } catch (e) {
      showMsg("Erreur envoi: $e");
    }
  }

  bool isMe(dynamic msg) {
    return msg["sender"].toString() == widget.currentUserId.toString();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Conversation"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: loadMessages,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: green))
          : Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Text(
                "Aucun message pour le moment",
                style: TextStyle(color: muted),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final mine = isMe(msg);

                return Align(
                  alignment: mine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width * 0.70,
                    ),
                    decoration: BoxDecoration(
                      color: mine ? green : card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: mine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg["text"] ?? "",
                          style: TextStyle(
                            color:
                            mine ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg["sender_name"] ?? "",
                          style: TextStyle(
                            color: mine
                                ? Colors.black54
                                : Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              border: const Border(
                top: BorderSide(color: Colors.white10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      hintStyle: TextStyle(color: muted),
                      filled: true,
                      fillColor: bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: green,
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}