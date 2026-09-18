import 'package:flutter/material.dart';

const kTeal = Color(0xFF00B7B3);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kTeal,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              'medinow',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Meditate With Us!',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  _socialButton(
                    color: Colors.white,
                    foreground: const Color(0xFF163239),
                    icon: Icons.apple,
                    label: 'Sign in with Apple',
                  ),
                  const SizedBox(height: 12),
                  _socialButton(
                    color: const Color(0xFFCFEFF5),
                    foreground: const Color(0xFF163239),
                    icon: Icons.email_outlined,
                    label: 'Continue with Email or Phone',
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Continue With Google',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 340,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 10,
                    left: 60,
                    right: 60,
                    child: Icon(Icons.self_improvement, size: 210, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 22,
                    left: 30,
                    child: Icon(Icons.eco, size: 56, color: Colors.white70),
                  ),
                  Positioned(
                    bottom: 32,
                    right: 34,
                    child: Icon(Icons.eco, size: 64, color: Colors.white70),
                  ),
                  Positioned(
                    bottom: 84,
                    left: 80,
                    child: Icon(Icons.eco, size: 40, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  Positioned(
                    top: 48,
                    right: 96,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kTeal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _socialButton({
    required Color color,
    required Color foreground,
    required IconData icon,
    required String label,
  }) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: foreground,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}