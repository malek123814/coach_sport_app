import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePlanScreen extends StatefulWidget {
  final dynamic plan;

  const CreatePlanScreen({
    super.key,
    this.plan,
  });

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  final sessionsController = TextEditingController();
  final descriptionController = TextEditingController();
  final benefitsController = TextEditingController();

  //final String baseUrl = "http://127.0.0.1:8000";

  final String baseUrl = "http://10.0.2.2:8000";

  bool loading = false;
  int? coachId;
  String selectedLevel = "basic";

  final ImagePicker picker = ImagePicker();
  List<XFile> selectedImages = [];
  List existingImages = [];

  final Color bg = const Color(0xFF0B1220);
  final Color card = const Color(0xFF1D2638);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  bool get isEdit => widget.plan != null;

  @override
  void initState() {
    super.initState();
    loadCoachId();
    fillDataIfEdit();
  }

  Future<void> loadCoachId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coachId = prefs.getInt("user_id");
    });
  }

  void fillDataIfEdit() {
    if (!isEdit) return;

    titleController.text = widget.plan["title"]?.toString() ?? "";
    selectedLevel = widget.plan["level"]?.toString() ?? "basic";
    priceController.text = widget.plan["price"]?.toString() ?? "";
    durationController.text = widget.plan["duration"]?.toString() ?? "";
    sessionsController.text = widget.plan["sessions_count"]?.toString() ?? "";
    descriptionController.text = widget.plan["description"]?.toString() ?? "";
    benefitsController.text = widget.plan["benefits"]?.toString() ?? "";
    existingImages = List.from(widget.plan["images"] ?? []);
  }

  Future<void> pickPlanImages() async {
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages = images;
      });
    }
  }

  Future<void> savePlan() async {
    if (coachId == null) {
      showMsg("Coach non connecté");
      return;
    }

    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        durationController.text.isEmpty ||
        sessionsController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      showMsg("Remplis tous les champs obligatoires");
      return;
    }

    setState(() => loading = true);

    final request = http.MultipartRequest(
      isEdit ? "PUT" : "POST",
      Uri.parse(
        isEdit
            ? "$baseUrl/api/plans/${widget.plan["id"]}/update/"
            : "$baseUrl/api/plans/create/",
      ),
    );

    request.fields["coach"] = coachId.toString();
    request.fields["title"] = titleController.text.trim();
    request.fields["level"] = selectedLevel;
    request.fields["price"] = priceController.text.trim();
    request.fields["duration"] = durationController.text.trim();
    request.fields["sessions_count"] = sessionsController.text.trim();
    request.fields["description"] = descriptionController.text.trim();
    request.fields["benefits"] = benefitsController.text.trim();

    if (isEdit) {
      final ids = existingImages.map((e) => e["id"]).toList();
      request.fields["remaining_images"] = jsonEncode(ids);
    }

    for (final image in selectedImages) {
      final bytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          "images",
          bytes,
          filename: image.name,
        ),
      );
    }

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        showMsg(isEdit ? "Forfait modifié ✅" : "Forfait créé ✅");

        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        showMsg("Erreur: $body");
      }
    } catch (e) {
      showMsg("Erreur connexion: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    durationController.dispose();
    sessionsController.dispose();
    descriptionController.dispose();
    benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(isEdit ? "Modifier le forfait" : "Ajouter un forfait"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(),
              const SizedBox(height: 24),

              input(
                controller: titleController,
                label: "Nom du forfait",
                hint: "Forfait Basic / Premium / Elite",
                icon: Icons.workspace_premium,
              ),

              levelDropdown(),

              input(
                controller: priceController,
                label: "Prix",
                hint: "100",
                icon: Icons.payments,
                keyboardType: TextInputType.number,
              ),

              input(
                controller: durationController,
                label: "Durée",
                hint: "1 mois / 3 mois",
                icon: Icons.calendar_month,
              ),

              input(
                controller: sessionsController,
                label: "Nombre de séances",
                hint: "8",
                icon: Icons.fitness_center,
                keyboardType: TextInputType.number,
              ),

              input(
                controller: descriptionController,
                label: "Description",
                hint: "Explique le contenu du forfait...",
                icon: Icons.description,
                maxLines: 4,
              ),

              input(
                controller: benefitsController,
                label: "Avantages inclus",
                hint: "Ex: Suivi, nutrition, bilan...",
                icon: Icons.check_circle,
                maxLines: 4,
              ),

              if (isEdit) existingImagesWidget(),

              const SizedBox(height: 16),

              imagePickerBox(),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : savePlan,
                  icon: loading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(
                    loading
                        ? "Chargement..."
                        : isEdit
                        ? "Modifier le forfait"
                        : "Créer le forfait",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF123C3B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(isEdit ? Icons.edit : Icons.local_offer, color: green),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Modifier offre coaching" : "Créer une offre coaching",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isEdit
                  ? "Modifie les informations du forfait."
                  : "Ajoute un forfait visible aux clients.",
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget existingImagesWidget() {
    if (existingImages.isEmpty) {
      return Text(
        "Aucune image actuelle",
        style: TextStyle(color: muted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Images actuelles",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: existingImages.length,
            itemBuilder: (context, index) {
              final img = existingImages[index];

              return Stack(
                children: [
                  Container(
                    width: 105,
                    height: 105,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111A2B),
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image: NetworkImage(img["image_url"]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 18,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          existingImages.removeAt(index);
                        });
                      },
                      child: const CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.redAccent,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget imagePickerBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: pickPlanImages,
            icon: Icon(Icons.photo_library, color: green),
            label: Text(
              selectedImages.isEmpty
                  ? isEdit
                  ? "Ajouter nouvelles images"
                  : "Ajouter des images du forfait"
                  : "${selectedImages.length} images sélectionnées",
              style: TextStyle(color: green, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget levelDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedLevel,
        dropdownColor: card,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.bar_chart, color: green),
          labelText: "Niveau du forfait",
          labelStyle: TextStyle(color: muted),
          filled: true,
          fillColor: const Color(0xFF111A2B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: const [
          DropdownMenuItem(value: "basic", child: Text("Basic")),
          DropdownMenuItem(value: "premium", child: Text("Premium")),
          DropdownMenuItem(value: "elite", child: Text("Elite")),
        ],
        onChanged: (value) {
          setState(() {
            selectedLevel = value!;
          });
        },
      ),
    );
  }

  Widget input({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: green),
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: muted),
          hintStyle: TextStyle(color: muted),
          filled: true,
          fillColor: const Color(0xFF111A2B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}