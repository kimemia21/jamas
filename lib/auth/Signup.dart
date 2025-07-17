import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamas/features/user/UserHomepage.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _kraPinController = TextEditingController();
  final _referralController = TextEditingController();
  final _otpController = TextEditingController();
  final _passWordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form states
  bool _isLoading = false;
  bool _showOtpField = false;
  bool _otpSent = false;
  String _otpMethod = 'phone';
  int _otpCountdown = 60;
  bool showpassword = false;

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
    _fullNameController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    _passWordController.dispose();
    _phoneController.dispose();
    _kraPinController.dispose();
    _referralController.dispose();
    _otpController.dispose();
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
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildRegistrationForm(),
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
            'Create Your Account',
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

  Widget _buildRegistrationForm() {
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
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Full name is required';
                if (value!.length < 2)
                  return 'Name must be at least 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 20),
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
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              prefixText: '+254 ',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone number is required';
                if (value!.length != 9)
                  return 'Enter a valid Kenyan phone number';
                if (!RegExp(r'^[17]').hasMatch(value)) {
                  return 'Phone number must start with 7 or 1';
                }
                return null;
              },
            ),
            _buildTextField(controller:_passWordController, label: "Enter Password", icon: Icons.lock ,validator: (value){
              if (value?.isEmpty ?? true) return 'password is required';
              return null;
            },
            
            isSecured: showpassword),
                 _buildTextField(controller:_confirmPasswordController, label: "Confirm Password", icon: Icons.lock ,validator: (value){
              if (value?.isEmpty ?? true) return 'Confirm password is required';
                 if (value!=_passWordController.text ) return 'Passwords are not matching';
              return null;
            },
            
            isSecured: showpassword),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _kraPinController,
              label: 'KRA PIN',
              icon: Icons.badge_outlined,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) return 'KRA PIN is required';
                if (!RegExp(r'^[A-Z]\d{9}[A-Z]$').hasMatch(value!)) {
                  return 'Enter a valid KRA PIN (e.g., A123456789Z)';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _referralController,
              label: 'Referral Number (Agent ID Optional)',
              icon: Icons.group_outlined,
              required: false,
              validator: (value) {
                if (value?.isNotEmpty ?? false) {
                  if (value!.length < 3) return 'Invalid referral number';
                }
                return null;
              },
            ),
            if (_showOtpField) ...[
              const SizedBox(height: 20),
              _buildOtpSection(),
            ],
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildLoginLink(),
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
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    String? prefixText,
    bool required = true,
    bool isSecured =false,

  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kenyaGreen,
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: kenyaRed, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: isSecured,

          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization ?? TextCapitalization.words,
          decoration: InputDecoration
          (
            suffix: isSecured
                ? IconButton(
                    icon: Icon(showpassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () =>setState(() {
                      showpassword=!showpassword;
                    }),
                  )
                : null,
            prefixIcon: Icon(icon, color: kenyaGreen),
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              color: kenyaGreen,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildOtpSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: softGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: softGreen),
              const SizedBox(width: 8),
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: softGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _otpSent
                ? 'Enter the OTP sent to your ${_otpMethod == 'phone' ? 'phone' : 'email'}'
                : 'Choose verification method:',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          if (!_otpSent) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOtpMethodButton('Phone', Icons.phone, 'phone'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOtpMethodButton('Email', Icons.email, 'email'),
                ),
              ],
            ),
          ],
          if (_otpSent) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText: _otpCountdown > 0 ? '${_otpCountdown}s' : null,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'OTP is required';
                if (value!.length != 6) return 'OTP must be 6 digits';
                return null;
              },
            ),
            if (_otpCountdown == 0) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _resendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(color: softGreen),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildOtpMethodButton(String text, IconData icon, String method) {
    final isSelected = _otpMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _otpMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? softGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? softGreen : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
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
                    : Text(
                      _showOtpField
                          ? (_otpSent ? 'Verify & Register' : 'Send OTP')
                          : 'Continue',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Sign In',
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

  void _handleSubmit() async {
     if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (!_showOtpField) {
        // First submission - show OTP field
        setState(() {
          _showOtpField = true;
          _isLoading = false;
        });
      } else if (!_otpSent) {
        // Send OTP
        await _sendOtp();
      } else {
        // Verify OTP and complete registration
        await _verifyOtpAndRegister();
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _otpSent = true;
      _otpCountdown = 60;
    });

    _startCountdown();
    _showSuccessSnackBar(
      'OTP sent to your ${_otpMethod == 'phone' ? 'phone' : 'email'}',
    );
  }

  Future<void> _verifyOtpAndRegister() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, accept any 6-digit OTP
    if (_otpController.text.length == 6) {
      _showSuccessSnackBar(
        'Registration successful! Welcome to JaMas Recyclers.',
      );
      // Navigate to home or login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(), // Replace with actual home page
        ),
      );
    } else {
      _showErrorSnackBar('Invalid OTP. Please try again.');
    }
  }

  void _resendOtp() {
    setState(() {
      _otpCountdown = 60;
    });
    _startCountdown();
    _sendOtp();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _otpCountdown--;
        });
        return _otpCountdown > 0;
      }
      return false;
    });
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
}
