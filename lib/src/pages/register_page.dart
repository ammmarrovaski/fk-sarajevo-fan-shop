import 'package:flutter/material.dart';
import '../modules/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);
    const Color fksBijela = Colors.white;

    return Scaffold(
      backgroundColor: fksBordo,
      // AppBar služi da se korisnik može vratiti nazad na Login
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: fksBijela),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const Text(
                  "NOVI ČLAN",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: fksBijela,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Kreiraj račun i podrži bordo tim!",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fksBijela,
                    hintText: 'Email adresa',
                    prefixIcon: const Icon(Icons.email_outlined, color: fksBordo),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fksBijela,
                    hintText: 'Lozinka (min. 6 znakova)',
                    prefixIcon: const Icon(Icons.lock_outline, color: fksBordo),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fksBijela,
                    hintText: 'Ponovi lozinku',
                    prefixIcon: const Icon(Icons.lock_reset, color: fksBordo),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),

                // Dugme za Registraciju
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fksBijela,
                      foregroundColor: fksBordo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      String email = _emailController.text.trim();
                      String pass = _passwordController.text.trim();
                      String confirmPass = _confirmPasswordController.text.trim();

                      if (pass != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lozinke se ne podudaraju!")),
                        );
                        return;
                      }

                      // Pozivamo našu register funkciju iz AuthService
                      String? greska = await _authService.register(email, pass);

                      if (greska == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Uspješna registracija! Prijavi se.")),
                        );
                        Navigator.pop(context); // Vraća na Login
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(greska), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text("REGISTRUJ SE", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}