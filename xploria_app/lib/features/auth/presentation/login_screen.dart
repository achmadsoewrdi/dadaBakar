import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AuthState { initial, login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthState _currentState = AuthState.initial;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _changeState(AuthState newState) {
    setState(() {
      _currentState = newState;
    });
  }

  void _handleAuthSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          String message = _currentState == AuthState.login
              ? 'Selamat datang kembali di Xploria! 🚀'
              : 'Pendaftaran berhasil! Ayo jelajahi Xploria! 🎉';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: const Color(0xFF005CFF),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isInitial = _currentState == AuthState.initial;

    // Calculate dynamic layout values for animation
    double logoTop = isInitial ? size.height * 0.22 : size.height * 0.05;
    double logoScale = isInitial ? 1.0 : 0.65;
    double formTop = isInitial ? size.height : (_currentState == AuthState.login ? size.height * 0.32 : size.height * 0.26);
    double initialButtonsBottom = isInitial ? 60.0 : -200.0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Dark Navy Background (matching logo style)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0A122C),
          ),

          // 2. Playful floating circles in logo colors (Blue & Teal)
          // Top-right light blue/cyan bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: isInitial ? -60 : -100,
            right: isInitial ? -60 : -120,
            child: _buildBubble(size.width * 0.6, const Color(0xFF00C2FF).withOpacity(isInitial ? 0.35 : 0.15)),
          ),
          // Top-left soft teal bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: isInitial ? 80 : 20,
            left: isInitial ? -50 : -90,
            child: _buildBubble(110, const Color(0xFF00E3A2).withOpacity(0.15)),
          ),
          // Center-bottom large blue/violet bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            bottom: isInitial ? -size.height * 0.1 : -size.height * 0.3,
            left: -50,
            child: _buildBubble(size.width * 0.8, const Color(0xFF005CFF).withOpacity(0.12)),
          ),
          // Bottom-right teal/cyan bubble
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            bottom: isInitial ? 30 : -50,
            right: isInitial ? -20 : -60,
            child: _buildBubble(90, const Color(0xFF00E3A2).withOpacity(0.25)),
          ),

          // 3. Dynamic Animated Back Button (top-left)
          if (!isInitial)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _changeState(AuthState.initial);
                  },
                ),
              ),
            ),

          // 4. Sliding/Scaling Logo "Xploria" (integrated style)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            top: logoTop,
            left: 0,
            right: 0,
            child: AnimatedScale(
              scale: logoScale,
              duration: const Duration(milliseconds: 600),
              curve: Curves.fastOutSlowIn,
              child: _buildXploriaLogo(),
            ),
          ),

          // 5. Initial Screen Action Buttons
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            bottom: initialButtonsBottom,
            left: 32,
            right: 32,
            child: Column(
              children: [
                // "Sign Up" Button (Teal/Cyan matching the brand)
                _buildActionButton(
                  text: 'Sign Up',
                  backgroundColor: const Color(0xFF2ED9C3),
                  textColor: Colors.white,
                  onPressed: () => _changeState(AuthState.register),
                ),
                const SizedBox(height: 16),
                // "Login" Button (White with blue text)
                _buildActionButton(
                  text: 'Login',
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF005CFF),
                  onPressed: () => _changeState(AuthState.login),
                ),
              ],
            ),
          ),

          // 6. Sliding White Container for Form (Login / Register)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            top: formTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Title
                      Text(
                        _currentState == AuthState.login ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A122C),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name Input (Register only)
                      if (_currentState == AuthState.register) ...[
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005CFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'John Doe',
                          icon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (_currentState == AuthState.register) {
                              if (value == null || value.isEmpty) {
                                return 'Nama lengkap tidak boleh kosong';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Email Input
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005CFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'hello@xploria.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Input
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005CFF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    // Forgot Password (only in login state)
                    if (_currentState == AuthState.login)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF005CFF),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Submit Button
                      _buildSubmitButton(),
                      const SizedBox(height: 24),

                      // Switch state link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentState == AuthState.login
                                  ? "Don't have an account? "
                                  : "Already a member? ",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _formKey.currentState?.reset();
                                if (_currentState == AuthState.login) {
                                  _changeState(AuthState.register);
                                } else {
                                  _changeState(AuthState.login);
                                }
                              },
                              child: Text(
                                _currentState == AuthState.login ? 'Sign Up' : 'Sign In',
                                style: const TextStyle(
                                  color: Color(0xFF005CFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
          ),
        ],
      ),
    );
  }

  // High-fidelity replica of the Xploria Logo (X with rocket + stylized PLORIA text)
  Widget _buildXploriaLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. The stylized "X" with rocket
        SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left-to-right blue bar
              Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  width: 17,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF005CFF), Color(0xFF00C2FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              // Right-to-left teal bar
              Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 17,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E3A2), Color(0xFF00C6AB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              // Rocket icon flying out of the teal bar
              Positioned(
                top: 10,
                right: 10,
                child: Transform.rotate(
                  angle: math.pi / 4, // Tilted along the right-to-left bar
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A122C), // Cutout matching background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Color(0xFF00E3A2),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Stylized logo text: "PLORIA" (using custom 'O' with dot)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'PL',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2ED9C3), // Mint green
                letterSpacing: 2.0,
                fontFamily: 'Montserrat',
              ),
            ),
            // Custom circular 'O' with center dot
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2ED9C3), width: 3.5),
              ),
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2ED9C3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const Text(
              'RIA',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2ED9C3),
                letterSpacing: 2.0,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Slogan
        Text(
          'Explore the fun of learning!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Initial Action buttons
  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Input Field (styled in brand colors)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF005CFF).withOpacity(0.04), // Blue tint background
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF005CFF).withOpacity(0.7), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: const Color(0xFF005CFF).withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF005CFF), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  // Next / Register Button inside form (gradient button)
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005CFF), Color(0xFF2ED9C3)], // Blue to teal gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005CFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAuthSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                _currentState == AuthState.login ? 'Sign In' : 'Create Account',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // Floating background bubbles
  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
