import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';

class PlanDetailScreen extends StatelessWidget {
  final dynamic plan;

  const PlanDetailScreen({
    super.key,
    required this.plan,
  });

  Future<void> openChat(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getInt("user_id");

    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          clientId: clientId,
          coachId: plan["coach"],
          currentUserId: clientId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF071020);
    const green = Color(0xFF16D99A);
    const muted = Color(0xFF8C98AD);

    final List images = plan["images"] ?? [];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Détails du forfait"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: bg,
        child: SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => openChat(context),
            icon: const Icon(Icons.chat),
            label: const Text(
              "Contacter le coach",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageCarousel(images),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: box(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan["title"]?.toString() ?? "Forfait",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Coach : ${plan["coach_name"] ?? "Coach"}",
                    style: const TextStyle(
                      color: green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan["coach_speciality"]?.toString() ?? "Coach sportif",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: box(),
              child: Row(
                children: [
                  Expanded(
                    child: miniInfo(
                      Icons.payments,
                      "Prix",
                      "${plan["price"]} DT",
                    ),
                  ),
                  Expanded(
                    child: miniInfo(
                      Icons.calendar_month,
                      "Durée",
                      "${plan["duration"]}",
                    ),
                  ),
                  Expanded(
                    child: miniInfo(
                      Icons.fitness_center,
                      "Séances",
                      "${plan["sessions_count"]}",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: box(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title("Description"),
                  const SizedBox(height: 12),
                  Text(
                    plan["description"]?.toString() ?? "Aucune description",
                    style: const TextStyle(
                      color: muted,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  title("Avantages inclus"),
                  const SizedBox(height: 12),
                  Text(
                    plan["benefits"]?.toString().isNotEmpty == true
                        ? plan["benefits"].toString()
                        : "Aucun avantage ajouté.",
                    style: const TextStyle(
                      color: muted,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageCarousel(List images) {
    if (images.isEmpty) {
      return Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF111B2E),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.white30,
            size: 70,
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imgUrl = images[index]["image_url"];

          return Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: DecorationImage(
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${index + 1}/${images.length}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget miniInfo(IconData icon, String label, String value) {
    const green = Color(0xFF16D99A);
    const muted = Color(0xFF8C98AD);

    return Column(
      children: [
        Icon(icon, color: green),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget title(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  BoxDecoration box() {
    return BoxDecoration(
      color: const Color(0xFF111B2E),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    );
  }
}