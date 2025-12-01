import 'package:flutter/material.dart';

class EncryptionNotice extends StatelessWidget {
  const EncryptionNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 216, 203, 89).withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFFFD700).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock,
              size: 20,
              color: Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End-to-end encrypted',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B7355),
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  textAlign: TextAlign.center,
                  'Messages and calls are end-to-end encrypted. Only people in this chat can read, listen to, or share them.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B7355).withOpacity(0.8),
                    height: 1.3,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
