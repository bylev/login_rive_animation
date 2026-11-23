import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_rive_animation/screens/login_screen.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8090';
    }
    return 'http://localhost:8090';
  }

  Future<List<dynamic>> fetchPets() async {
    final response = await http.get(Uri.parse('$baseUrl/pet'));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Error al cargar mascotas de la API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas de Spring Boot'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pets = snapshot.data ?? [];

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              final isCat = pet['especie'] == 'Gato';
              return ListTile(
                leading: Icon(isCat ? Icons.pets : Icons.pets_outlined),
                title: Text('${pet['nombre']}'),
                // Igual que product['category']['category']: el dueño
                // viene como un objeto dentro de cada mascota.
                subtitle: Text(
                  '${pet['especie']} · ${pet['raza']} · ${pet['sexo']}\n'
                  'Dueño: ${pet['owner']['nombre']} ${pet['owner']['apellido']}',
                ),
                isThreeLine: true,
                trailing: Text(
                  '${pet['edad']} años\n${pet['peso']} kg',
                  textAlign: TextAlign.right,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
