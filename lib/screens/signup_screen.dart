import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@tecdesoftware\.edu\.mx$');
    return re.hasMatch(email.toLowerCase());
  }

  bool _isValidPassword(String pass) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  Widget _buildRule(String text, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: ok ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: ok ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;

    final emailErr = email.isEmpty
        ? 'Ingresa tu correo institucional'
        : (!_isValidEmail(email)
              ? 'Debe terminar en @tecdesoftware.edu.mx'
              : null);

    final passErr = pass.isEmpty
        ? 'Ingresa una contraseña'
        : (!_isValidPassword(pass)
              ? 'La contraseña no cumple todas las reglas'
              : null);

    final confirmErr = confirmPass.isEmpty
        ? 'Confirma tu contraseña'
        : (confirmPass != pass ? 'Las contraseñas no coinciden' : null);

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
    });

    FocusScope.of(context).unfocus();

    if (emailErr != null || passErr != null || confirmErr != null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada con éxito. Ahora inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'email-already-in-use' => 'Este correo ya está registrado',
        'invalid-email' => 'El correo electrónico no es válido',
        'weak-password' => 'La contraseña es muy débil',
        _ => e.message ?? 'Error al registrar',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pass = _passwordController.text;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo institucional',
                helperText: 'Debe terminar en @tecdesoftware.edu.mx',
                errorText: _emailError,
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                errorText: _passwordError,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reglas de la contraseña:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  _buildRule('Mínimo 8 caracteres', pass.length >= 8),
                  _buildRule(
                    'Al menos una mayúscula',
                    RegExp(r'[A-Z]').hasMatch(pass),
                  ),
                  _buildRule(
                    'Al menos una minúscula',
                    RegExp(r'[a-z]').hasMatch(pass),
                  ),
                  _buildRule(
                    'Al menos un número',
                    RegExp(r'\d').hasMatch(pass),
                  ),
                  _buildRule(
                    'Al menos un símbolo',
                    RegExp(r'[^A-Za-z0-9]').hasMatch(pass),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                errorText: _confirmPasswordError,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 24),
            MaterialButton(
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              onPressed: _isLoading ? null : _signUp,
              color: Colors.blue,
              disabledColor: Colors.blue.withAlpha(150),
              textColor: Colors.white,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
