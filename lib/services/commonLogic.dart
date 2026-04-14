bool isValidEmail(String email) {
  return RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$',
  ).hasMatch(email);
}
