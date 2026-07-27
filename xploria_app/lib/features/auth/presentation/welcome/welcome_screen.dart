import 'package:flutter/material.dart';
import '../widgets/xploria_logo.dart';
import '../widgets/auth_background.dart';
import '../login/login_screen.dart';
import '../register/register_screen.dart';

enum AuthMode { welcome, login, register }

class WelcomeScreen extends StatefulWidget {
  final AuthMode initialMode;
  const WelcomeScreen({
    super.key,
    this.initialMode = AuthMode.welcome,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late AuthMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
  }

  void _switchMode(AuthMode mode) {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const animDuration = Duration(milliseconds: 500);
    const animCurve = Curves.fastOutSlowIn;

    return PopScope(
      canPop: _currentMode == AuthMode.welcome,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentMode != AuthMode.welcome) {
          _switchMode(AuthMode.welcome);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AuthBackground(
          dimBubbles: _currentMode != AuthMode.welcome,
          child: Stack(
            children: [
              // 1. Animated Back Button (top-left)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: animCurve,
                top: 50,
                left: _currentMode == AuthMode.welcome ? -60 : 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _currentMode == AuthMode.welcome ? 0.0 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _switchMode(AuthMode.welcome),
                    ),
                  ),
                ),
              ),

              // 2. Animated Logo Position & Scale
              AnimatedPositioned(
                duration: animDuration,
                curve: animCurve,
                top: _currentMode == AuthMode.welcome
                    ? size.height * 0.22
                    : (_currentMode == AuthMode.register
                        ? size.height * 0.03
                        : size.height * 0.04),
                left: 0,
                right: 0,
                child: AnimatedScale(
                  duration: animDuration,
                  curve: animCurve,
                  scale: _currentMode == AuthMode.welcome ? 1.0 : 0.65,
                  child: const XploriaLogo(scale: 1.0),
                ),
              ),

              // 3. Welcome Action Buttons (Sign Up & Login)
              AnimatedPositioned(
                duration: animDuration,
                curve: animCurve,
                bottom: _currentMode == AuthMode.welcome ? 60.0 : -160.0,
                left: 32,
                right: 32,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _currentMode == AuthMode.welcome ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      // "Sign Up" Button
                      _buildActionButton(
                        text: 'Sign Up',
                        backgroundColor: Colors.white,
                        textColor: const Color(0xFF005CFF),
                        onPressed: () => _switchMode(AuthMode.register),
                      ),
                      const SizedBox(height: 16),
                      // "Login" Button (Outlined)
                      _buildActionButton(
                        text: 'Login',
                        backgroundColor: Colors.transparent,
                        textColor: Colors.white,
                        hasBorder: true,
                        onPressed: () => _switchMode(AuthMode.login),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Sliding White Form Container (Bottom Sheet)
              AnimatedPositioned(
                duration: animDuration,
                curve: animCurve,
                top: _currentMode == AuthMode.welcome
                    ? size.height
                    : (_currentMode == AuthMode.register
                        ? size.height * 0.22
                        : size.height * 0.24),
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _currentMode == AuthMode.register
                        ? RegisterFormContent(
                            key: const ValueKey('RegisterForm'),
                            onSwitchToLogin: () => _switchMode(AuthMode.login),
                          )
                        : _currentMode == AuthMode.login
                            ? LoginFormContent(
                                key: const ValueKey('LoginForm'),
                                onSwitchToRegister: () => _switchMode(AuthMode.register),
                              )
                            : const SizedBox.shrink(key: ValueKey('EmptyForm')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    bool hasBorder = false,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: hasBorder ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: hasBorder ? [] : [
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
}
