import 'package:flutter/material.dart';

const kTeal = Color(0xFF00B7B3);
const kYellow = Color(0xFFFFC954);
const kDarkBlue = Color(0xFF31406B);
const kTextDark = Color(0xFF141A2E);
const kGreyText = Color(0xFF8A8FA3);

class MeditateScreen extends StatelessWidget {
  const MeditateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text(
          'Meditate',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kTextDark),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.search_rounded, color: kTextDark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Filters(),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _BigCard(),
            ),
            SizedBox(height: 20),
            _MiniGrid(),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.home_rounded, color: kTeal, size: 26),
            Icon(Icons.grid_view_rounded, color: Color(0xFFB9BEC9), size: 26),
            Icon(Icons.favorite_rounded, color: Color(0xFFB9BEC9), size: 26),
            Icon(Icons.person_rounded, color: Color(0xFFB9BEC9), size: 26),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip('All', true),
          const SizedBox(width: 8),
          _chip('Bible in a Year', false),
          const SizedBox(width: 8),
          _chip('Dailies', false),
          const SizedBox(width: 8),
          _chip('Minutes', false),
          const SizedBox(width: 8),
          _chip('Novem', false),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: active ? kTeal : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? kTeal : const Color(0xFFE6E8F0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : kGreyText,
        ),
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kYellow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            right: 0,
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: 14,
                    child: Icon(Icons.wb_sunny, size: 72, color: const Color(0xFFFFD64F)),
                  ),
                  Positioned(
                    top: 2,
                    right: 4,
                    child: Icon(Icons.nightlight_round, size: 74, color: kDarkBlue),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'A Song of Moon',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1B2540)),
                ),
                SizedBox(height: 3),
                Text(
                  'Start with the basics',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B5A2E)),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.headphones_rounded, size: 15, color: Color(0xFF1B2540)),
                    SizedBox(width: 5),
                    Text(
                      '9 Sessions',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B2540)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1B2540)),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFF1B2540)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGrid extends StatelessWidget {
  const _MiniGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MiniCard(
                  bg: kYellow,
                  illustration: _sunWithClouds(),
                  title: 'The Sleep Hour',
                  author: 'Alina Mukhrejeeva',
                  meta: '3 Sessions',
                  metaIcon: Icons.headphones_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniCard(
                  bg: kYellow,
                  illustration: _moonWithClouds(),
                  title: 'Easy on the Mission',
                  author: 'Peter Mach',
                  meta: '5 minutes',
                  metaIcon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MiniCard(
                  bg: const Color(0xFFA9CFF0),
                  illustration: _sunAndMoon(),
                  title: 'Relax with Me',
                  author: 'Amanda James',
                  meta: '3 Sessions',
                  metaIcon: Icons.headphones_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniCard(
                  bg: const Color(0xFFB8EBE4),
                  illustration: _sunWithPlants(),
                  title: 'Sun and Energy',
                  author: 'Michael Hiu',
                  meta: '5 minutes',
                  metaIcon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sunWithClouds() {
    return Stack(
      children: [
        Positioned(
          top: 16,
          left: 32,
          child: Icon(Icons.wb_sunny, size: 46, color: const Color(0xFFFFD64F)),
        ),
        Positioned(
          bottom: 6,
          left: 10,
          child: Icon(Icons.cloud, size: 46, color: Colors.white),
        ),
        Positioned(
          bottom: 20,
          right: 12,
          child: Icon(Icons.cloud, size: 34, color: Colors.white),
        ),
      ],
    );
  }

  Widget _moonWithClouds() {
    return Stack(
      children: [
        Positioned(
          top: 18,
          left: 38,
          child: Icon(Icons.nightlight_round, size: 44, color: kDarkBlue),
        ),
        Positioned(
          bottom: 6,
          left: 10,
          child: Icon(Icons.cloud, size: 46, color: Colors.white),
        ),
        Positioned(
          bottom: 20,
          right: 12,
          child: Icon(Icons.cloud, size: 34, color: Colors.white),
        ),
      ],
    );
  }

  Widget _sunAndMoon() {
    return Stack(
      children: [
        Positioned(
          top: 24,
          left: 24,
          child: Icon(Icons.wb_sunny, size: 42, color: const Color(0xFFFFD64F)),
        ),
        Positioned(
          top: 22,
          right: 24,
          child: Icon(Icons.nightlight_round, size: 42, color: kDarkBlue),
        ),
        Positioned(
          bottom: 10,
          right: 48,
          child: Icon(Icons.cloud, size: 32, color: Colors.white),
        ),
      ],
    );
  }

  Widget _sunWithPlants() {
    return Stack(
      children: [
        Positioned(
          top: 18,
          left: 38,
          child: Icon(Icons.wb_sunny, size: 44, color: const Color(0xFFFFD64F)),
        ),
        Positioned(
          bottom: 8,
          left: 18,
          child: Icon(Icons.eco, size: 42, color: const Color(0xFF0A8A84)),
        ),
        Positioned(
          bottom: 6,
          right: 16,
          child: Icon(Icons.eco, size: 36, color: const Color(0xFF0A8A84)),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final Color bg;
  final Widget illustration;
  final String title;
  final String author;
  final String meta;
  final IconData metaIcon;

  const _MiniCard({
    required this.bg,
    required this.illustration,
    required this.title,
    required this.author,
    required this.meta,
    required this.metaIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: illustration,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark),
                ),
                const SizedBox(height: 3),
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: kGreyText),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(metaIcon, size: 13, color: kTeal),
                    const SizedBox(width: 4),
                    Text(
                      meta,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7080)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}