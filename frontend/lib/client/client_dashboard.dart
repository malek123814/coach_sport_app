import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'training_screen.dart';
import 'my_coaches_screen.dart';
import '../login/login_screen.dart';
import 'plan_detail_screen.dart';
import 'client_messages_screen.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color card2 = const Color(0xFF172236);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

 // final String baseUrl = "http://127.0.0.1:8000";
  final String baseUrl = "http://10.0.2.2:8000";

  final searchController = TextEditingController();
  String searchText = "";

  bool loading = true;
  bool showAll = false;
  String? selectedCategory;
  List plans = [];

  List get filteredPlans {
    if (searchText.trim().isEmpty) return plans;

    return plans.where((plan) {
      final title = plan["title"]?.toString().toLowerCase() ?? "";
      return title.contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  Future<void> loadPlans() async {
    try {
      setState(() => loading = true);

      String url = "$baseUrl/api/plans/";

      if (selectedCategory != null) {
        url = "$baseUrl/api/plans/?category=$selectedCategory";
      }

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        setState(() {
          plans = jsonDecode(res.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur backend: $e")),
      );
    }
  }

  String imageUrl(dynamic plan) {
    final url = plan["coach_photo_url"];
    if (url == null || url.toString().isEmpty) return "";

    if (url.toString().startsWith("http")) {
      return url.toString().replaceAll("http://10.0.2.2:8000", baseUrl);
    }

    return "$baseUrl$url";
  }

  String coachName(dynamic plan) {
    return plan["coach_name"]?.toString() ?? "Coach";
  }

  String speciality(dynamic plan) {
    return plan["coach_speciality"]?.toString() ?? "Coach sportif";
  }

  @override
  Widget build(BuildContext context) {
    final visiblePlans = filteredPlans;

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: bottomNav(),
      body: SafeArea(
        child: loading
            ? Center(child: CircularProgressIndicator(color: green))
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topBar(),
              const SizedBox(height: 28),
              searchBar(),
              const SizedBox(height: 34),
              categories(),
              const SizedBox(height: 34),
              recommendedHeader(),
              const SizedBox(height: 18),
              visiblePlans.isEmpty ? emptyBox() : recommendedCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget topBar() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          "Elite Performance",
          style: TextStyle(
            color: green,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: "Déconnexion",
          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
          onPressed: () => confirmLogout(context),
        ),
      ],
    );
  }

  Widget searchBar() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: muted),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  showAll = true;
                });
              },
              decoration: InputDecoration(
                hintText: "Chercher un forfait...",
                hintStyle: TextStyle(color: muted, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchText.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clear();
                setState(() {
                  searchText = "";
                  showAll = false;
                });
              },
              icon: Icon(Icons.close, color: green),
            )
          else
            Icon(Icons.tune, color: green),
        ],
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

  Widget categoryItem(IconData icon, String text, String categoryValue) {
    final bool active = selectedCategory == categoryValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = active ? null : categoryValue;
          showAll = false;
          searchController.clear();
          searchText = "";
        });

        loadPlans();
      },
      child: categoryBox(icon, text, active),
    );
  }

  Widget allCategoryItem() {
    final bool active = selectedCategory == null;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = null;
          showAll = false;
          searchController.clear();
          searchText = "";
        });

        loadPlans();
      },
      child: categoryBox(Icons.grid_view, "TOUT", active),
    );
  }

  Widget categoryBox(IconData icon, String text, bool active) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            overflow: TextOverflow.ellipsis,
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

  Widget recommendedHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedCategory == null
                    ? "Tous les forfaits"
                    : "Forfaits $selectedCategory",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Clique sur un forfait pour voir les détails",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              showAll = !showAll;
            });
          },
          child: Row(
            children: [
              Text(
                showAll ? "SHOW\nLESS" : "VIEW\nALL",
                style: TextStyle(
                  color: green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                showAll ? Icons.keyboard_arrow_up : Icons.chevron_right,
                color: green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget recommendedCards() {
    final list = filteredPlans;
    final showPlans = showAll ? list : list.take(4).toList();

    return ListView.builder(
      itemCount: showPlans.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return bigPlanCard(showPlans[index]);
      },
    );
  }

  Widget bigPlanCard(dynamic plan) {
    final img = imageUrl(plan);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlanDetailScreen(plan: plan),
          ),
        );
      },
      child: Container(
        height: 285,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          image: img.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(img),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.05),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          child: Column(
            children: [
              if (img.isEmpty)
                Expanded(
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.25),
                      size: 90,
                    ),
                  ),
                )
              else
                const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: green, size: 18),
                            const SizedBox(width: 4),
                            const Text(
                              "4.9 (124 reviews)",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plan["title"]?.toString() ?? "Forfait",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coachName(plan),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          speciality(plan),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 82,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF33405A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "PRIX",
                          style: TextStyle(color: Colors.white60, fontSize: 9),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${plan["price"]} DT",
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomNav() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF101A2B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(Icons.dashboard, "Dashboard", true),
          navItem(Icons.sports_martial_arts, "Mes Coachs", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyCoachesScreen(),
              ),
            );
          }),
          navItem(Icons.fitness_center, "Training", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TrainingScreen(),
              ),
            );
          }),
          navItem(Icons.message, "Messages", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ClientMessagesScreen(),
              ),
            );
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
      bool active, [
        VoidCallback? onTap,
      ]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF123C3B) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? green : muted, size: 20),
            const SizedBox(height: 3),
            Text(
              text,
              style: TextStyle(
                color: active ? green : muted,
                fontSize: 9,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
        searchText.isNotEmpty
            ? "Aucun forfait trouvé avec ce nom."
            : selectedCategory == null
            ? "Aucun forfait disponible pour le moment."
            : "Aucun forfait dans cette spécialité.",
        style: TextStyle(color: muted),
      ),
    );
  }
}