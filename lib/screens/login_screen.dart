import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_rive_animation/screens/pets_screen.dart';
import 'package:login_rive_animation/screens/signup_screen.dart';
import 'package:rive/rive.dart';

import 'dart:async'; //importar timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true; // Control para mostrar/Ocultar contraseña
  bool _isLoading = false; // 5.2 Muestra el spinner mientras se autentica

  // 1.1 Máquina estados  //Cerebro de la animación
  StateMachineController? _controller;

  //STATEMACHINEINPUT
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  //timer para detener el recorrido de la mirada
  Timer? _typingDebounce;

  // Cambiar color FocusNode: Que un campo esté resaltado
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  //4.1 Controles para manipular lo que escribe el usuario
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  //4.2 Errores para mostrar al usuario
  String? emailError;
  String? passError;

  // 4.3 Validadores

  bool isValidEmail(String email) {
    //final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (email.trim().isEmpty) {
      return false;
    }
    return true;
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    /* final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );*/
    if (pass.trim().isEmpty) {
      return false;
    }
    return true;
  }

  // 4.4 Acción del botón de login
  Future<void> _onLogin() async {
    if (_isLoading) return;

    //Recortar espacios en blanco accidentales
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    // Recalcular errores
    final emailTypedError = isValidEmail(email) ? null : 'Email inválido';
    final passTypedError = isValidPassword(pass) ? null : 'Contraseña inválida';

    //4.5 Para mostrar el cambio
    /*
    setState(() {
      emailError = emailTypedError;
      passError = passTypedError;
    });*/

    //4.6 Cerrar el teclado y oso neutro
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    //4.7 Si el formato es inválido, el oso falla y no se llama a Firebase
    if (emailTypedError != null || passTypedError != null) {
      _trigFail?.fire();
      return;
    }

    // 5.4 Mostrar spinner
    setState(() {
      _isLoading = true;
    });

    try {
      // 5.5 Retardo artificial para ver el spinner (quitar en producción)
      await Future.delayed(const Duration(seconds: 2));
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // 5.6 Login correcto: el oso celebra
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _trigSuccess?.fire();
      await Future.delayed(const Duration(seconds: 2));

      // 5.7 Navegar a mascotas sin poder regresar al login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PetsScreen()),
      );
    } catch (e) {
      // 5.8 Credenciales no válidas: mensaje general, sin marcar un campo
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _trigFail?.fire();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales inválidas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onForgotPassword() async {
    String resetEmail = emailCtrl.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Recuperar contraseña'),
          content: TextFormField(
            initialValue: resetEmail,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            onChanged: (value) => resetEmail = value,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'ejemplo@tecdesoftware.edu.mx',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final email = resetEmail.trim();
    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo electrónico'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Si el correo está registrado, recibirás un enlace para restablecer tu contraseña',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = e.code == 'invalid-email'
          ? 'El formato del correo no es válido'
          : (e.message ?? 'No se pudo enviar el correo');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  //Ciclo de vida del widget (createStare, initState, Build, setState, dispose)

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        if (_isHandsUp != null) {
          _isHandsUp!.change(false);
          // Mirada neutral
          _numLook?.value = 50.0;
        }
      }
    });
    _passwordFocus.addListener(() {
      _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context)
        .size; //obtiene el tamñao de la pantalla

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  //Para separar elementos
                  width: screenSize.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    "assets/michi.riv",
                    stateMachines: ['Login Machine'],
                    //1.2 Vincular la animación
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );

                      if (_controller == null) return;
                      //Agregar controlador al escenario
                      artboard.addController(_controller!);
                      //1.4 Vincular las variables
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  //2.3 Asignar el focus al text field
                  focusNode: _emailFocus,
                  onChanged: (value) {
                    if (_isHandsUp != null) {
                      // _isHandsUp!.change(false); //manos abajo cuando escribo
                    }

                    if (_isChecking != null) {
                      _isChecking!.change(true); //mirada de preocupacion
                    }
                    // Implementar recorrido de mirada
                    // Ajuste de límites del 0 al 100
                    //80 medida de calibración
                    final look = (value.length / 80.0 * 100.0).clamp(
                      0.0,
                      100.0,
                    );
                    _numLook?.value = look;

                    // Debounce: Si vuelve a teclear, reinicia el contador
                    // En tres segundos se vuelve mirada neutral
                    _typingDebounce?.cancel();
                    // Crear nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      //Si se cierra la pantalla, termina la ejecución
                      if (!mounted) return;

                      _isChecking?.change(false);
                    });
                  },
                  decoration: InputDecoration(
                    //! errorText: emailError,
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
                  controller: passCtrl,
                  focusNode: _passwordFocus,
                  onChanged: (value) {
                    if (_isChecking != null) {
                      // _isChecking!.change(false);
                    }

                    if (_isHandsUp != null) {
                      _isHandsUp!.change(true);
                    }
                  },
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    //!errorText: passError,
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
                const SizedBox(height: 10),
                SizedBox(
                  width: screenSize.width,
                  child: GestureDetector(
                    onTap: _onForgotPassword,
                    child: const Text(
                      "Forgot Password?",
                      textAlign: TextAlign.right,
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MaterialButton(
                  minWidth: screenSize.width,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  onPressed: _onLogin,
                  color: Colors.blue,
                  textColor: Colors.white,
                  // 5.9 Spinner mientras carga
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Login'),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: screenSize.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Dispose
  @override
  void dispose() {
    //Liberar memoria en los focusNode
    _emailFocus.dispose();
    _passwordFocus.dispose();
    //Liberar memoria en los controladores de texto
    emailCtrl.dispose();
    passCtrl.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}
