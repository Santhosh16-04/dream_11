import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:clever_11/routes/m11_routes.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class M11_RegistrationScreen extends StatefulWidget {
  const M11_RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<M11_RegistrationScreen> createState() => _M11_RegistrationScreenState();
}

class _M11_RegistrationScreenState extends State<M11_RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadhaarNumberController =
      TextEditingController();
  DateTime? _selectedDate;
  File? _aadhaarImage;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // current date
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // prevent future dates
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/m1_whole_background_blue.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Form(
                  key: _formKey,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Complete Your KYC',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verify your identity to start playing fantasy sports',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLength: 12,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Aadhaar number';
                                      }
                                      if (!RegExp(r'^\d{12}$')
                                          .hasMatch(value)) {
                                        return 'Aadhaar number must be exactly 12 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Upload Aadhar Card',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: _aadhaarImage == null
                                              ? _pickImage
                                              : null,
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
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: _aadhaarImage == null
                                                  ? const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              Icons.upload_file,
                                                              size: 48,
                                                              color: Color(
                                                                  0xFFCCCCCC)),
                                                          SizedBox(height: 8),
                                                          Text(
                                                              'Upload Document (jpg,png,jpeg)',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFCCCCCC))),
                                                        ],
                                                      ),
                                                    )
                                                  : GestureDetector(
                                                      onTap: _showFullImage,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                        child: Image.file(
                                                          _aadhaarImage!,
                                                          width:
                                                              double.infinity,
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
                                                    size: 22,
                                                    color: Colors.red),
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
                                          suffixIcon:
                                              Icon(Icons.calendar_today),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if (_nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Please enter your name.')),
                                );
                              } else if (_formKey.currentState!.validate() &&
                                  _aadhaarImage != null) {
                                // Save Aadhaar details to SharedPreferences
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('aadhaar_status', 'under_process');
                                await prefs.setString('aadhaar_name', _nameController.text.trim());
                                await prefs.setString('aadhaar_number', _aadhaarNumberController.text.trim());
                                if (_selectedDate != null) {
                                  await prefs.setString('aadhaar_dob', _selectedDate!.toIso8601String());
                                }
                                if (_aadhaarImage != null) {
                                  await prefs.setString('aadhaar_image_path', _aadhaarImage!.path);
                                }
                                await prefs.setString("loginStatus", "success");

                                Navigator.pushReplacementNamed(
                                    context, M11_AppRoutes.m11_home);
                              } else if (_aadhaarImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please upload your Aadhaar image.')),
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
                              'Continue',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
