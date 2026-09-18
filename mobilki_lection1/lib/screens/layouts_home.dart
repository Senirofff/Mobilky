import 'package:flutter/material.dart';

import 'course_screen.dart';
import 'meditate_screen.dart';
import 'wallet_screen.dart';
import 'welcome_screen.dart';

const kTeal = Color(0xFF00B7B3);

class LayoutsHome extends StatelessWidget {
  const LayoutsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Макеты проектов'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Легкие макеты'),
            const SizedBox(height: 12),
            _openButton(context, 'Meditate', 'Главный экран приложения медитаций', const MeditateScreen()),
            const SizedBox(height: 12),
            _openButton(context, 'Welcome', 'Экран входа / приветствия', const WelcomeScreen()),
            const SizedBox(height: 28),
            const _SectionTitle('Сложные макеты'),
            const SizedBox(height: 12),
            _openButton(context, '3D Design Basic', 'Детали курса перед покупкой', const CourseScreen()),
            const SizedBox(height: 12),
            _openButton(context, 'My E-Wallet', 'Кошелёк и история транзакций', const WalletScreen()),
          ],
        ),
      ),
    );
  }

  Widget _openButton(BuildContext context, String title, String subtitle, Widget screen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => screen),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF8A8FA3)),
    );
  }
}