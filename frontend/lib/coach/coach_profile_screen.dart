import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_plan_screen.dart';

class CoachProfileScreen extends StatefulWidget {
  final String showOnly;

  const CoachProfileScreen({
    super.key,
    this.showOnly = "all",
  });

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  final nameController = TextEditingController();
  final experienceController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();

  String? selectedSpeciality;
  String? photoUrl;

  final List<String> sports = [
    "Fitness",
    "Musculation",
    "Boxe",
    "Yoga",
  ];

  bool loading = true;
  bool saved = false;
  int? userId;
  List plans = [];

  XFile? selectedImage;
  final ImagePicker picker = ImagePicker();

  final Color bg = const Color(0xFF0B1220);
  final Color card = const Color(0xFF1D2638);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

 // final String baseUrl = "http://127.0.0.1:8000";
  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  Future<void> initProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id");

    if (userId != null) {
      await loadProfile();
      await loadPlans();
    }

    setState(() => loading = false);
  }

  Future<void> loadProfile() async {
    try {
      final url = Uri.parse("$baseUrl/api/coach-profile/$userId/");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          nameController.text = data["name"] ?? "";
          selectedSpeciality = data["speciality"];
          experienceController.text = data["experience"] ?? "";
          locationController.text = data["location"] ?? "";
          bioController.text = data["bio"] ?? "";

          if (data["photo_url"] != null && data["photo_url"].toString().isNotEmpty) {
            photoUrl = data["photo_url"].toString().startsWith("http")
                ? data["photo_url"]
                : baseUrl + data["photo_url"];
          }

          saved = true;
        });
      } else {
        saved = false;
      }
    } catch (e) {
      saved = false;
    }
  }

  Future<void> loadPlans() async {
    if (userId == null) return;

    try {
      final url = Uri.parse("$baseUrl/api/plans/?coach=$userId");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        setState(() {
          plans = jsonDecode(res.body);
        });
      }
    } catch (e) {
      debugPrint("Erreur load plans: $e");
    }
  }

  Future<void> saveProfile() async {
    if (userId == null) {
      showMsg("User non connecté");
      return;
    }

    if (selectedSpeciality == null || selectedSpeciality!.isEmpty) {
      showMsg("Choisir une spécialité");
      return;
    }

    final url = Uri.parse("$baseUrl/api/coach-profile/save/");
    final request = http.MultipartRequest("POST", url);

    request.fields["user"] = userId.toString();
    request.fields["name"] = nameController.text.trim();
    request.fields["speciality"] = selectedSpeciality!;
    request.fields["experience"] = experienceController.text.trim();
    request.fields["location"] = locationController.text.trim();
    request.fields["bio"] = bioController.text.trim();

    if (selectedImage != null) {
      final bytes = await selectedImage!.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          "photo",
          bytes,
          filename: selectedImage!.name,
        ),
      );
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        selectedImage = null;

        await loadProfile();
        await loadPlans();

        setState(() => saved = true);

        showMsg("Profil sauvegardé ✅");
      } else {
        showMsg("Erreur upload: ${response.statusCode}");
      }
    } catch (e) {
      showMsg("Erreur: $e");
    }
  }

  Future<void> deletePlan(int id) async {
    final url = Uri.parse("$baseUrl/api/plans/$id/delete/");
    final res = await http.delete(url);

    if (res.statusCode == 200 || res.statusCode == 204) {
      await loadPlans();
      showMsg("Forfait supprimé ✅");
    } else {
      showMsg("Erreur suppression: ${res.body}");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void confirmDeletePlan(dynamic plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: card,
        title: const Text(
          "Supprimer forfait",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Tu veux supprimer ${plan["title"]} ?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: TextStyle(color: muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deletePlan(plan["id"]);
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: green),
                title: const Text(
                  "Choisir depuis la galerie",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: Icon(Icons.camera_alt, color: green),
                  title: const Text(
                    "Prendre une photo",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        selectedImage = image;
      });

      showMsg("Image sélectionnée ✅");
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    experienceController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: green)),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          widget.showOnly == "forfaits" ? "Mes Forfaits" : "Mon Profil",
        ),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: saved ? profileView() : profileForm(),
    );
  }

  Widget profileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          avatarIcon(),
          const SizedBox(height: 20),
          input(nameController, "Nom", Icons.person),
          dropdownSpeciality(),
          input(experienceController, "Expérience", Icons.work_outline),
          input(locationController, "Localisation", Icons.location_on),
          input(bioController, "Bio", Icons.description, maxLines: 4),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Enregistrer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (widget.showOnly == "profile") profileInfoSection(),
          if (widget.showOnly == "forfaits") forfaitsSection(),
          if (widget.showOnly == "all") ...[
            profileInfoSection(),
            const SizedBox(height: 20),
            forfaitsSection(),
          ],
        ],
      ),
    );
  }

  Widget profileInfoSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: box(),
          child: Column(
            children: [
              avatarIcon(),
              const SizedBox(height: 16),
              Text(
                nameController.text.isEmpty ? "Coach" : nameController.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                selectedSpeciality ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => saved = false);
                },
                icon: const Icon(Icons.edit),
                label: const Text("Modifier Profil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.black,
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
              title("Informations Coach"),
              const SizedBox(height: 18),
              info(Icons.fitness_center, "Spécialité", selectedSpeciality ?? ""),
              info(Icons.work_outline, "Expérience", experienceController.text),
              info(Icons.location_on, "Localisation", locationController.text),
              info(Icons.description, "Bio", bioController.text),
            ],
          ),
        ),
      ],
    );
  }

  Widget forfaitsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              title("Mes Forfaits"),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePlanScreen(),
                    ),
                  );
                  await loadPlans();
                },
                icon: const Icon(Icons.add),
                label: const Text("Ajouter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          plans.isEmpty
              ? Text("Aucun forfait ajouté", style: TextStyle(color: muted))
              : Column(
            children: plans.map((plan) {
              return forfaitCard(plan);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget forfaitCard(dynamic plan) {
    final List images = plan["images"] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF123C3B),
                child: Icon(Icons.workspace_premium, color: green, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  plan["title"].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF123C3B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${plan["price"]} DT",
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 🔥 IMAGES STYLE INSTAGRAM
          if (images.isNotEmpty)
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final img = images[index]["image_url"];

                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(img),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1D2638),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text("Aucune image", style: TextStyle(color: muted)),
              ),
            ),

          const SizedBox(height: 14),

          // 🔹 INFOS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip("${plan["level"] ?? "basic"}"),
              chip("${plan["duration"] ?? "Durée"}"),
              chip("${plan["sessions_count"] ?? 0} séances"),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            plan["description"]?.toString() ?? "",
            style: TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePlanScreen(plan: plan),
                      ),
                    );
                    await loadPlans();
                  },
                  icon: Icon(Icons.edit, color: green, size: 18),
                  label: Text("Modifier", style: TextStyle(color: green)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: green),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    confirmDeletePlan(plan);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  label: const Text(
                    "Supprimer",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2638),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: muted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget avatarIcon() {
    ImageProvider? imageProvider;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(photoUrl!);
    }

    return GestureDetector(
      onTap: showImageSourceDialog,
      child: CircleAvatar(
        radius: 55,
        backgroundColor: const Color(0xFF123C3B),
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Icon(Icons.camera_alt, color: green, size: 42)
            : null,
      ),
    );
  }

  Widget dropdownSpeciality() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: sports.contains(selectedSpeciality) ? selectedSpeciality : null,
        dropdownColor: card,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.fitness_center, color: green),
          labelText: "Spécialité",
          labelStyle: TextStyle(color: muted),
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        iconEnabledColor: green,
        items: sports.map((sport) {
          return DropdownMenuItem<String>(
            value: sport,
            child: Text(sport),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSpeciality = value;
          });
        },
      ),
    );
  }

  Widget input(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: green),
          labelText: label,
          labelStyle: TextStyle(color: muted),
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: green),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "Non renseigné" : value,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget title(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  BoxDecoration box() {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(18),
    );
  }
}