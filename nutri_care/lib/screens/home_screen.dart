import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/auth_api.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'guides_screen.dart';
import 'recipes_screen.dart';
import 'alerts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthApi _authApi = AuthApi();
  UserProfile? _currentUser;
  bool _loading = true;

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userProfile = await _authApi.getUserProfile(user.uid);
        if (mounted) {
          setState(() {
            _currentUser = userProfile;
            _screens = [
              const _HomeContent(),
              GuidesScreen(currentUser: userProfile),
              RecipesScreen(currentUser: userProfile),
              const AlertsScreen(),
            ];
            _loading = false;
          });
        }
      } else {
        // No user logged in, redirect to login
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        // Show error and redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authApi.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 180, // Increased height to accommodate all elements
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8BC34A), Color(0xFFC8E6C9)], // Green gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Muraho\nNeza!', // "Muraho Neza!" on two lines
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.0, // Adjust line height
                      ),
                    ),
                    const SizedBox(width: 8),
                    // "welcome" next to "Neza!"
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                        ), // Align "welcome" with "Neza!"
                        child: Text(
                          'welcome',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 22,
                            //fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(), // Pushes content to the left
                    // You might add the menu icon here if needed
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            _showProfileDialog();
                            break;
                          case 'logout':
                            _signOut();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              const Icon(Icons.person),
                              const SizedBox(width: 8),
                              Text(_currentUser?.displayName ?? 'Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text('Logout'),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 30,
                      ), // Example of a menu icon
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "let's build healthy eating habits together",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Guides'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_basket,
            ), // Changed to shopping_basket for Recipes
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ), // Changed to notifications for Alerts
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${_currentUser?.displayName ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Email: ${_currentUser?.email ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Type: ${_currentUser?.userType ?? 'N/A'}'),
            const SizedBox(height: 8),
            if (_currentUser?.userType == 'creator')
              Text(
                'Verified: ${_currentUser?.isVerified == true ? 'Yes' : 'Pending'}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // The overall background color of the body should be yellow.
      child: Container(
        color: const Color(0xFFDCDCAA), // Yellowish background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // No "Welcome Card" as per the new design.
              // Instead, we have the Quick Links (round icons) directly below the app bar.
              GridView.count(
                crossAxisCount: 3, // 3 items per row
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _RoundQuickLink(
                    imagePath:
                        'assets/images/nutrition_guides.png', // Replace with actual image asset
                    title: 'Nutrition\nGuides',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GuidesScreen(),
                        ),
                      );
                    },
                  ),
                  _RoundQuickLink(
                    imagePath:
                        'assets/images/local_recipes.png', // Replace with actual image asset
                    title: 'Local\nRecipes',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecipesScreen(),
                        ),
                      );
                    },
                  ),
                  _RoundQuickLink(
                    imagePath:
                        'assets/images/health_alerts.png', // Replace with actual image asset
                    title: 'Health\nAlerts',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AlertsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Did You Know Section
              const Text(
                'DID YOU KNOW!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              const _DidYouKnowCard(
                fact:
                    'Avocados are packed with heart-healthy fats that\ncan help lower bad cholesterol, keep your brain sharp! 🥑💖',
              ),
              const SizedBox(height: 12),
              const _DidYouKnowCard(
                fact:
                    'Eating one kiwi gives you more vitamin C than an\norange, helping boost your immune system and fight off\ncolds naturally! 🥝💪',
              ),
              const SizedBox(height: 12),
              const _DidYouKnowCard(
                fact:
                    'Eating one kiwi gives you more vitamin C than an\norange, helping boost your immune system and fight off\ncolds naturally! 🥝💪', // Duplicated from image
              ),
              const SizedBox(height: 20), // Padding before bottom nav bar
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundQuickLink extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const _RoundQuickLink({
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor:
                Colors.transparent, // Background of avatar is transparent
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _DidYouKnowCard extends StatelessWidget {
  final String fact;

  const _DidYouKnowCard({required this.fact});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(fact, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
