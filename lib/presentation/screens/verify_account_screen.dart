import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'verify_pan_card_screen.dart';
import 'verify_bank_account_screen.dart';
import 'verify_address_sheet.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String email;
  final String mobile;
  final bool emailVerified;
  final bool mobileVerified;
  final bool panVerified;
  final bool bankVerified;
  final bool addressVerified;

  const VerifyAccountScreen({
    Key? key,
    required this.email,
    required this.mobile,
    this.emailVerified = false,
    this.mobileVerified = false,
    this.panVerified = false,
    this.bankVerified = false,
    this.addressVerified = false,
  }) : super(key: key);

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  late TextEditingController _emailController;
  bool _isEmailValid = true;

  // Remove local state for verification, always load from SharedPreferences

  SuperTooltip? _panTooltip;
  final _controller = SuperTooltipController();
  final _bankTooltipController = SuperTooltipController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _controller.hideTooltip();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email_verified': prefs.getBool('email_verified') ?? false,
      'mobile_verified': prefs.getBool('mobile_verified') ?? false,
      'pan_number': prefs.getString('pan_number'),
      'pan_status': prefs.getString('pan_status'),
      'bank_account_number': prefs.getString('bank_account_number'),
      'bank_status': prefs.getString('bank_status'),
      'address': prefs.getString('address'),
      'address_verified': prefs.getBool('address_verified') ?? false,
      'verified_email': prefs.getString('verified_email'),
    };
  }

  // Email validation regex
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _isEmailValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email address cannot be empty'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (!_isValidEmail(email)) {
        _isEmailValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _isEmailValid = true;
        // Show bottom sheet for valid email
        _showEmailOtpSheet();
      }
    });
  }

  void _showEmailOtpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final List<TextEditingController> otpControllers =
            List.generate(6, (_) => TextEditingController());
        final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
        bool isOtpLoading = false;
        bool hasRequestedFocus = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isOtpFilled = otpControllers.every((c) => c.text.length == 1);

            // Only request focus for the first field once
            if (!hasRequestedFocus) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (focusNodes[0].canRequestFocus) {
                  focusNodes[0].requestFocus();
                }
              });
              hasRequestedFocus = true;
            }

            void handleVerify() async {
              FocusScope.of(context).unfocus();
              String otp = otpControllers.map((c) => c.text).join();
              if (otp.length == 6 && otp == '123456' && !isOtpLoading) {
                setModalState(() => isOtpLoading = true);
                await Future.delayed(Duration(seconds: 2));
                setModalState(() => isOtpLoading = false);
                Navigator.of(context).pop();
                _showSuccessBottomSheet();
              } else if (otp.length == 6 && otp != '123456') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid OTP. Please try again.')),
                );
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter the 6-digit OTP')),
                );
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              }
            }

            void onOtpChanged(int idx, String value) {
              if (value.length == 1 && idx < 5) {
                focusNodes[idx + 1].requestFocus();
              } else if (value.isEmpty && idx > 0) {
                focusNodes[idx - 1].requestFocus();
              }
              setModalState(() {});
              if (otpControllers.every((c) => c.text.length == 1) &&
                  !isOtpLoading) {
                FocusScope.of(context).unfocus();
                handleVerify();
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Enter OTP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.grey[700]),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 14),
                            children: [
                              const TextSpan(
                                  text:
                                      'Enter the OTP sent on your email address at '),
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              TextSpan(
                                text: '  ',
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Text('Edit',
                                      style: TextStyle(
                                          color: Color(0xFF003FB4),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 45,
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 3.5),
                        decoration: BoxDecoration(
                          color: Color(0xFFEAF6FF),
                          border:
                              Border.all(color: Color(0xFFB6D6F6), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: TextField(
                            controller: otpControllers[index],
                            focusNode: focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                                counterText: '', border: InputBorder.none),
                            onChanged: (value) => onOtpChanged(index, value),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                      child: Text('OR', style: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 8),
                  const Text(
                    'Click on the Verification Link sent to you on your entered email address.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isOtpFilled && !isOtpLoading ? handleVerify : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF003FB4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isOtpLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('VERIFY',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessBottomSheet() {
    // Save email verification status
    _saveEmailVerificationStatus(true);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) { 
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 160,
                height: 160,
                /*  decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ), */
                child: Lottie.asset(
                  'assets/lottie/success.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Email Verified Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              // Congratulations Message
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  'Congratulations! Your email is successfully verified. Get ready for exclusive offers and updates!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),

              // Ok, Got it Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // You can add additional navigation logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003FB4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Ok, Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveEmailVerificationStatus(bool verified) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_verified', verified);
    if (verified) {
      // Save the verified email address
      await prefs.setString('verified_email', _emailController.text);
    }
    setState(() {}); // Refresh UI
  }

  Widget _buildVerifyContainer({
    required String label,
    required String value,
    required String status, // 'verified', 'under_process', 'not_started'
    required VoidCallback? onVerify,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    label == 'Email Address'
                        ? TextField(
                            controller: _emailController,
                            enabled: status != 'verified',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: status == 'verified'
                                  ? Colors.green[700]
                                  : (_isEmailValid ? Colors.black : Colors.red),
                            ),
                            decoration: InputDecoration(
                              hintText: status == 'verified'
                                  ? 'Email verified'
                                  : 'Enter email address',
                              hintStyle: TextStyle(
                                color: status == 'verified'
                                    ? Colors.green[600]
                                    : Colors.grey[400],
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              if (status != 'verified') {
                                setState(() {
                                  _isEmailValid = true;
                                });
                              }
                            },
                            onSubmitted: (value) {
                              if (status != 'verified') {
                                _validateEmail(value);
                              }
                            },
                          )
                        : Text(value.isNotEmpty ? value : '-',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              if (status == 'verified')
                Icon(Icons.check_circle, color: Colors.green, size: 28)
              else if (status == 'under_process')
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28)
              else
                InkWell(
                  onTap: onVerify,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF003FB4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 4, bottom: 4),
                      child: const Text(
                        'VERIFY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF003FB4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Verify Your Account',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadVerificationStatus(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final status = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildVerifyContainer(
                    label: 'Email Address',
                    value: status['verified_email'] ?? widget.email,
                    status: status['email_verified'] == true ? 'verified' : 'not_started',
                    onVerify: () => _validateEmail(_emailController.text),
                  ),
                  _buildVerifyContainer(
                    label: 'Mobile Number',
                    value: widget.mobile,
                    status: status['mobile_verified'] == true ? 'verified' : 'not_started',
                    onVerify: () {},
                  ),
                  // PAN Card section
                  _buildVerifyContainer(
                    label: 'Pan Card',
                    value: status['pan_number'] ?? '-',
                    status: status['pan_status'] == 'under_process'
                        ? 'under_process'
                        : (status['pan_status'] == 'verified' ? 'verified' : 'not_started'),
                    onVerify: status['pan_status'] == 'under_process'
                        ? null
                        : () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: PanCardVerificationSheet(),
                              ),
                            );
                            if (result is Map &&
                                result['panNumber'] != null &&
                                result['panStatus'] != null) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('pan_number', result['panNumber']);
                              await prefs.setString('pan_status', result['panStatus']);
                              setState(() {}); // reload status
                            }
                          },
                  ),
                  // Bank Account section
                  _buildVerifyContainer(
                    label: 'Bank Account',
                    value: status['bank_account_number'] ?? '-',
                    status: status['bank_status'] == 'under_process'
                        ? 'under_process'
                        : (status['bank_status'] == 'verified' ? 'verified' : 'not_started'),
                    onVerify: status['bank_status'] == 'under_process'
                        ? null
                        : () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: BankAccountVerificationSheet(),
                              ),
                            );
                            if (result is Map &&
                                result['accountNumber'] != null &&
                                result['bankStatus'] != null) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('bank_account_number', result['accountNumber']);
                              await prefs.setString('bank_status', result['bankStatus']);
                              setState(() {}); // reload status
                            }
                          },
                  ),
                  // Address section
                  _buildVerifyContainer(
                    label: 'Address',
                    value: status['address'] ?? '-',
                    status: status['address_verified'] == true ? 'verified' : 'not_started',
                    onVerify: status['address_verified'] == true
                        ? null
                        : () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: AddressVerificationSheet(),
                              ),
                            );
                            if (result is Map && result['address'] != null) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('address', result['address']);
                              await prefs.setBool('address_verified', true);
                              setState(() {}); // reload status
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      children: [
                        Image.asset('assets/images/deal.png', height: 80),
                        const SizedBox(height: 12),
                        const Text(
                          'If you need any help regarding your account verification, feel free to contact our customer support for further assistance.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF003FB4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('CONTACT US'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
