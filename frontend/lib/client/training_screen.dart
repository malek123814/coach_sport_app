import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";
  //final String baseUrl = "http://127.0.0.1:8000/api";

  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  bool loading = true;
  int? clientId;
  List logs = [];

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    clientId = prefs.getInt("user_id");

    if (clientId == null) {
      setState(() => loading = false);
      return;
    }

    final res = await http.get(Uri.parse("$baseUrl/training/client/$clientId/"));

    if (res.statusCode == 200) {
      setState(() {
        logs = jsonDecode(res.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> deleteLog(int id) async {
    await http.delete(Uri.parse("$baseUrl/training/$id/delete/"));
    await loadLogs();
  }

  void openAddForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTrainingLogScreen(clientId: clientId!),
      ),
    ).then((_) => loadLogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Training Journal"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: openAddForm,
            icon: Icon(Icons.add_circle, color: green),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: green))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerCard(),
            const SizedBox(height: 22),
            const Text(
              "Historique / Agenda",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            logs.isEmpty ? emptyBox() : logsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddForm,
        backgroundColor: green,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text("Ajouter séance"),
      ),
    );
  }

  Widget headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book, color: green, size: 34),
          const SizedBox(height: 12),
          const Text(
            "Ton carnet personnel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ajoute tes exercices, poids, taille, objectif et notes chaque jour.",
            style: TextStyle(color: muted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget logsList() {
    return Column(
      children: logs.map((log) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${log["date"]}  •  ${log["time"]}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => deleteLog(log["id"]),
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              info("Poids", "${log["weight"] ?? "-"} kg"),
              info("Taille", "${log["height"] ?? "-"} cm"),
              info("Objectif", log["goal"]?.toString() ?? "-"),
              const SizedBox(height: 10),
              Text("Exercices", style: TextStyle(color: green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                log["exercises"]?.toString() ?? "",
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
              if ((log["notes"] ?? "").toString().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text("Notes", style: TextStyle(color: green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  log["notes"].toString(),
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text("$label : ", style: TextStyle(color: muted)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
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
        "Aucune séance ajoutée pour le moment.",
        style: TextStyle(color: muted),
      ),
    );
  }
}

class AddTrainingLogScreen extends StatefulWidget {
  final int clientId;

  const AddTrainingLogScreen({
    super.key,
    required this.clientId,
  });

  @override
  State<AddTrainingLogScreen> createState() => _AddTrainingLogScreenState();
}

class _AddTrainingLogScreenState extends State<AddTrainingLogScreen> {
  final String baseUrl = "http://127.0.0.1:8000/api";

  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final goalController = TextEditingController();
  final exercisesController = TextEditingController();
  final notesController = TextEditingController();

  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  bool loading = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    dateController.text =
    "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    timeController.text =
    "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  Future<void> saveLog() async {
    if (exercisesController.text.trim().isEmpty) {
      showMsg("Ajoute les exercices");
      return;
    }

    setState(() => loading = true);

    final res = await http.post(
      Uri.parse("$baseUrl/training/create/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "client": widget.clientId,
        "date": dateController.text.trim(),
        "time": timeController.text.trim().length == 5
            ? "${timeController.text.trim()}:00"
            : timeController.text.trim(),
        "weight": weightController.text.trim().isEmpty
            ? null
            : double.tryParse(weightController.text.trim()),
        "height": heightController.text.trim().isEmpty
            ? null
            : double.tryParse(heightController.text.trim()),
        "goal": goalController.text.trim(),
        "exercises": exercisesController.text.trim(),
        "notes": notesController.text.trim(),
      }),
    );

    setState(() => loading = false);

    if (res.statusCode == 201) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      showMsg("Erreur: ${res.body}");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    weightController.dispose();
    heightController.dispose();
    goalController.dispose();
    exercisesController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Widget input(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType type = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Ajouter séance"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            input(dateController, "Date YYYY-MM-DD", Icons.calendar_month),
            input(timeController, "Heure HH:MM", Icons.access_time),
            input(weightController, "Poids kg", Icons.monitor_weight, type: TextInputType.number),
            input(heightController, "Taille cm", Icons.height, type: TextInputType.number),
            input(goalController, "Objectif", Icons.flag),
            input(exercisesController, "Exercices faits", Icons.fitness_center, maxLines: 5),
            input(notesController, "Notes", Icons.note_alt, maxLines: 4),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: loading ? null : saveLog,
                icon: loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                )
                    : const Icon(Icons.save),
                label: Text(
                  loading ? "Enregistrement..." : "Enregistrer",
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
    );
  }
}