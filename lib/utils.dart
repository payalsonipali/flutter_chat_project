bool isEmailValid(String email) {
  // Define a regular expression pattern for email validation
  final pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';

  // Create a RegExp object using the pattern
  final regExp = RegExp(pattern);

  // Use the hasMatch method to check if the email matches the pattern
  return regExp.hasMatch(email);
}


String? isPasswordValid(String? value){
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  bool hasNumber = RegExp(r'[0-9]').hasMatch(value);

  if(!hasNumber){
    return 'Password must have one number';
  }

  bool hasSpecialChar = RegExp(r'[!@#\$&*~%^,]').hasMatch(value);

  if(!hasSpecialChar){
    return 'Password must have one special character';
  }

  return null;
}