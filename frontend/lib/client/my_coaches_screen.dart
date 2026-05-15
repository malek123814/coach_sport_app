import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';

class MyCoachesScreen extends StatefulWidget {
  const MyCoachesScreen({super.key});

  @override
  State<MyCoachesScreen> createState() => _MyCoachesScreenState();
}

class _MyCoachesScreenState extends State<MyCoachesScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";
  //final String baseUrl = "http://127.0.0.1:8000/api";

  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color card2 = const Color(0xFF172236);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  bool loading = true;
  int? clientId;
  String? selectedCategory;
  List conversations = [];

  @override
  void initState() {
    super.initState();
    loadCoaches();
  }

  Future<void> loadCoaches() async {
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

  List get filteredConversations {
    if (selectedCategory == null) return conversations;

    return conversations.where((conv) {
      final speciality = conv["coach_speciality"]?.toString().toLowerCase() ?? "";
      return speciality == selectedCategory!.toLowerCase();
    }).toList();
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
    );
  }

  String imageUrl(dynamic conv) {
    final url = conv["coach_photo_url"];
    if (url == null || url.toString().isEmpty) return "";
    return url.toString().replaceAll("http://10.0.2.2:8000", "http://127.0.0.1:8000");
  }

  @override
  Widget build(BuildContext context) {
    final coaches = filteredConversations;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Mes Coachs"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: green))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            categories(),
            const SizedBox(height: 22),
            Text(
              selectedCategory == null
                  ? "Tous mes coachs"
                  : "Coachs $selectedCategory",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            coaches.isEmpty
                ? emptyBox()
                : Column(
              children: coaches.map((conv) {
                return coachCard(conv);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget categories() {
    return SizedBox(
      height: 95,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          allCategoryItem(),
          categoryItem(Icons.fitness_center, "FITNESS", "Fitness"),
          categoryItem(Icons.sports_gymnastics, "MUSCULATION", "Musculation"),
          categoryItem(Icons.sports_mma, "BOXE", "Boxe"),
          categoryItem(Icons.self_improvement, "YOGA", "Yoga"),
        ],
      ),
    );
  }

  Widget allCategoryItem() {
    final active = selectedCategory == null;

    return GestureDetector(
      onTap: () {
        setState(() => selectedCategory = null);
      },
      child: categoryBox(Icons.grid_view, "TOUT", active),
    );
  }

  Widget categoryItem(IconData icon, String text, String value) {
    final active = selectedCategory == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = active ? null : value;
        });
      },
      child: categoryBox(icon, text, active),
    );
  }

  Widget categoryBox(IconData icon, String text, bool active) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 18),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF0C3B39) : card2,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: active ? green : Colors.white70, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? green : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 65,
              color: green,
            ),
        ],
      ),
    );
  }

  Widget coachCard(dynamic conv) {
    final img = imageUrl(conv);

    return Container(
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
            radius: 28,
            backgroundColor: const Color(0xFF123C3B),
            backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
            child: img.isEmpty ? Icon(Icons.person, color: green) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv["coach_name"]?.toString() ?? "Coach ${conv["coach"]}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  conv["coach_speciality"]?.toString() ?? "Coach sportif",
                  style: TextStyle(color: muted),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => openChat(conv),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Message"),
          ),
        ],
      ),
    );
  }

  Widget emptyBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        selectedCategory == null
            ? "Tu n'as contacté aucun coach pour le moment."
            : "Aucun coach contacté dans cette catégorie.",
        style: TextStyle(color: muted),
      ),
    );
  }
}