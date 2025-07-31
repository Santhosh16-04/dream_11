class Validators {
  static bool isValidMobileNumberPattern(String mobileNumber) {
    if (mobileNumber.isEmpty) {
      return false;
    }
    final RegExp mobileRegex = RegExp(r'^[6-9][0-9]*$');
    return mobileRegex.hasMatch(mobileNumber);
  }
} 