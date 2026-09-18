import 'package:flutter/material.dart';

const kBlue = Color(0xFF2E5BFF);
const kSoftBg = Color(0xFFF5F7FA);
const kTextDark = Color(0xFF1A1F36);

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftBg,
      appBar: AppBar(
        backgroundColor: kSoftBg,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kTextDark),
          ),
        ),
        title: const Text(
          '3D Design Basic',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _HeroImage(),
          const SizedBox(height: 16),
          const _StatsRow(),
          const SizedBox(height: 18),
          const Text(
            '3D Design Basic',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kTextDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'In this course you will learn how to build a space to a 3-dimensional product. There are 24 premium learning videos for you.',
            style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF7A8094)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                '24 Lessons (20 hours)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('See all', style: TextStyle(fontSize: 13, color: kBlue)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const _LessonCard(),
          const SizedBox(height: 24),
          const _EnrollButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3D7BFF),
            Color(0xFF7A5CFF),
            Color(0xFFB455F0),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            right: 60,
            bottom: 30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ),
          const Center(
            child: Icon(Icons.view_in_ar_rounded, size: 72, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat(icon: Icons.person_outline_rounded, label: '4,569'),
        const SizedBox(width: 8),
        _stat(icon: Icons.star_rounded, label: '4.9', iconColor: const Color(0xFFFFB400)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: kBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Best Seller',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _stat({
    required IconData icon,
    required String label,
    Color iconColor = kBlue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kTextDark),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7A5CFF), Color(0xFFB455F0)],
              ),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Introduction to 3D',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kTextDark),
                ),
                SizedBox(height: 4),
                Text(
                  '20 mins',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A8094)),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: kBlue, size: 22),
        ],
      ),
    );
  }
}

class _EnrollButton extends StatelessWidget {
  const _EnrollButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: kBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Enroll - \$24.99',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}