import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true; // Control para mostrar/Ocultar contraseña
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context)
        .size; //obtiene el tamñao de la pantalla

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                //Para separar elementos
                width: screenSize.width,
                height: 200,
                child: RiveAnimation.asset("assets/michi.riv"),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    // Propiedad para redondear esquinas
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ), //Email
              const SizedBox(height: 10),
              TextField(
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // Refrescar el ícono
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: Icon(
                      //If ternario
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    // Propiedad para redondear esquinas
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ), // Password
            ],
          ),
        ),
      ),
    );
  }
}
