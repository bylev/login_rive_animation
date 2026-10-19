import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true; // Control para mostrar/Ocultar contraseña

  // 1.1 Máquina estados  //Cerebro de la animación
  StateMachineController? _controller;

  //STATEMACHINEINPUT
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

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
                  onChanged: (value) {
                    if (_isHandsUp != null) {
                      _isHandsUp!.change(false);
                    }

                    if (_isChecking != null) {
                      _isChecking!.change(true);
                    }
                  },
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
                  onChanged: (value) {
                    if (_isChecking != null) {
                      _isChecking!.change(false);
                    }

                    if (_isHandsUp != null) {
                      _isHandsUp!.change(true);
                    }
                  },
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
      ),
    );
  }
}
