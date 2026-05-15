import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'coach_clients_screen.dart';
import '../login/login_screen.dart';
import 'coach_profile_screen.dart';
import 'coach_messages_screen.dart';

class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  final Color bg = const Color(0xFF0B1220);
  final Color card = const Color(0xFF1D2638);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  //final String baseUrl = "http://127.0.0.1:8000/api";
  final String baseUrl = "http://10.0.2.2:8000/api";

  int activeClientsCount = 0;
  int forfaitsCount = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    final prefs = await SharedPreferences.getInstance();
    final coachId = prefs.getInt("user_id");

    if (coachId == null) return;

    try {
      final clientsRes = await http.get(
        Uri.parse("$baseUrl/coach/clients/$coachId/"),
      );

      final plansRes = await http.get(
        Uri.parse("$baseUrl/plans/?coach=$coachId"),
      );

      if (clientsRes.statusCode == 200) {
        activeClientsCount = jsonDecode(clientsRes.body).length;
      }

      if (plansRes.statusCode == 200) {
        forfaitsCount = jsonDecode(plansRes.body).length;
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Erreur dashboard stats: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: card,
        title: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Tu veux vraiment te déconnecter ?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: TextStyle(color: muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            child: Text("Déconnexion", style: TextStyle(color: green)),
          ),
        ],
      ),
    );
  }

  void openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CoachProfileScreen(showOnly: "profile"),
      ),
    ).then((_) => loadDashboardStats());
  }

  void openForfaits(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CoachProfileScreen(showOnly: "forfaits"),
      ),
    ).then((_) => loadDashboardStats());
  }

  void openMessages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CoachMessagesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: bottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(context),
              const SizedBox(height: 24),
              statsGrid(),
              const SizedBox(height: 22),
              actionCard(context),
              const SizedBox(height: 22),
              quickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 23,
          backgroundColor: const Color(0xFF123C3B),
          child: Icon(Icons.sports_martial_arts, color: green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            "Dashboard Coach",
            style: TextStyle(
              color: green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          tooltip: "Déconnexion",
          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
          onPressed: () => confirmLogout(context),
        ),
      ],
    );
  }

  Widget statsGrid() {
    return Column(
      children: [
        statCard(
          icon: Icons.payments_outlined,
          title: "TOTAL EARNINGS",
          value: "0 DT",
          badge: "+0%",
        ),
        const SizedBox(height: 16),
        statCard(
          icon: Icons.groups_2_outlined,
          title: "ACTIVE CLIENTS",
          value: activeClientsCount.toString(),
          badge: "New",
        ),
        const SizedBox(height: 16),
        statCard(
          icon: Icons.fitness_center,
          title: "MY FORFAITS",
          value: forfaitsCount.toString(),
          badge: "Ready",
        ),
      ],
    );
  }

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    required String badge,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconBox(icon),
              const Spacer(),
              badgeBox(badge),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(color: muted, fontSize: 12, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA46F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_turned_in, color: Colors.white, size: 30),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ACTION REQUIRED",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Complète ton profil coach",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Ajoute spécialité, expérience et forfaits.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => openProfile(context),
          ),
        ],
      ),
    );
  }

  Widget quickActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rowTitle(Icons.flash_on, "Quick Actions"),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              quickItem(Icons.account_circle, "Profile", () {
                openProfile(context);
              }),
              quickItem(Icons.fitness_center, "Forfaits", () {
                openForfaits(context);
              }),
              quickItem(Icons.message, "Messages", () {
                openMessages(context);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget quickItem(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: green, size: 30),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomNav(BuildContext context) {
    return Container(
      height: 76,
      color: const Color(0xFF111A2B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(Icons.dashboard, "Dashboard", true, () {}),
          navItem(Icons.people, "Clients", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CoachClientsScreen(),
              ),
            ).then((_) => loadDashboardStats());
          }),
          navItem(Icons.fitness_center, "Forfaits", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CoachProfileScreen(showOnly: "forfaits"),
              ),
            ).then((_) => loadDashboardStats());
          }),
          navItem(Icons.account_circle, "Profile", false, () {
            openProfile(context);
          }),
          navItem(Icons.message, "Message", false, () {
            openMessages(context);
          }),
          navItem(Icons.logout, "Logout", false, () {
            confirmLogout(context);
          }),
        ],
      ),
    );
  }

  Widget navItem(
      IconData icon,
      String text,
      bool active,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? green : muted, size: 21),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: active ? green : muted,
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget rowTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: green, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget iconBox(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF123C3B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: green),
    );
  }

  Widget badgeBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF123C3B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: green, fontSize: 12)),
    );
  }

  BoxDecoration box() {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(16),
    );
  }
}