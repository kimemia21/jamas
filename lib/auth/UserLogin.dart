import 'package:flutter/material.dart';
import 'package:jamas/auth/Signup.dart';
import 'package:jamas/features/user/UserHomepage.dart';
import 'package:jamas/routing/Navigator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Form states
  bool _isLoading = false;
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kenya-specific colors
  static const Color kenyaGreen = Color(0xFF006B3C);
  static const Color kenyaRed = Color(0xFFCE1126);
  static const Color kenyaBlack = Color(0xFF000000);
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color softGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D4F37), Color(0xFF1B5E20), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildLoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset('assets/images/jamas.jpeg', fit: BoxFit.cover),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [premiumGold, Colors.white],
              ).createShader(bounds),
          child: const Text(
            'JaMas Recyclers',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sustainable Transport Solutions',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Text(
            'Welcome Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value!)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isSecured: !_showPassword,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildRememberMeAndForgotPassword(),
            const SizedBox(height: 32),
            _buildLoginButton(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildSignUpLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isSecured = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kenyaGreen,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: isSecured,
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixIcon:
                isSecured
                    ? IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: kenyaGreen,
                      ),
                      onPressed:
                          () => setState(() {
                            _showPassword = !_showPassword;
                          }),
                    )
                    : null,
            prefixIcon: Icon(icon, color: kenyaGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kenyaGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kenyaRed),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged:
                  (value) => setState(() => _rememberMe = value ?? false),
              activeColor: kenyaGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Text(
              'Remember me',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        GestureDetector(
          onTap: _handleForgotPassword,
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: kenyaGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: kenyaGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        GestureDetector(
          onTap: _handleSignUp,
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: kenyaGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, accept any valid email and password
      _showSuccessSnackBar('Login successful! Welcome back.');

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(), // Replace with actual home page
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Login failed. Please check your credentials.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleForgotPassword() {
    // Navigate to forgot password page or show dialog
    _showInfoDialog(
      'Forgot Password',
      'Please contact support or use the password reset feature in the app.',
    );
  }

  void _handleSignUp() {
    // Navigate to registration page
    SmoothNavigator.push(
      context,
      RegistrationPage(),
      type: TransitionType.slideUp,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: softGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kenyaRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: kenyaGreen)),
              ),
            ],
          ),
    );
  }
}
