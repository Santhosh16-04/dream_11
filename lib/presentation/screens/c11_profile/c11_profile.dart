import 'package:flutter/material.dart';
import 'package:clever_11/presentation/screens/verify_address_sheet.dart';
import 'package:clever_11/presentation/screens/verify_bank_account_screen.dart';
import 'package:clever_11/presentation/screens/verify_pan_card_screen.dart';
import 'package:clever_11/presentation/widgets/network_image_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';

class M11_ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> personalData;
  const M11_ProfileScreen({Key? key, required this.personalData})
      : super(key: key);
 
  @override
  State<M11_ProfileScreen> createState() => _M11_ProfileScreenState();
}

class _M11_ProfileScreenState extends State<M11_ProfileScreen> {
  late Map<String, dynamic> personalData;
  Map<String, dynamic> verification = {};

  @override
  void initState() {
    super.initState();
    personalData = Map<String, dynamic>.from(widget.personalData);
    _loadVerificationStatus(personalData).then((data) {
      setState(() {
        personalData = data;
        verification = data['verification'] ?? {};
      });
    });
  }

  Future<Map<String, dynamic>> _loadVerificationStatus(
      Map<String, dynamic> personalData) async {
    final prefs = await SharedPreferences.getInstance();
    final verification = personalData['verification'] ?? {};
    verification['email'] = prefs.getBool('email_verified') ?? false;
    verification['mobile'] = prefs.getBool('mobile_verified') ?? false;
    verification['pan_status'] = prefs.getString('pan_status');
    verification['pan'] = (prefs.getString('pan_status') == 'verified');
    verification['pan_number'] = prefs.getString('pan_number');
    verification['pan_name'] = prefs.getString('pan_name');
    verification['pan_dob'] = prefs.getString('pan_dob');
    verification['pan_state'] = prefs.getString('pan_state');
    verification['pan_image_path'] = prefs.getString('pan_image_path');
    verification['bank_status'] = prefs.getString('bank_status');
    verification['bank'] = (prefs.getString('bank_status') == 'verified');
    verification['bank_account_number'] =
        prefs.getString('bank_account_number');
    verification['bank_re_account_number'] =
        prefs.getString('bank_re_account_number');
    verification['bank_name'] = prefs.getString('bank_name');
    verification['bank_ifsc'] = prefs.getString('bank_ifsc');
    verification['bank_bank_name'] = prefs.getString('bank_bank_name');
    verification['bank_branch_name'] = prefs.getString('bank_branch_name');
    verification['bank_image_path'] = prefs.getString('bank_image_path');
    verification['address_verified'] =
        prefs.getBool('address_verified') ?? false;
    verification['address'] = prefs.getString('address');
    verification['address_line1'] = prefs.getString('address_line1');
    verification['address_line2'] = prefs.getString('address_line2');
    verification['address_city'] = prefs.getString('address_city');
    verification['address_state'] = prefs.getString('address_state');
    verification['address_pincode'] = prefs.getString('address_pincode');
    verification['verified_email'] = prefs.getString('verified_email');
    verification['aadhaar_status'] = prefs.getString('aadhaar_status');
    verification['aadhaar_name'] = prefs.getString('aadhaar_name');
    verification['aadhaar_number'] = prefs.getString('aadhaar_number');
    verification['aadhaar_dob'] = prefs.getString('aadhaar_dob');
    verification['aadhaar_image_path'] = prefs.getString('aadhaar_image_path');
    personalData['verification'] = verification;
    return personalData;
  }

  void _refreshVerification() async {
    final data = await _loadVerificationStatus(personalData);
    setState(() {
      personalData = data;
      verification = data['verification'] ?? {};
    });
  }

