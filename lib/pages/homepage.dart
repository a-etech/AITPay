import 'package:flutter/material.dart';
import '../widgets/bg_container.dart';
import 'check_status_page.dart'; // Import the CheckStatusPage
import 'profile_page.dart';

class AppColors {
  static const Color red = Color(0xFFFF4B4B);
  static const Color purple = Color(0xFF9C27B0);
  static const Color blue = Color(0xFF2196F3);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color teal = Color(0xFF009688);
  static const Color green = Color(0xFF4CAF50);
  static const Color lime = Color(0xFFCDDC39);
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color orange = Color(0xFFFF9800);
}

class HomePage extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const HomePage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Updated pages to include CheckStatusPage without parameters
  late final List<Widget> _pages = [
    const HomeContent(),
    const CheckStatusPage(paymentReference: '', amountToPay: 0, paymentMethod: ''), // Removed parameters
    ProfilePage(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    // Show exit confirmation dialog
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User does not want to exit
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User wants to exit
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false; // Fallback to false if dialog is null
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Set the back button behavior
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'AITPay',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: BackgroundContainer(
          opacity: 1,
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              label: 'Check Status',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }
}

// This is the content of your main home page, separated for clarity
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 45),
            child: Center(
              child: SizedBox(
                width: screenSize.width * 0.88,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    FeatureCard(
                      icon: Icons.payment,
                      label: 'Proceed to Pay',
                      color: AppColors.purple,
                      onTap: () => Navigator.pushNamed(context, '/proceedToPay'),
                    ),
                    FeatureCard(
                      icon: Icons.payments_outlined,
                      label: 'Schedule of Fee',
                      color: AppColors.cyan,
                      onTap: () => Navigator.pushNamed(context, '/scheduleOfFee'),
                    ),
                    FeatureCard(
                      icon: Icons.assignment_turned_in,
                      label: 'Check Registration',
                      color: AppColors.teal,
                      onTap: () => Navigator.pushNamed(context, '/checkRegistration'),
                    ),
                    FeatureCard(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      color: AppColors.green,
                      onTap: () => Navigator.pushNamed(context, '/helpSupport'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// FeatureCard widget moved outside to be accessible globally
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 38,
                  color: color,
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
