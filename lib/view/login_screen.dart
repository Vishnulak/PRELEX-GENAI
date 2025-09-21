import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'home_screen.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Signup controllers
  final _signupUsernameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  // Visibility states
  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureSignupConfirmPassword = true;

  // Validation states for login
  bool _isLoginEmailValid = false;
  bool _isLoginPasswordValid = false;

  // Validation states for signup
  bool _isSignupUsernameValid = false;
  bool _isSignupEmailValid = false;
  bool _isSignupPasswordValid = false;
  bool _isSignupConfirmPasswordValid = false;

  // Hover states
  bool _isLoginButtonHovered = false;
  bool _isSignupButtonHovered = false;

  // Animation controllers
  late AnimationController _borderController;
  late AnimationController _flipController;
  late AnimationController _loginButtonController;
  late AnimationController _signupButtonController;

  // Animations
  late Animation<double> _borderAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _loginButtonScale;
  late Animation<double> _signupButtonScale;

  bool _showLogin = true; // true for login, false for signup

  @override
  void initState() {
    super.initState();

    _borderController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _flipController = AnimationController(
      duration: Duration(milliseconds: 600), // Reduced from 800ms for smoother flip
      vsync: this,
    );

    _loginButtonController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _signupButtonController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_borderController);

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.fastOutSlowIn, // Changed to smoother curve
    ));

    _loginButtonScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _loginButtonController,
      curve: Curves.easeInOut,
    ));

    _signupButtonScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _signupButtonController,
      curve: Curves.easeInOut,
    ));

    _borderController.repeat();
  }

  void _flipCard() {
    print('Flip card called, current state: _showLogin = $_showLogin');

    if (_showLogin) {
      // Going from login to signup
      _flipController.forward();
    } else {
      // Going from signup to login
      _flipController.reverse();
    }

    setState(() {
      _showLogin = !_showLogin;
    });
  }

  void _validateLoginField(String field, String value) {
    setState(() {
      switch (field) {
        case 'email':
          _isLoginEmailValid = value.isNotEmpty &&
              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
          break;
        case 'password':
          _isLoginPasswordValid = value.length >= 6;
          break;
      }
    });
  }

  void _validateSignupField(String field, String value) {
    setState(() {
      switch (field) {
        case 'username':
          _isSignupUsernameValid = value.isNotEmpty;
          break;
        case 'email':
          _isSignupEmailValid = value.isNotEmpty &&
              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
          break;
        case 'password':
          _isSignupPasswordValid = value.length >= 6;
          break;
        case 'confirmPassword':
          _isSignupConfirmPasswordValid =
              value.isNotEmpty && value == _signupPasswordController.text;
          break;
      }
    });
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required bool isValid,
    required String? Function(String?) validator,
    required Function(String) onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      width: 300, // Limited width to make input fields shorter
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(color: Colors.white, fontSize: 16),
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                letterSpacing: 1.2,
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: isValid ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: AnimatedScale(
                      scale: isValid ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  if (suffixIcon != null) suffixIcon,
                ],
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Center align all content
        children: [
          // Title with glow
          Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),

          // Email field
          _buildAnimatedTextField(
            controller: _loginEmailController,
            label: 'EMAIL',
            isValid: _isLoginEmailValid,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onChanged: (value) => _validateLoginField('email', value),
          ),
          SizedBox(height: 20),

          // Password field
          _buildAnimatedTextField(
            controller: _loginPasswordController,
            label: 'PASSWORD',
            isValid: _isLoginPasswordValid,
            obscureText: _obscureLoginPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _obscureLoginPassword = !_obscureLoginPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onChanged: (value) => _validateLoginField('password', value),
          ),
          SizedBox(height: 30),

          // Sign In Button - reduced width
          MouseRegion(
            onEnter: (_) {
              setState(() => _isLoginButtonHovered = true);
              _loginButtonController.forward();
            },
            onExit: (_) {
              setState(() => _isLoginButtonHovered = false);
              _loginButtonController.reverse();
            },
            child: AnimatedBuilder(
              animation: _loginButtonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _loginButtonScale.value,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 200, // Reduced width
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isLoginButtonHovered
                            ? [Colors.cyan[300]!, Colors.blue[300]!]
                            : [Colors.cyan, Colors.blue[400]!],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: _isLoginButtonHovered
                          ? [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_loginFormKey.currentState!.validate()) {
                          // Navigate to PrelexLandingPage
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PrelexHomePage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),

          // Forgot password link
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  print('Forgot password clicked');
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Sign up link - removed border box
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account? ',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    print('Flip to signup clicked');
                    _flipCard();
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.cyan,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Center align all content
        children: [
          // Title with glow
          Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),

          // Username field
          _buildAnimatedTextField(
            controller: _signupUsernameController,
            label: 'USERNAME',
            isValid: _isSignupUsernameValid,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
            onChanged: (value) => _validateSignupField('username', value),
          ),
          SizedBox(height: 15),

          // Email field
          _buildAnimatedTextField(
            controller: _signupEmailController,
            label: 'EMAIL',
            isValid: _isSignupEmailValid,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onChanged: (value) => _validateSignupField('email', value),
          ),
          SizedBox(height: 15),

          // Password field
          _buildAnimatedTextField(
            controller: _signupPasswordController,
            label: 'PASSWORD',
            isValid: _isSignupPasswordValid,
            obscureText: _obscureSignupPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignupPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _obscureSignupPassword = !_obscureSignupPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onChanged: (value) => _validateSignupField('password', value),
          ),
          SizedBox(height: 15),

          // Confirm Password field
          _buildAnimatedTextField(
            controller: _signupConfirmPasswordController,
            label: 'CONFIRM PASSWORD',
            isValid: _isSignupConfirmPasswordValid,
            obscureText: _obscureSignupConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignupConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _obscureSignupConfirmPassword = !_obscureSignupConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _signupPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            onChanged: (value) => _validateSignupField('confirmPassword', value),
          ),
          SizedBox(height: 25),

          // Sign Up Button - reduced width
          MouseRegion(
            onEnter: (_) {
              setState(() => _isSignupButtonHovered = true);
              _signupButtonController.forward();
            },
            onExit: (_) {
              setState(() => _isSignupButtonHovered = false);
              _signupButtonController.reverse();
            },
            child: AnimatedBuilder(
              animation: _signupButtonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _signupButtonScale.value,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 200, // Reduced width
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isSignupButtonHovered
                            ? [Colors.cyan[300]!, Colors.blue[300]!]
                            : [Colors.cyan, Colors.blue[400]!],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: _isSignupButtonHovered
                          ? [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_signupFormKey.currentState!.validate()) {
                          // Navigate to PrelexLandingPage
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PrelexHomePage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 15),

          // Sign in link - removed border box
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    print('Flip to login clicked');
                    _flipCard();
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.cyan,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background image on the right side
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/login_bg1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Left side - Dark background
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Container(
                color: Color(0xFF1a1a1a),
              ),
            ),

            // Centered form container with animated cyan border and flip animation
            Center(
              child: AnimatedBuilder(
                animation: _borderAnimation,
                builder: (context, child) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.8,
                    decoration: BoxDecoration(
                      gradient: SweepGradient(
                        colors: [
                          Colors.cyan,
                          Colors.black,
                          Colors.cyan,
                          Colors.black,
                          Colors.cyan,
                          Colors.black,
                          Colors.cyan,
                        ],
                        stops: [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 1.0],
                        transform: GradientRotation(_borderAnimation.value * 2 * 3.14159),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          // Left side - Form area with flip animation
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF1a1a1a),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(9),
                                  bottomLeft: Radius.circular(9),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: Offset(5, 0),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                              child: AnimatedBuilder(
                                animation: _flipAnimation,
                                builder: (context, child) {
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(_flipAnimation.value * math.pi),
                                    child: _flipAnimation.value <= 0.5
                                        ? _buildLoginForm()
                                        : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..rotateY(math.pi),
                                      child: _buildSignupForm(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Right side - Background image area
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('images/login_bg1.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(9),
                                  bottomRight: Radius.circular(9),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: Offset(-5, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _borderController.dispose();
    _flipController.dispose();
    _loginButtonController.dispose();
    _signupButtonController.dispose();

    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupUsernameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();

    super.dispose();
  }
}

