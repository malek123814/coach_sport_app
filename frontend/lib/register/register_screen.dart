  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;

  import '../login/login_screen.dart';

  class RegisterScreen extends StatefulWidget {
    final bool isCoach;

    const RegisterScreen({
      super.key,
      required this.isCoach,
    });

    @override
    State<RegisterScreen> createState() => _RegisterScreenState();
  }

  class _RegisterScreenState extends State<RegisterScreen> {
    bool obscurePassword = true;
    bool isLoading = false;

    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final specialityController = TextEditingController();

    final Color bg = const Color(0xFF08111F);
    final Color card = const Color(0xFF0B1424);
    final Color input = const Color(0xFF121C2E);
    final Color green = const Color(0xFF13C783);

    Future<void> registerUser() async {
      setState(() {
        isLoading = true;
      });

      //final url = Uri.parse("http://127.0.0.1:8000/api/register/");
      final url = Uri.parse("http://10.0.2.2:8000/api/register/");

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": fullNameController.text.trim(),
            "email": emailController.text.trim(),
            "password": passwordController.text.trim(),
            "role": widget.isCoach ? "coach" : "client",
            "phone": phoneController.text.trim(),
            "speciality": widget.isCoach ? specialityController.text.trim() : "",
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Compte créé avec succès")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur register: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur connexion backend: $e")),
        );
      }

      setState(() {
        isLoading = false;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Center(
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.isCoach
                            ? "CREATE COACH ACCOUNT"
                            : "CREATE CLIENT ACCOUNT",
                        style: TextStyle(
                          color: green,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.isCoach
                          ? "Join CoachConnect and manage your athletes."
                          : "Join CoachConnect and find your perfect coach.",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 24),

                    label("Username"),
                    inputField(
                      controller: fullNameController,
                      hint: "malek",
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 14),

                    label("Email Address"),
                    inputField(
                      controller: emailController,
                      hint: "example@email.com",
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 14),

                    label("Phone Number"),
                    inputField(
                      controller: phoneController,
                      hint: "+216 12 345 678",
                      icon: Icons.phone_outlined,
                    ),

                    if (widget.isCoach) ...[
                      const SizedBox(height: 14),
                      label("Speciality"),
                      inputField(
                        controller: specialityController,
                        hint: "Fitness, Football, Yoga...",
                        icon: Icons.sports_gymnastics_outlined,
                      ),
                    ],

                    const SizedBox(height: 14),

                    label("Password"),
                    inputField(
                      controller: passwordController,
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      obscure: obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: isLoading ? null : registerUser,
                        child: isLoading
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : const Text(
                          "Create Account",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Login",
                              style: TextStyle(
                                color: green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget label(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    Widget inputField({
      required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool obscure = false,
      Widget? suffix,
    }) {
      return TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey, size: 18),
          suffixIcon: suffix,
          filled: true,
          fillColor: input,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: green),
          ),
        ),
      );
    }
  }