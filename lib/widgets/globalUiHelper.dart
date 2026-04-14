import 'package:flutter/material.dart';

class UiHelper {
  // 🔹 TextField
  static Widget textField({
    Color filterColor=Colors.white,
    required String label,
    required Icon icon,
    bool isPassword = false,
    TextEditingController? controller,
    Color prefixIconColor=Colors.black,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(
        color: Colors.white, // typed text color
      ),
      decoration: InputDecoration(
        hintText: label,

        // ✅ Correct icon usage
        prefixIcon: icon,

        // ✅ Modern look
        filled: true,
        fillColor: filterColor,

        // ✅ Normal border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        // ✅ Focus border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 1,
          ),
        ),

        // ✅ Error border (future use)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),

        // ✅ Icon color
        prefixIconColor: prefixIconColor,
      ),
    );

  }

  // 🔹 Elevated Button
  static Widget elevatedButton({
    required String text,
    required VoidCallback onPressed,
    Color Color=Colors.white,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(text),
    );
  }

  // 🔹 Text Button
  static Widget textButton({
    required String text,
    required VoidCallback onPressed,
    Color color=Colors.red,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text,style: TextStyle(color: color),),
    );
  }

  static void showToast({
    required BuildContext context,
    required String text,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(color: textColor),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


}
