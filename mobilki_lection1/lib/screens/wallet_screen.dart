import 'package:flutter/material.dart';

const kDark = Color(0xFF15171D);
const kGreyText = Color(0xFF7A8094);
const kBlue = Color(0xFF2E5BFF);
const kRed = Color(0xFFF4574D);

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F9),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Center(child: Icon(Icons.menu, color: kDark)),
        ),
        title: const Text(
          'My E-Wallet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kDark),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 6),
            child: Icon(Icons.search_rounded, color: kDark),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications_none, color: kDark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _BankCard(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kDark),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All', style: TextStyle(fontSize: 13, color: kBlue)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const _Transactions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const _TabBar(),
    );
  }
}

class _BankCard extends StatelessWidget {
  const _BankCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF000000), Color(0xFF33373F)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -60,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBlue.withValues(alpha: 0.35),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Andrew Ainsley',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  const Text(
                    'VISA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _Mastercard(),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '**** **** **** 3629',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, size: 15, color: kDark),
                        SizedBox(width: 6),
                        Text(
                          'Top Up',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(height: 14),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$9,379',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Your balance',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Mastercard extends StatelessWidget {
  const _Mastercard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 2,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEB001B)),
            ),
          ),
          Positioned(
            left: 16,
            top: 2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Transactions extends StatelessWidget {
  const _Transactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _txRow(
            icon: Icons.chair_rounded,
            iconColor: const Color(0xFFF08A3C),
            title: 'Lawson Chair',
            date: 'Dec 15, 2024 | 10:00 AM',
            amount: '-\$120',
            positive: false,
            status: 'Orders',
          ),
          _txRow(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: kBlue,
            title: 'Top Up Wallet',
            date: 'Dec 14, 2024 | 16:42 PM',
            amount: '+\$400',
            positive: true,
            status: 'Top Up',
          ),
          _txRow(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: const Color(0xFF5FA96B),
            title: 'Parabolic Reflector',
            date: 'Dec 14, 2024 | 11:39 AM',
            amount: '-\$170',
            positive: false,
            status: 'Orders',
          ),
          _txRow(
            icon: Icons.table_restaurant_rounded,
            iconColor: const Color(0xFF8A5CF6),
            title: 'Mini Wooden Table',
            date: 'Dec 13, 2024 | 14:46 PM',
            amount: '-\$165',
            positive: false,
            status: 'Orders',
          ),
          _txRow(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: kBlue,
            title: 'Top Up Wallet',
            date: 'Dec 12, 2024 | 09:27 AM',
            amount: '+\$300',
            positive: true,
            status: 'Top Up',
          ),
        ],
      ),
    );
  }

  Widget _txRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
    required String amount,
    required bool positive,
    required String status,
  }) {
    final isOrders = status == 'Orders';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDark),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: kGreyText),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: positive ? const Color(0xFF2E9E5B) : kRed,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOrders
                      ? const Color(0xFFFFE9E7)
                      : const Color(0xFFE6EDFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isOrders ? kRed : kBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.home_rounded, size: 24, color: Color(0xFFB9BEC9)),
              Icon(Icons.shopping_bag_rounded, size: 24, color: Color(0xFFB9BEC9)),
              Icon(Icons.receipt_long_rounded, size: 24, color: Color(0xFFB9BEC9)),
              _WalletTab(),
              Icon(Icons.person_rounded, size: 24, color: Color(0xFFB9BEC9)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletTab extends StatelessWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.white),
          SizedBox(width: 5),
          Text(
            'Wallet',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
