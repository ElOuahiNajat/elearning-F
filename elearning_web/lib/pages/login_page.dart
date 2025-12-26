import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/auth_service.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (response != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        setState(() => _errorMessage = "Email ou mot de passe incorrect");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side: Background with Gradient/Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade900,
                    Colors.deepPurple.shade600,
                    const Color(0xFF6366F1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(
                            Iconsax.teacher,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "E-Learning Platform",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Apprenez sans limites avec notre solution IA",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side: Login Form
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(64),
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bienvenue !",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Connectez-vous pour accéder à vos cours",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 48),
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.danger, color: Colors.red.shade600, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Text(
                          "Adresse Email",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "exemple@mail.com",
                            prefixIcon: const Icon(Iconsax.sms),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Mot de passe",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            prefixIcon: const Icon(Iconsax.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Iconsax.eye : Iconsax.eye_slash),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text("Mot de passe oublié ?"),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Se connecter",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Pas de compte ?",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text("Créer un compte"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