  void _showEmailVerificationSheet() {
    final initialEmail =
        verification['verified_email'] ?? personalData['email'] ?? '';
    TextEditingController emailController =
        TextEditingController(text: initialEmail);
    bool isVerified = verification['email'] == true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isEmailValid = true;
            bool isLoading = false;
            void verifyEmail() async {
              final email = emailController.text;
              if (email.isEmpty ||
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(email)) {
                setModalState(() {
                  isEmailValid = false;
                });
                return;
              }
              setModalState(() {
                isLoading = true;
              });
              await Future.delayed(Duration(seconds: 2)); // Simulate API
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('email_verified', true);
              await prefs.setString('verified_email', email);
              setModalState(() {
                isLoading = false;
              });
              Navigator.of(context).pop();
              _refreshVerification();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Email verified successfully!'),
                    backgroundColor: Colors.green),
              );
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
                      Text('Email Verification',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.grey[700]),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    enabled: !isVerified,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: isEmailValid ? null : 'Enter a valid email',
                    ),
                  ),
                  SizedBox(height: 16),
                  if (!isVerified)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : verifyEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF003FB4),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Text('Tap here to verify',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  else
                    Center(
                      child: Text('Verified',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPanVerificationSheet() async {
    final panNumber = verification['pan_number'] ?? '';
    final panName = verification['pan_name'] ?? '';
    final panDob = verification['pan_dob'];
    final panState = verification['pan_state'];
    final panImagePath = verification['pan_image_path'];
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
        child: PanCardVerificationSheet(
          initialPanNumber: panNumber,
          initialName: panName,
          initialDob: panDob,
          initialState: panState,
          initialImagePath: panImagePath,
        ),
      ),
    );
    if (result is Map &&
        result['panNumber'] != null &&
        result['panStatus'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pan_number', result['panNumber']);
      await prefs.setString('pan_status', result['panStatus']);
      _refreshVerification();
    }
  }

  void _showBankVerificationSheet() async {
    final accountNumber = verification['bank_account_number'] ?? '';
    final reAccountNumber = verification['bank_re_account_number'] ?? '';
    final bankName = verification['bank_name'] ?? '';
    final ifsc = verification['bank_ifsc'] ?? '';
    final bankBankName = verification['bank_bank_name'] ?? '';
    final branchName = verification['bank_branch_name'] ?? '';
    final bankImagePath = verification['bank_image_path'] ?? '';
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
        child: BankAccountVerificationSheet(
          initialAccountNumber: accountNumber,
          initialReAccountNumber: reAccountNumber,
          initialName: bankName,
          initialIfsc: ifsc,
          initialBankName: bankBankName,
          initialBranchName: branchName,
          initialImagePath: bankImagePath,
        ),
      ),
    );
    if (result is Map &&
        result['accountNumber'] != null &&
        result['bankStatus'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bank_account_number', result['accountNumber']);
      await prefs.setString('bank_status', result['bankStatus']);
      _refreshVerification();
    }
  }

  void _showAddressVerificationSheet() async {
    final addressLine1 = verification['address_line1'];
    final addressLine2 = verification['address_line2'];
    final city = verification['address_city'];
    final state = verification['address_state'];
    final pincode = verification['address_pincode'];
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
        child: AddressVerificationSheet(
          initialAddressLine1: addressLine1,
          initialAddressLine2: addressLine2,
          initialCity: city,
          initialState: state,
          initialPincode: pincode,
        ),
      ),
    );
    if (result is Map && result['address'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('address', result['address']);
      await prefs.setBool('address_verified', true);
      _refreshVerification();
    }
  }

  void _showAadhaarVerificationSheet() async {
    final aadhaarName = verification['aadhaar_name'] ?? '';
    final aadhaarNumber = verification['aadhaar_number'] ?? '';
    final aadhaarDob = verification['aadhaar_dob'];
    final aadhaarImagePath = verification['aadhaar_image_path'];
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AadhaarVerificationSheet(
        initialName: aadhaarName,
        initialNumber: aadhaarNumber,
        initialDob: aadhaarDob,
        initialImagePath: aadhaarImagePath,
      ),
    );
    if (result == 'under_process') {
      _refreshVerification();
    }
  }

  String _getNextVerificationPrompt(Map<String, dynamic> verification) {
    if (verification['email'] != true) {
      return 'Please verify your Email.';
    } else if (verification['pan_status'] == 'under_process' ||
        verification['pan'] != true) {
      return 'Please verify your PAN Card.';
    } else if (verification['bank_status'] == 'under_process' ||
        verification['bank'] != true) {
      return 'Please verify your Bank Account.';
    } else if (verification['address_verified'] != true) {
      return 'Please verify your Address.';
    } else {
      return 'All verifications completed!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadVerificationStatus(Map<String, dynamic>.from(personalData)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!;
        final verification = data['verification'] ?? {};
        final playingExp = data['playing_experience'] ?? {};
        final levelTasks = data['level_tasks'] as List<dynamic>? ?? [];
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              color: Color(0xFF003FB4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Back arrow (left), edit icon (right)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 24, left: 8, right: 8, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Blue background with avatar
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: personalData['profile_image'] != null
                                  ? NetworkImageWithLoader(
                                      imageUrl: personalData['profile_image'],
                                      width: 96,
                                      height: 96,
                                      backgroundColor: Colors.white,
                                    )
                                  : Container(
                                      width: 96,
                                      height: 96,
                                      color: Colors.white,
                                      child: Icon(Icons.person,
                                          size: 48, color: Colors.grey),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right:
                                MediaQuery.of(context).size.width / 2 - 48 - 16,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.camera_alt,
                                  size: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            personalData['masked_phone'] ?? '',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              minimumSize: Size(0, 32),
                            ),
                            onPressed: () {},
                            child: Text('UPDATE',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // White rounded container for the rest
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Level Card
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'Level ${personalData['level'] ?? 1}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF003FB4))),
                                      Text(
                                          'Level ${personalData['next_level'] ?? 2}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600])),
                                      Icon(Icons.info_outline,
                                          color: Color(0xFF003FB4)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text('Complete the following tasks.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  ...levelTasks.map((task) => Row(
                                        children: [
                                          Icon(Icons.circle,
                                              size: 10,
                                              color: task['done']
                                                  ? Colors.green
                                                  : Colors.grey),
                                          SizedBox(width: 8),
                                          Expanded(
                                              child: Text(task['task'],
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey[800]))),
                                        ],
                                      )),
                                  SizedBox(height: 8),
                                  Text(
                                      'Unlock On Level ${personalData['unlock_on_level'] ?? ''}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      Icon(Icons.lock,
                                          size: 18, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(personalData['unlock_bonus'] ?? '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Profile Verification
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Profile Verification',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700])),
                              SizedBox(height: 8),
                              Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildVerifyIcon(
                                          'MOBILE',
                                          Icons.phone,
                                          verification['mobile'] == true
                                              ? 'verified'
                                              : 'not_started'),
                                      GestureDetector(
                                        onTap: () =>
                                            _showEmailVerificationSheet(),
                                        child: _buildVerifyIcon(
                                            'EMAIL',
                                            Icons.email,
                                            verification['email'] == true
                                                ? 'verified'
                                                : 'not_started'),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            _showAadhaarVerificationSheet(),
                                        child: _buildVerifyIcon(
                                            'AADHAAR',
                                            Icons.person,
                                            verification['aadhaar_status'] ==
                                                    'under_process'
                                                ? 'under_process'
                                                : (verification[
                                                            'aadhaar_status'] ==
                                                        'verified'
                                                    ? 'verified'
                                                    : 'not_started')),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            _showPanVerificationSheet(),
                                        child: _buildVerifyIcon(
                                            'PAN',
                                            Icons.credit_card,
                                            verification['pan_status'] ==
                                                    'under_process'
                                                ? 'under_process'
                                                : (verification['pan'] == true
                                                    ? 'verified'
                                                    : 'not_started')),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            _showBankVerificationSheet(),
                                        child: _buildVerifyIcon(
                                            'BANK',
                                            Icons.account_balance,
                                            verification['bank_status'] ==
                                                    'under_process'
                                                ? 'under_process'
                                                : (verification['bank'] == true
                                                    ? 'verified'
                                                    : 'not_started')),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            _showAddressVerificationSheet(),
                                        child: _buildVerifyIcon(
                                            'ADDRESS',
                                            Icons.location_on,
                                            verification['address_verified'] ==
                                                    true
                                                ? 'verified'
                                                : 'not_started'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Visibility(
                                visible: false,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getNextVerificationPrompt(
                                            verification),
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          '/verify_account',
                                          arguments: {
                                            'email':
                                                personalData['email'] ?? '',
                                            'mobile':
                                                personalData['phone'] ?? '',
                                            'emailVerified':
                                                verification['email'] == true,
                                            'mobileVerified':
                                                verification['mobile'] == true,
                                            'panVerified':
                                                verification['pan'] == true,
                                            'bankVerified':
                                                verification['bank'] == true,
                                            'addressVerified': verification[
                                                    'address_verified'] ==
                                                true,
                                          },
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Color(0xFF003FB4),
                                        side: BorderSide(
                                            color: Color(0xFF003FB4)!),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 0),
                                        minimumSize: Size(0, 32),
                                      ),
                                      child: Text('UPDATE',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Playing Experience
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Playing Experience',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700])),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildExpCard(
                                      'Contests Win',
                                      playingExp['contests_win'] ?? 0,
                                      Icons.emoji_events,
                                      Colors.blue[100]!),
                                  SizedBox(width: 8),
                                  _buildExpCard(
                                      'Total Contests',
                                      playingExp['total_contests'] ?? 0,
                                      Icons.stars,
                                      Colors.orange[100]!),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildExpCard(
                                      'Matches',
                                      playingExp['matches'] ?? 0,
                                      Icons.sports_cricket,
                                      Colors.pink[100]!),
                                  SizedBox(width: 8),
                                  _buildExpCard(
                                      'Series',
                                      playingExp['series'] ?? 0,
                                      Icons.emoji_events_outlined,
                                      Colors.cyan[100]!),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Leaderboard Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xFF003FB4),
                                side: BorderSide(color: Color(0xFF003FB4)!),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 0),
                                minimumSize: Size(0, 40),
                              ),
                              child: Text('Leaderboard',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        // Profile Info
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Profile Info',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700])),
                              SizedBox(height: 8),
                              Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text('Name',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey[600]))),
                                          Expanded(
                                              child: Text(
                                                  personalData['name'] ?? '',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text('Email',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey[600]))),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                        personalData['email'] ??
                                                            '',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                                Icon(Icons.edit,
                                                    size: 16,
                                                    color: Color(0xFF003FB4)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text('Team Name',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey[600]))),
                                          Expanded(
                                              child: Text(
                                                  personalData['team_name'] ??
                                                      '',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text('Phone',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey[600]))),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                        personalData['phone'] ??
                                                            '',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                                Icon(Icons.edit,
                                                    size: 16,
                                                    color: Color(0xFF003FB4)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Logout Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF003FB4),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text('Logout',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text('Logout from all device',
                                    style: TextStyle(
                                        color: Color(0xFF003FB4),
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerifyIcon(String label, IconData icon, String status) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: status == 'verified'
                  ? Colors.green[100]
                  : (status == 'under_process'
                      ? Colors.orange[50]
                      : Colors.grey[200]),
              child: Icon(
                icon,
                color: status == 'verified'
                    ? Colors.green
                    : (status == 'under_process' ? Colors.orange : Colors.grey),
                size: 20,
              ),
            ),
            if (status == 'under_process')
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 16),
              ),
            if (status == 'verified')
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.check_circle, color: Colors.green, size: 16),
              ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: status == 'verified'
                ? Colors.green
                : (status == 'under_process'
                    ? Colors.orange
                    : Colors.grey[600]),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpCard(String label, int count, IconData icon, Color bgColor) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 1,
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Color(0xFF003FB4)),
              SizedBox(height: 6),
              Text('$count',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 2),
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[800])),
            ],
          ),
        ),
      ),
    );
  }
}

