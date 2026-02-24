import 'package:flutter/material.dart';
import '../modules/auth_service.dart'; // Importujemo servis za bazu // Importujemo servis za bazu
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Kontroleri i servis
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color fksBordo = Color(0xFF800000);
    const Color fksBijela = Colors.white;

    return Scaffold(
      backgroundColor: fksBordo, // Bordo pozadina
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Grb Sarajeva
                Image.asset(
                  'assets/images/fksarajevo.png',
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.shield, size: 100, color: fksBijela),
                ),
                const SizedBox(height: 20),
                const Text(
                  "FKS SHOP",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: fksBijela,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fksBijela,
                    hintText: 'Email adresa',
                    prefixIcon: const Icon(Icons.email_outlined, color: fksBordo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fksBijela,
                    hintText: 'Lozinka',
                    prefixIcon: const Icon(Icons.lock_outline, color: fksBordo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Dugme
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fksBijela,
                      foregroundColor: fksBordo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Popunite sva polja!")),
                        );
                        return;
                      }

                      // Pozivamo Firebase preko servisa
                      String? greska = await _authService.login(email, password);

                      if (greska == null) {
                        print("Uspješan login!");
                        // Ovdje ćemo dodati navigaciju na Home
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Greška: $greska"),
                            backgroundColor: Colors.orange[900],
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "PRIJAVI SE",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Dugme za Registraciju
                TextButton(
                  onPressed: () {
                    print("Navigacija na Register stranu...");
                    Navigator.push(
                      context,MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                  },
                  child: const Text(
                    "Nemaš račun? Registruj se ovdje",
                    style: TextStyle(color: fksBijela, fontWeight: FontWeight.w600),
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