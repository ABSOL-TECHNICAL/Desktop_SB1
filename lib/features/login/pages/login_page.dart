import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/login/controllers/login_controller.dart';
import 'package:impal_desktop/version_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());
  final VersionController versionController = Get.put(VersionController());

  bool _obscured = true;
  bool _isLoading = false;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    await controller.login();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_bg.avif',
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/impal.png',
                height: 130,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(30.0),
                width: 400,
                height: 380,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Text(
                      "Login",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ), 
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            hintText: "Username",
                            icon: Icons.person,
                            isPassword: false,
                            controller: controller.username,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            hintText: "Password",
                            icon: Icons.lock,
                            isPassword: true,
                            controller: controller.password,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 80),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          :  Text(
                              "Login",
                              style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                ), 
                              // TextStyle(
                              //   color: Colors.white,
                              //   fontSize: 16,
                              //   fontWeight: FontWeight.w600,
                              // ),
                            ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Text.rich(
                      TextSpan(
                        text: "All rights reserved to ",
                        style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                 
                 
                ), 
                        children: [
                          TextSpan(
                            text: "ABSOL",
                            style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 33, 68, 243),
                 
                ), 
                            //  TextStyle(
                            //   fontWeight: FontWeight.bold,
                            //   color: Color.fromARGB(255, 33, 68, 243),
                            // ),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => Text(
                          'Version: ${versionController.version}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14                         
                        ))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required bool isPassword,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscured,
      style: theme.textTheme.bodyLarge?.copyWith(
                        
                  color: Colors.black,
                 
                ), 
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        hintText: hintText,
        hintStyle:  theme.textTheme.bodyLarge?.copyWith(
                        
                  color: Colors.black,
                 
                ), 
        prefixIcon: Icon(icon, color: Colors.black87),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: _toggleObscured,
                child: Icon(
                  _obscured ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isPassword ? "Please enter password" : "Please enter username";
        }
        return null;
      },
    );
  }
}
