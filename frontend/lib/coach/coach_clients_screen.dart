import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CoachClientsScreen extends StatefulWidget {
  const CoachClientsScreen({super.key});

  @override
  State<CoachClientsScreen> createState() => _CoachClientsScreenState();
}

class _CoachClientsScreenState extends State<CoachClientsScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";

  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  bool loading = true;
  int? coachId;
  List clients = [];

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    final prefs = await SharedPreferences.getInstance();
    coachId = prefs.getInt("user_id");

    if (coachId == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/coach/clients/$coachId/"),
      );

      if (res.statusCode == 200) {
        setState(() {
          clients = jsonDecode(res.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      await http.delete(Uri.parse("$baseUrl/coach/clients/$id/delete/"));
      await loadClients();
    } catch (e) {
      showMsg("Erreur suppression: $e");
    }
  }

  void openForm({dynamic client}) {
    if (coachId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCoachClientScreen(
          coachId: coachId!,
          client: client,
        ),
      ),
    ).then((_) => loadClients());
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Mes Clients"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => openForm(),
            icon: Icon(Icons.add_circle, color: green),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: green))
          : clients.isEmpty
          ? emptyBox()
          : ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          return clientCard(clients[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        backgroundColor: green,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text("Ajouter client"),
      ),
    );
  }

  Widget emptyBox() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(22),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          "Aucun client ajouté pour le moment.",
          style: TextStyle(color: muted),
        ),
      ),
    );
  }

  Widget clientCard(dynamic c) {
    final total = c["total_sessions"] ?? 0;
    final done = c["done_sessions"] ?? 0;
    final paid = c["paid"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              CircleAvatar(
                backgroundColor: const Color(0xFF123C3B),
                child: Icon(Icons.person, color: green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  c["client_name"]?.toString() ?? "Client",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: paid
                      ? const Color(0xFF123C3B)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  paid ? "Payé" : "Non payé",
                  style: TextStyle(color: paid ? green : Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          info(Icons.flag, "Objectif", c["goal"]?.toString() ?? "-"),
          info(Icons.phone, "Téléphone", c["phone"]?.toString() ?? "-"),
          info(Icons.fitness_center, "Séances", "$done / $total"),
          info(
            Icons.calendar_month,
            "Prochaine séance",
            "${c["next_session_date"] ?? "-"}  ${c["next_session_time"] ?? ""}",
          ),
          info(Icons.note, "Notes", c["notes"]?.toString() ?? "-"),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openForm(client: c),
                  icon: Icon(Icons.edit, color: green),
                  label: Text("Modifier", style: TextStyle(color: green)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: green),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => deleteClient(c["id"]),
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: const Text(
                    "Supprimer",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: green, size: 18),
          const SizedBox(width: 10),
          Text("$label : ", style: TextStyle(color: muted)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class AddCoachClientScreen extends StatefulWidget {
  final int coachId;
  final dynamic client;

  const AddCoachClientScreen({
    super.key,
    required this.coachId,
    this.client,
  });

  @override
  State<AddCoachClientScreen> createState() => _AddCoachClientScreenState();
}

class _AddCoachClientScreenState extends State<AddCoachClientScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final goalController = TextEditingController();
  final totalController = TextEditingController();
  final doneController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final notesController = TextEditingController();

  final Color bg = const Color(0xFF071020);
  final Color card = const Color(0xFF111B2E);
  final Color green = const Color(0xFF16D99A);
  final Color muted = const Color(0xFF8C98AD);

  bool paid = false;
  bool loading = false;

  bool get isEdit => widget.client != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final c = widget.client;

      nameController.text = c["client_name"]?.toString() ?? "";
      phoneController.text = c["phone"]?.toString() ?? "";
      goalController.text = c["goal"]?.toString() ?? "";
      totalController.text = c["total_sessions"]?.toString() ?? "0";
      doneController.text = c["done_sessions"]?.toString() ?? "0";
      dateController.text = c["next_session_date"]?.toString() ?? "";
      timeController.text = c["next_session_time"]?.toString() ?? "";
      notesController.text = c["notes"]?.toString() ?? "";
      paid = c["paid"] == true;
    }
  }

  Future<void> saveClient() async {
    if (nameController.text.trim().isEmpty ||
        goalController.text.trim().isEmpty) {
      showMsg("Nom client et objectif obligatoires");
      return;
    }

    setState(() => loading = true);

    final body = jsonEncode({
      "coach": widget.coachId,
      "client_name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "goal": goalController.text.trim(),
      "total_sessions": int.tryParse(totalController.text.trim()) ?? 0,
      "done_sessions": int.tryParse(doneController.text.trim()) ?? 0,
      "paid": paid,
      "next_session_date":
      dateController.text.trim().isEmpty ? null : dateController.text.trim(),
      "next_session_time": timeController.text.trim().isEmpty
          ? null
          : (timeController.text.trim().length == 5
          ? "${timeController.text.trim()}:00"
          : timeController.text.trim()),
      "notes": notesController.text.trim(),
    });

    final uri = isEdit
        ? Uri.parse("$baseUrl/coach/clients/${widget.client["id"]}/update/")
        : Uri.parse("$baseUrl/coach/clients/create/");

    try {
      final res = isEdit
          ? await http.patch(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      )
          : await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (!mounted) return;

      setState(() => loading = false);

      print("SAVE STATUS: ${res.statusCode}");
      print("SAVE BODY: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        showMsg("Erreur: ${res.body}");
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      showMsg("Erreur connexion backend: $e");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    goalController.dispose();
    totalController.dispose();
    doneController.dispose();
    dateController.dispose();
    timeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Widget input(
      TextEditingController c,
      String label,
      IconData icon, {
        TextInputType type = TextInputType.text,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: type,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(isEdit ? "Modifier client" : "Ajouter client"),
        backgroundColor: bg,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            input(nameController, "Nom client", Icons.person),
            input(phoneController, "Téléphone", Icons.phone),
            input(goalController, "Objectif", Icons.flag),
            input(
              totalController,
              "Nombre total de séances",
              Icons.fitness_center,
              type: TextInputType.number,
            ),
            input(
              doneController,
              "Séances terminées",
              Icons.check_circle,
              type: TextInputType.number,
            ),
            input(
              dateController,
              "Prochaine séance date YYYY-MM-DD",
              Icons.calendar_month,
            ),
            input(
              timeController,
              "Prochaine séance heure HH:MM",
              Icons.access_time,
            ),
            input(
              notesController,
              "Notes coach",
              Icons.note_alt,
              maxLines: 4,
            ),
            SwitchListTile(
              value: paid,
              onChanged: (v) => setState(() => paid = v),
              title: const Text(
                "Client a payé ?",
                style: TextStyle(color: Colors.white),
              ),
              activeColor: green,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: loading ? null : saveClient,
                icon: loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
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