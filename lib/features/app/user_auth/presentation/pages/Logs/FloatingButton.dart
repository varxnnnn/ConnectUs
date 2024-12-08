import 'package:flutter/material.dart';
import 'AdminLoginPage.dart';

class FloatingAdminButton extends StatelessWidget {
  static Color secondaryColor = Color(0xFF0D6EC5);

  const FloatingAdminButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Section for "Login as Admin"
        FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginPage()),
            );
          },
          backgroundColor: secondaryColor,
          icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
          label: const Text(
            "Login as Admin",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
