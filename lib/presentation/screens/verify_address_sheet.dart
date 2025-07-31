import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressVerificationSheet extends StatefulWidget {
  final String? initialAddressLine1;
  final String? initialAddressLine2;
  final String? initialCity;
  final String? initialState;
  final String? initialPincode;
  const AddressVerificationSheet({Key? key, this.initialAddressLine1, this.initialAddressLine2, this.initialCity, this.initialState, this.initialPincode}) : super(key: key);

  @override
  State<AddressVerificationSheet> createState() => _AddressVerificationSheetState();
}

class _AddressVerificationSheetState extends State<AddressVerificationSheet> {
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialAddressLine1 != null) addressLine1Controller.text = widget.initialAddressLine1!;
    if (widget.initialAddressLine2 != null) addressLine2Controller.text = widget.initialAddressLine2!;
    if (widget.initialCity != null) cityController.text = widget.initialCity!;
    if (widget.initialState != null) stateController.text = widget.initialState!;
    if (widget.initialPincode != null) pincodeController.text = widget.initialPincode!;
  }

  void _validateAndSubmit() async {
    String? error;
    if (addressLine1Controller.text.trim().isEmpty) {
      error = "Please enter Address Line 1.";
    } else if (cityController.text.trim().isEmpty) {
      error = "Please enter City.";
    } else if (stateController.text.trim().isEmpty) {
      error = "Please enter State.";
    } else if (pincodeController.text.trim().isEmpty) {
      error = "Please enter Pincode.";
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // Save all address fields to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('address_line1', addressLine1Controller.text.trim());
    await prefs.setString('address_line2', addressLine2Controller.text.trim());
    await prefs.setString('address_city', cityController.text.trim());
    await prefs.setString('address_state', stateController.text.trim());
    await prefs.setString('address_pincode', pincodeController.text.trim());
    // Set address_verified to true
    await prefs.setBool('address_verified', true);

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
              Container(
                width: 160,
                height: 160,
                child: Lottie.asset(
                  'assets/lottie/success.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Address Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Thank you! Your address has been submitted.",
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
                      'address': _getAddressSummary(),
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

  String _getAddressSummary() {
    return addressLine1Controller.text.trim() + ', ' +
        (addressLine2Controller.text.trim().isNotEmpty ? addressLine2Controller.text.trim() + ', ' : '') +
        cityController.text.trim() + ', ' +
        stateController.text.trim() + ' - ' +
        pincodeController.text.trim();
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
          const Text("Enter Your Address",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          const SizedBox(height: 16),
          const Text("Address Line 1", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: addressLine1Controller,
            decoration: const InputDecoration(
              hintText: "House No, Street, Area",
            ),
          ),
          const SizedBox(height: 16),
          const Text("Address Line 2", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: addressLine2Controller,
            decoration: const InputDecoration(
              hintText: "Landmark, Apartment, etc (optional)",
            ),
          ),
          const SizedBox(height: 16),
          const Text("City", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: cityController,
            decoration: const InputDecoration(
              hintText: "Enter your city",
            ),
          ),
          const SizedBox(height: 16),
          const Text("State", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: stateController,
            decoration: const InputDecoration(
              hintText: "Enter your state",
            ),
          ),
          const SizedBox(height: 16),
          const Text("Pincode", style: TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: pincodeController,
            decoration: const InputDecoration(
              hintText: "Enter pincode", 
              counterText: ''
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
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