class AadhaarVerificationSheet extends StatefulWidget {
  final String? initialName;
  final String? initialNumber;
  final String? initialDob;
  final String? initialImagePath;
  const AadhaarVerificationSheet(
      {Key? key,
      this.initialName,
      this.initialNumber,
      this.initialDob,
      this.initialImagePath})
      : super(key: key);

  @override
  State<AadhaarVerificationSheet> createState() =>
      _AadhaarVerificationSheetState();
}

class _AadhaarVerificationSheetState extends State<AadhaarVerificationSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadhaarNumberController =
      TextEditingController();
  DateTime? _selectedDate;
  File? _aadhaarImage;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) _nameController.text = widget.initialName!;
    if (widget.initialNumber != null)
      _aadhaarNumberController.text = widget.initialNumber!;
    if (widget.initialDob != null)
      _selectedDate = DateTime.tryParse(widget.initialDob!);
    if (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty)
      _aadhaarImage = File(widget.initialImagePath!);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    FocusScope.of(context).unfocus();
  }

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _aadhaarImage = File(image.path);
      });
    }
  }

  void _showFullImage() {
    if (_aadhaarImage == null) return;
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(0),
        child: Stack(
          children: [
            PhotoView(
              imageProvider: FileImage(_aadhaarImage!),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3.0,
            ),
            Positioned(
              top: 30,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSheet() {
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
              Container(
                width: 160,
                height: 160,
                child: Icon(Icons.check_circle, color: Colors.green, size: 120),
              ),
              Text(
                'Aadhaar Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Thank you! Your Aadhaar details have been submitted for verification.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                    'Go Back',
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
    ).then((_) async {
      // After success, set aadhaar_status to 'under_process' and save all fields
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aadhaar_status', 'under_process');
      await prefs.setString('aadhaar_name', _nameController.text.trim());
      await prefs.setString(
          'aadhaar_number', _aadhaarNumberController.text.trim());
      if (_selectedDate != null)
        await prefs.setString('aadhaar_dob', _selectedDate!.toIso8601String());
      if (_aadhaarImage != null)
        await prefs.setString('aadhaar_image_path', _aadhaarImage!.path);
      if (mounted) Navigator.of(context).pop('under_process');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Aadhaar KYC',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000)),
              ),
              const SizedBox(height: 4),
              Text(
                'Verify your Aadhaar to complete KYC',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name (as per Aadhaar)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aadhaarNumberController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Aadhaar number';
                  }
                  if (!RegExp(r'^\d{12}').hasMatch(value)) {
                    return 'Aadhaar number must be exactly 12 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Upload Aadhar Card',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _aadhaarImage == null ? _pickImage : null,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(16),
                        dashPattern: const [8, 4],
                        color: Color(0xFFCCCCCC),
                        strokeWidth: 2,
                        child: Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _aadhaarImage == null
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload_file,
                                          size: 48, color: Color(0xFFCCCCCC)),
                                      SizedBox(height: 8),
                                      Text('Upload Document (jpg,png,jpeg)',
                                          style: TextStyle(
                                              color: Color(0xFFCCCCCC))),
                                    ],
                                  ),
                                )
                              : GestureDetector(
                                  onTap: _showFullImage,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      _aadhaarImage!,
                                      width: double.infinity,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (_aadhaarImage != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _aadhaarImage = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.clear,
                                size: 22, color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                      hintText: 'Select your date of birth',
                    ),
                    controller: TextEditingController(
                      text: _selectedDate == null
                          ? ''
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                    validator: (value) {
                      if (_selectedDate == null) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState!.validate() &&
                        _aadhaarImage != null) {
                      _showSuccessSheet();
                    } else if (_aadhaarImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please upload your Aadhaar image.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003FB4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Tap here to verify',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
