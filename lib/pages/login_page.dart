import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Definisanje boja
    const Color fksBordo = Color(0xFF800000);
    const Color fksBijela = Colors.white;

    return Scaffold(
      // 1. Postavljamo bordo pozadinu za cijeli ekran
      backgroundColor: fksBordo, 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
Container(
  height: 150,
  child: Image.asset(
    'assets/images/fksarajevo.png',
    fit: BoxFit.contain,
  ),
),
              const SizedBox(height: 20),
              const Text(
                "FKS SHOP",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: fksBijela, // Bijeli tekst na bordo pozadini
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),

              // 3. Polja za unos (sada moraju imati bijelu pozadinu da se vide)
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fksBijela,
                  labelText: 'Email adresa',
                  prefixIcon: const Icon(Icons.email_outlined, color: fksBordo),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fksBijela,
                  labelText: 'Lozinka',
                  prefixIcon: const Icon(Icons.lock_outline, color: fksBordo),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),

              // 4. Bijelo dugme sa bordo tekstom
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fksBijela, // Obrnuto
                    foregroundColor: fksBordo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    print("Pokušaj prijave...");
                  },
                  child: const Text("PRIJAVI SE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => print("Idi na registraciju"),
                child: const Text(
                  "Nemaš račun? Registruj se",
                  style: TextStyle(color: fksBijela),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}