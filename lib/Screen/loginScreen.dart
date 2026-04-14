import 'package:fitx/Screen/homeScreen.dart';
import 'package:fitx/Screen/profileSetup.dart';
import 'package:fitx/widgets/globalUiHelper.dart';
import 'package:flutter/material.dart';
import '../services/authService.dart';
import '../services/commonLogic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  Future<void> _checkProfileAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot =
        await FirebaseDatabase.instance
            .ref("users/${user.uid}/profile/profileCompleted")
            .get();

    final completed = snapshot.exists && snapshot.value == true;

    if (!mounted) return;

    if (completed) {
      Navigator.pushReplacementNamed(context, '/bottomNavigation');
    } else {
      Navigator.pushReplacementNamed(context, '/OnboardingFlow');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'Assets/Images/loginScreen.jpg',
                ), // Local image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 65),
                  Text(
                    _isLogin
                        ? ' Welcome Back, Fitness Warrior'
                        : 'Start Your Fitness Journey Today',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  const SizedBox(height: 40),

                  // Toggle Switch
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLogin = true;
                                _resetFields();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    _isLogin
                                        ? Colors.lightGreenAccent.shade100
                                            .withOpacity(0.7)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    color:
                                        _isLogin ? Colors.black : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLogin = false;
                                _resetFields();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    !_isLogin
                                        ? Colors.lightGreenAccent.shade100
                                            .withOpacity(0.7)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    color:
                                        !_isLogin ? Colors.black : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name Field (Only for Signup)
                  if (!_isLogin)
                    Column(
                      children: [
                        UiHelper.textField(
                          label: "Enter Name",
                          icon: const Icon(Icons.person_outline),
                          filterColor: Colors.black.withOpacity(0.5),
                          prefixIconColor: Colors.grey,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Email Field (Common for both)
                  UiHelper.textField(
                    label: "Enter Email",
                    icon: const Icon(Icons.email_outlined),
                    filterColor: Colors.black.withOpacity(0.5),
                    prefixIconColor: Colors.grey,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 12),

                  // Password Field (Common for both)
                  UiHelper.textField(
                    label: "Enter Password",
                    icon: const Icon(Icons.password),
                    isPassword: true,
                    prefixIconColor: Colors.grey,
                    filterColor: Colors.black.withOpacity(0.5),
                    controller: _passwordController,
                  ),
                  if (_isLogin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        UiHelper.textButton(
                          text: "Forgot password",
                          onPressed: () async {
                            final email = _emailController.text.trim();

                            // 1. Empty check
                            if (email.isEmpty) {
                              UiHelper.showToast(
                                context: context,
                                text: "Enter registered email",
                                backgroundColor: Colors.red,
                              );
                              return;
                            }

                            // 2. Format check (Firebase will NOT do this)
                            if (!isValidEmail(email)) {
                              UiHelper.showToast(
                                context: context,
                                text: "Enter a valid email address",
                                backgroundColor: Colors.red,
                              );
                              return;
                            }

                            // 3. Firebase call
                            try {
                              await authService.forgotPassword(email);

                              UiHelper.showToast(
                                context: context,
                                text:
                                    "If an account exists, a password reset link has been sent",
                                backgroundColor: Colors.green,
                              );
                            } catch (e) {
                              UiHelper.showToast(
                                context: context,
                                text: e.toString().replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                                backgroundColor: Colors.red,
                              );
                            }
                          },
                        ),
                      ],
                    ),

                  // Confirm Password Field (Only for Signup)
                  if (!_isLogin)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        UiHelper.textField(
                          label: "Confirm Password",
                          icon: const Icon(Icons.password),
                          isPassword: true,
                          prefixIconColor: Colors.grey,
                          filterColor: Colors.black.withOpacity(0.5),
                          controller: _confirmPasswordController,
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),

                  // Login/Signup Button
                  UiHelper.elevatedButton(
                    Color: Colors.lightGreen.withOpacity(0.9),
                    text: _isLogin ? "Login" : "Sign Up",
                    onPressed: () async {
                      setState(() => _isLoading = true);

                      if (_isLogin) {
                        // Login logic
                        if (_passwordController.text.isEmpty ||
                            _emailController.text.isEmpty) {
                          setState(() => _isLoading = false);
                          // Show error - passwords don't match
                          UiHelper.showToast(
                            context: context,
                            text: "Please fill all required fields",
                            backgroundColor: Colors.red,
                          );
                          return;
                        } else if (!isValidEmail(_emailController.text)) {
                          setState(() => _isLoading = false);
                          UiHelper.showToast(
                            context: context,
                            text: "Enter a valid email address",
                            backgroundColor: Colors.red,
                          );
                          return;
                        }
                        try {
                          await authService.login(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                          setState(() => _isLoading = false);
                          await _checkProfileAndNavigate();

                          UiHelper.showToast(
                            context: context,
                            text: "Login Sucessfull",
                            backgroundColor: Colors.green,
                          );
                        } catch (e) {
                          setState(() => _isLoading = false);

                          UiHelper.showToast(
                            context: context,
                            text: e.toString(),
                            backgroundColor: Colors.red,
                          );
                        }
                      } else {
                        // Signup logic
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          setState(() => _isLoading = false);
                          // Show error - passwords don't match
                          UiHelper.showToast(
                            context: context,
                            text: "Password is mismatch",
                            backgroundColor: Colors.red,
                          );
                        } else {
                          if (_emailController.text.isEmpty) {
                            setState(() => _isLoading = false);
                            UiHelper.showToast(
                              context: context,
                              text: "Email cannot be empty",
                              backgroundColor: Colors.red,
                            );
                            return;
                          }

                          if (!isValidEmail(_emailController.text)) {
                            setState(() => _isLoading = false);
                            UiHelper.showToast(
                              context: context,
                              text: "Enter a valid email address",
                              backgroundColor: Colors.red,
                            );
                            return;
                          }
                          try {
                            final credential = await authService.signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            final uid = credential.user!.uid;
                            await FirebaseDatabase.instance
                                .ref("users/$uid/profile")
                                .update({"name": _nameController.text.trim()});

                            setState(() => _isLoading = false);
                            _resetFields();
                            UiHelper.showToast(
                              context: context,
                              text: "Signup successful",
                              backgroundColor: Colors.green,
                            );
                            await Future.delayed(const Duration(seconds: 1));
                          } catch (e) {
                            setState(() => _isLoading = false);
                            UiHelper.showToast(
                              context: context,
                              text: e.toString(),
                              backgroundColor: Colors.red,
                            );
                          }
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 30),

                  // Or divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade700)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade700)),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // Social Login Buttons
                  Row(
                    children: [
                      // Google button
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.green.withOpacity(0.2),
                              // highlightColor: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                setState(() => _isLoading = true);

                                try {
                                  final userCredential =
                                      await authService.signInWithGoogle();

                                  if (userCredential != null) {
                                    await _checkProfileAndNavigate();

                                    UiHelper.showToast(
                                      context: context,
                                      text: "Signed in with Google",
                                      backgroundColor: Colors.green,
                                    );
                                  } else {
                                    UiHelper.showToast(
                                      context: context,
                                      text: "Login failed",
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                } catch (e) {
                                  UiHelper.showToast(
                                    context: context,
                                    text: e.toString(), // SHOW REAL ERROR
                                    backgroundColor: Colors.red,
                                  );
                                }

                                setState(() => _isLoading = false);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.g_mobiledata_sharp,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Google',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Apple button
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                UiHelper.showToast(
                                  context: context,
                                  text: "Apple Sign-In is coming soon.",
                                  backgroundColor: Colors.orange,
                                );
                              },
                              splashColor: Colors.green.withOpacity(0.2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.apple, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Apple',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
