import 'package:flutter/material.dart';
import 'package:next_project/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  void registerUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // 🔒 VALIDATION SECTION
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ All fields are required.")),
      );
      return;
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Name should contain only letters.")),
      );
      return;
    }

    if (!RegExp(r'^[\w\.\-]+@[a-zA-Z]+\.[a-zA-Z]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📧 Invalid email format.")),
      );
      return;
    }

    if (password.length < 8 ||
        !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔐 Password must be at least 8 characters long and include letters & numbers.")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Passwords do not match.")),
      );
      return;
    }

    // ✅ If validation passes, proceed with registration
    setState(() => isLoading = true);
    try {
      final res = await ApiService.registerUser(name, email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Registration complete")),
      );

      if (res['success'] == true) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/register_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Semi-transparent overlay for better contrast
          Container(color: Colors.white.withOpacity(0.4)),

          // Registration card
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 185, 24, 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.orange.withOpacity(0.1),
                        hintText: "Full Name",
                        hintStyle: const TextStyle(color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.orange.withOpacity(0.1),
                        hintText: "Email",
                        hintStyle: const TextStyle(color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.orange.withOpacity(0.1),
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password field
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.orange.withOpacity(0.1),
                        hintText: "Confirm Password",
                        hintStyle: const TextStyle(color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        onPressed: isLoading ? null : registerUser,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login link
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Colors.orange,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
