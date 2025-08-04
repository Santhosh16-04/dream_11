import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BankAccountVerificationSheet extends StatefulWidget {
  final String? initialAccountNumber;
  final String? initialReAccountNumber;
  final String? initialName;
  final String? initialIfsc;
  final String? initialBankName;
  final String? initialBranchName;
  final String? initialImagePath;
  const BankAccountVerificationSheet({Key? key, this.initialAccountNumber, this.initialReAccountNumber, this.initialName, this.initialIfsc, this.initialBankName, this.initialBranchName, this.initialImagePath}) : super(key: key);

  @override
  State<BankAccountVerificationSheet> createState() => _BankAccountVerificationSheetState();
}

class _BankAccountVerificationSheetState extends State<BankAccountVerificationSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController reAccountController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  String? get _pickedFileName {
    if (_pickedImage == null) return null;
    return _pickedImage!.path.split('/').last;
  }

  String? get _pickedFileSize {
    if (_pickedImage == null) return null;
    final bytes = _pickedImage!.lengthSync();
    final kb = bytes / 1024;
    return "${kb.toStringAsFixed(2)} KB";
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialAccountNumber != null) accountController.text = widget.initialAccountNumber!;
    if (widget.initialReAccountNumber != null) reAccountController.text = widget.initialReAccountNumber!;
    if (widget.initialName != null) nameController.text = widget.initialName!;
    if (widget.initialIfsc != null) ifscController.text = widget.initialIfsc!;
    if (widget.initialBankName != null) bankNameController.text = widget.initialBankName!;
    if (widget.initialBranchName != null) branchNameController.text = widget.initialBranchName!;
    if (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty) _pickedImage = File(widget.initialImagePath!);
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF003FB4),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            SizedBox(height: 10),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF003FB4),
                child: const Icon(Icons.photo, color: Colors.white, size: 20),
              ),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  void _showFullImage() {
    if (_pickedImage == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: PhotoView(
                  imageProvider: FileImage(_pickedImage!),
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.clear, color: Colors.white, size: 26),
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
  }

  void _validateAndSubmit() async {
    String? error;
    if (_pickedImage == null) {
      error = "Please upload your bank account proof image.";
    } else if (nameController.text.trim().isEmpty) {
      error = "Please enter your full name.";
    } else if (accountController.text.trim().isEmpty) {
      error = "Please enter your bank account number.";
    } else if (reAccountController.text.trim().isEmpty) {
      error = "Please re-enter your bank account number.";
    } else if (accountController.text.trim() != reAccountController.text.trim()) {
      error = "Account numbers do not match.";
    } else if (ifscController.text.trim().isEmpty) {
      error = "Please enter IFSC code.";
    } else if (bankNameController.text.trim().isEmpty) {
      error = "Please enter your bank name.";
    } else if (branchNameController.text.trim().isEmpty) {
      error = "Please enter your branch name.";
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // Save all bank fields to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bank_name', nameController.text.trim());
    await prefs.setString('bank_account_number', accountController.text.trim());
    await prefs.setString('bank_re_account_number', reAccountController.text.trim());
    await prefs.setString('bank_ifsc', ifscController.text.trim());
    await prefs.setString('bank_bank_name', bankNameController.text.trim());
    await prefs.setString('bank_branch_name', branchNameController.text.trim());
    if (_pickedImage != null) await prefs.setString('bank_image_path', _pickedImage!.path);

    // All fields are valid, show success bottom sheet
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
                'Bank Details Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Thank you! Our team is reviewing your details.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close success sheet
                    Navigator.of(context).pop({
                      'accountNumber': accountController.text.trim(),
                      'bankStatus': 'under_process',
                    });
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const Text("Verify Your Bank Account",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          const SizedBox(height: 16),
          const Text("Upload Bank Account Proof",
              style: TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          DottedBorder(
            color: Colors.grey,
            strokeWidth: 1,
            dashPattern: [6, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(8),
            child: InkWell(
              onTap: _pickedImage == null
                  ? _showImageSourceDialog
                  : _showFullImage,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    alignment: Alignment.center,
                    child: _pickedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.credit_card,
                                size: 40,
                                color: const Color(0xFF003FB4),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "Tap here",
                                      style: TextStyle(
                                          color: const Color(0xFF003FB4),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    TextSpan(
                                      text: " to upload Bank Account Proof",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                // Image thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    _pickedImage!,
                                    width: 120,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 10),
                                // File info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _pickedFileName ?? '',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _pickedFileSize ?? '',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                // Delete icon
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _pickedImage = null);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We accept Passbook front page image, Online Bank account statement screenshot, Cancelled Cheque Image",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "First Name Last Name",
            ),
          ),
          const SizedBox(height: 16),
          const Text("Account Number", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: accountController,
            decoration: const InputDecoration(
              hintText: "Enter your bank account number",
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text("Re-Enter Account Number", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: reAccountController,
            decoration: const InputDecoration(
              hintText: "Confirm your bank account number",
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text("IFSC Code", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: ifscController,
            decoration: const InputDecoration(
              hintText: "Enter branch IFSC code (eg: ABCD0123456)",
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          const Text("Name of Your Bank", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: bankNameController,
            decoration: const InputDecoration(
              hintText: "Enter name of your bank (eg: ICICI Bank)",
            ),
          ),
          const SizedBox(height: 16),
          const Text("Name of Your Branch", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: branchNameController,
            decoration: const InputDecoration(
              hintText: "Enter branch name (eg: New Delhi, Main Branch)",
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003FB4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("TAP HERE TO VERIFY",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
} 