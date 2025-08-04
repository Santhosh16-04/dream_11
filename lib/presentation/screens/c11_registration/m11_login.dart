import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clever_11/routes/m11_routes.dart';
import 'dart:async';
import 'package:clever_11/utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class M11_LoginTeleportation extends StatefulWidget {
  final String? initialMobileNumber;
  final bool isEditMode;
  
  const M11_LoginTeleportation({
    super.key, 
    this.initialMobileNumber,
    this.isEditMode = false,
  });

  @override
  State<M11_LoginTeleportation> createState() => _M11_LoginTeleportationState();
}

class _M11_LoginTeleportationState extends State<M11_LoginTeleportation> {
  TextEditingController mobileNoEditController = TextEditingController();
  bool isOtpStep = false;
  List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool whatsappUpdates = false;
  bool is18Confirmed = false;
  bool isMobileLoading = false;
  bool isOtpLoading = false;
  int resendSeconds = 30;
  Timer? resendTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialMobileNumber != null) {
      mobileNoEditController.text = widget.initialMobileNumber!;
      // If in edit mode, auto-confirm 18+ age
      if (widget.isEditMode) {
        is18Confirmed = true;
      }
    }
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    super.dispose();
  }

  void startResendTimer() {
    resendTimer?.cancel();
    setState(() {
      resendSeconds = 30;
    });
    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          resendSeconds--;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant M11_LoginTeleportation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Not needed for this widget
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Not needed for this widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedPadding(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child:
                    isOtpStep ? _buildOtpContainer() : _buildMobileContainer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContainer() {
    void handleMobileSubmit() async {
      FocusScope.of(context).unfocus();
      if (mobileNoEditController.text.length == 10 &&
          Validators.isValidMobileNumberPattern(mobileNoEditController.text) &&
          is18Confirmed &&
          !isMobileLoading) {
        setState(() => isMobileLoading = true);
        await Future.delayed(Duration(seconds: 2));
        setState(() {
          isMobileLoading = false;
          isOtpStep = true;
        });
        startResendTimer();
      } else if (!is18Confirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please confirm that you are 18+ years old')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please enter a valid 10-digit mobile number')),
        );
      }
    }

    return Container(
      key: ValueKey('mobile'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: ShapeDecoration(
        color: Color(0xFFFEFEFE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('Login / Register',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFEAF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Color(0xFFB6D6F6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone, color: Color(0xFF6A90A8)),
                  SizedBox(width: 8),
                  Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: mobileNoEditController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Mobile Number',
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      onChanged: (value) {
                        if (value.length == 10 && !isMobileLoading) {
                          FocusScope.of(context).unfocus();
                      //    handleMobileSubmit();
                        }
                      },  
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Checkbox(
                  value: is18Confirmed,
                  onChanged: (val) {
                    setState(() => is18Confirmed = val ?? false);
                  },
                  activeColor: Color(0xFF0A57E3),
                ),
                Expanded(
                  child: Text(
                    'I confirm that I am 18+ years age',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isMobileLoading ? null : handleMobileSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF003FB4),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: isMobileLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text('Continue',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0,bottom: 12),
            child: Row(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        'Get updates on Whatsapp',
                        style: TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Transform.scale(
                          scale:
                              0.60, 
                          alignment: Alignment
                              .centerLeft,
                          child: Switch(
                            value: whatsappUpdates,
                            onChanged: (val) {
                              setState(() => whatsappUpdates = val);
                            },
                            activeColor: const Color(0xFF0A57E3),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle invite code tap
                  },
                  child: Text(
                    'Got invite code?',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF003FB4)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpContainer() {
      void handleOtpSubmit() async { 
        FocusScope.of(context).unfocus();
        String otp = otpControllers.map((c) => c.text).join();
        if (otp.length == 6 && otp == '123456' && !isOtpLoading) {
          setState(() => isOtpLoading = true);
          await Future.delayed(Duration(seconds: 2));
          setState(() => isOtpLoading = false);

          // Save mobile verification status and updated mobile number
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('mobile_verified', true);
          await prefs.setString('phone', mobileNoEditController.text);
          await prefs.setString('masked_phone', '+91 ${mobileNoEditController.text}');

          if (widget.isEditMode) {
            // If in edit mode, go back to profile screen
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mobile number updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // Normal flow - go to registration
            Navigator.pushReplacementNamed(context, M11_AppRoutes.m11_registration);
          }
        } else if (otp.length == 6 && otp != '123456') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid OTP. Please try again.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter the 6-digit OTP')),
          );
        }
      }

    return Container(
      key: ValueKey('otp'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: ShapeDecoration(
        color: Color(0xFFFEFEFE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text('Verify with OTP',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('OTP sent to +91 ${mobileNoEditController.text}',
                    style: TextStyle(fontSize: 15)),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isOtpStep = false;
                      otpControllers.forEach((c) => c.clear());
                    });
                  },
                  child: Text('Change',
                      style: TextStyle(
                          color: Color(0xFF003FB4), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:24.0,bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: 45,
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 3.5),
                  decoration: BoxDecoration(
                    color: Color(0xFFEAF6FF),
                    border: Border.all(color: Color(0xFFB6D6F6), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: TextField(
                      controller: otpControllers[index],
                      focusNode: otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          counterText: '', border: InputBorder.none),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
            
                        if (otpControllers.every((c) => c.text.length == 1)) {
                          FocusScope.of(context).unfocus();
                          handleOtpSubmit();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
          resendSeconds > 0
              ? Padding(
                padding: const EdgeInsets.only(top: 12.0,bottom: 8),
                child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: Colors.black),
                      children: [
                        TextSpan(text: 'Resend OTP in '),
                        TextSpan(
                          text: '${resendSeconds}s',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              )
              : GestureDetector(
                  onTap: () {
                    startResendTimer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0,bottom: 8),
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: Color(0xFF003FB4),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.only(top:8.0,bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isOtpLoading ? null : handleOtpSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF003FB4),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder( 
                      borderRadius: BorderRadius.circular(4)),
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
                    : Text('Verify',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'By Continuing you accept terms of service and privacy policy',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'ONLINE GAMING IS ADDICTIVE IN NATURE',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                fontSize: 13),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
