import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../api/auth_api.dart';
import '../models/user_model.dart';
import '../constants/colors.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../bloc/navigation/navigation_event.dart';
import '../bloc/navigation/navigation_state.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../bloc/content/content_bloc.dart';
import '../bloc/content/content_event.dart';
import '../widgets/theme_toggle.dart';

import 'guides_screen.dart';
import 'recipes_screen.dart';
import 'alerts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthApi _authApi = AuthApi();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<UserBloc>().add(LoadUserProfile(user.uid));
      context.read<ContentBloc>().add(LoadGuides());
      context.read<ContentBloc>().add(LoadRecipes());
      context.read<ContentBloc>().add(LoadAlerts());
    }
  }



  void _signOut() {
    context.read<UserBloc>().add(SignOutUser());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserSignedOut || state is UserError) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (userState is! UserLoaded) {
            return const Scaffold(body: Center(child: Text('Please log in')));
          }

          final currentUser = userState.user;
          final screens = [
            const _HomeContent(),
            GuidesScreen(currentUser: currentUser),
            RecipesScreen(currentUser: currentUser),
            const AlertsScreen(),
          ];

          return BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, navState) {
              final currentIndex = navState.currentIndex;
              
              return Scaffold(
                backgroundColor: currentIndex == 0 ? AppColors.homeBackground : AppColors.secondaryBackground,
                appBar: AppBar(
                  title: Text(
                    currentIndex == 0
                        ? 'Muraho Neza! Welcome'
                        : ['Home', 'Guides', 'Recipes', 'Alerts'][currentIndex],
                  ),
                  backgroundColor: currentIndex == 0 ? AppColors.homeBackground : AppColors.secondaryBackground,
                  foregroundColor: Colors.white,
                  actions: [
                    const ThemeToggle(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            _showProfileDialog(currentUser);
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
                              Text(currentUser.displayName),
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
                    ),
                  ],
                ),
                body: IndexedStack(index: currentIndex, children: screens),
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: currentIndex,
                  onTap: (index) {
                    context.read<NavigationBloc>().add(NavigateToTab(index));
                  },
                  backgroundColor: AppColors.bottomNavBackground,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.grey[600],
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Guides'),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.restaurant_menu),
                      label: 'Recipes',
                    ),
                    BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProfileDialog(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.displayName}'),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
            const SizedBox(height: 8),
            Text('Type: ${user.userType}'),
            const SizedBox(height: 8),
            if (user.userType == 'creator')
              Text(
                'Verified: ${user.isVerified ? 'Yes' : 'Pending'}',
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.restaurant_menu, size: 40, color: AppColors.homeBackground),
                  SizedBox(height: 12),
                  Text(
                    'Welcome to NutriCare!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.homeBackground,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your trusted companion for nutrition guidance and healthy recipes.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Links Section
          const Text(
            'Quick Links',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _QuickLinkCard(
                icon: Icons.menu_book,
                title: 'Nutrition Guides',
                subtitle: 'Expert advice',
                color: Colors.blue,
                onTap: () {
                  // This would be handled by the parent's navigation
                },
              ),
              _QuickLinkCard(
                icon: Icons.restaurant_menu,
                title: 'Healthy Recipes',
                subtitle: 'Delicious meals',
                color: Colors.orange,
                onTap: () {
                  // This would be handled by the parent's navigation
                },
              ),
              _QuickLinkCard(
                icon: Icons.warning_amber,
                title: 'Health Alerts',
                subtitle: 'Stay informed',
                color: Colors.red,
                onTap: () {
                  // This would be handled by the parent's navigation
                },
              ),
              _QuickLinkCard(
                icon: Icons.trending_up,
                title: 'Progress Tracker',
                subtitle: 'Monitor health',
                color: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress Tracker - Coming Soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Did You Know Section
          const Text(
            'Did You Know?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          const _DidYouKnowCard(
            fact:
                'Eating a variety of colorful fruits and vegetables ensures you get a wide range of vitamins and minerals!',
            icon: Icons.palette,
          ),
          const SizedBox(height: 12),
          const _DidYouKnowCard(
            fact:
                'Drinking water before meals can help with digestion and weight management.',
            icon: Icons.water_drop,
          ),
          const SizedBox(height: 12),
          const _DidYouKnowCard(
            fact:
                'Protein should make up 10-35% of your daily calorie intake for optimal health.',
            icon: Icons.fitness_center,
          ),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    (color.r * 255).round(),
                    (color.g * 255).round(),
                    (color.b * 255).round(),
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DidYouKnowCard extends StatelessWidget {
  final String fact;
  final IconData icon;

  const _DidYouKnowCard({required this.fact, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(76, 175, 80, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(fact, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }
}
