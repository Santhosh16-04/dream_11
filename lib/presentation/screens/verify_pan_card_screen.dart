import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanCardVerificationSheet extends StatefulWidget {
  final String? initialPanNumber;
  final String? initialName;
  final String? initialDob;
  final String? initialState;
  final String? initialImagePath;
  const PanCardVerificationSheet({Key? key, this.initialPanNumber, this.initialName, this.initialDob, this.initialState, this.initialImagePath}) : super(key: key);

  @override
  State<PanCardVerificationSheet> createState() => _PanCardVerificationSheetState();
}

class _PanCardVerificationSheetState extends State<PanCardVerificationSheet> {
  final TextEditingController panController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;
  String? selectedState;
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

  final List<String> states = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPanNumber != null) panController.text = widget.initialPanNumber!;
    if (widget.initialName != null) nameController.text = widget.initialName!;
    if (widget.initialDob != null) selectedDate = DateTime.tryParse(widget.initialDob!);
    if (widget.initialState != null) selectedState = widget.initialState!;
    if (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty) _pickedImage = File(widget.initialImagePath!);
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _pickState() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: [
          ...states.map((state) => ListTile(
                title: Text(state),
                onTap: () {
                  setState(() => selectedState = state);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
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
      error = "Please upload your PAN card image.";
    } else if (panController.text.trim().isEmpty) {
      error = "Please enter your PAN card number.";
    } else if (nameController.text.trim().isEmpty) {
      error = "Please enter the PAN card holder's name.";
    } else if (selectedDate == null) {
      error = "Please select your date of birth.";
    } else if (selectedState == null || selectedState!.isEmpty) {
      error = "Please select your state.";
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // Save all PAN fields to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pan_name', nameController.text.trim());
    await prefs.setString('pan_number', panController.text.trim());
    await prefs.setString('pan_dob', selectedDate!.toIso8601String());
    await prefs.setString('pan_state', selectedState!);
    if (_pickedImage != null) await prefs.setString('pan_image_path', _pickedImage!.path);

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
                'PAN Details Submitted!',
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
                      'panNumber': panController.text.trim(),
                      'panStatus': 'under_process',
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
          const Text("Enter Your PAN Card Details",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          const SizedBox(height: 16),
          const Text("Upload clear image of PAN Card",
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
                                      text: " to upload your PAN Card Image",
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
          const SizedBox(height: 24),
          const Text("Pan Card Number",
              style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: panController,
            decoration: const InputDecoration(
                hintText: "Enter your 10-digit PAN", counterText: ''),
            maxLength: 10,
          ),
          const SizedBox(height: 16),
          const Text("PAN Card Holder’s Name",
              style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Enter Name on PAN Card",
            ),
          ),
          const SizedBox(height: 16),
          const Text("Date Of Birth",
              style: TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: selectedDate != null
                            ? "${selectedDate!.day.toString().padLeft(2, '0')}"
                            : "Day",
                      ),
                      enabled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text("/", style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: selectedDate != null
                            ? "${selectedDate!.month.toString().padLeft(2, '0')}"
                            : "Month",
                      ),
                      enabled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text("/", style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: selectedDate != null
                            ? "${selectedDate!.year}"
                            : "Year",
                      ),
                      enabled: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("State", style: TextStyle(fontWeight: FontWeight.w500)),
          GestureDetector(
            onTap: _pickState,
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  hintText: selectedState ?? "Select State",
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                enabled: false,
              ),
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
