import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/content_models.dart';
import '../constants/colors.dart';
import '../bloc/content/content_bloc.dart';
import '../api/firestore_content_api.dart';
import '../bloc/content/content_state.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _searchController = TextEditingController();
  final _contentApi = FirestoreContentApi();

  @override
  void initState() {
    super.initState();
    // Clear search state when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchBloc>().add(ClearSearch());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    // For now, we'll disable search on notifications
    // context.read<SearchBloc>().add(SearchAlerts(query: _searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: AppColors.secondaryBackground,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.secondaryBackground,
            child: const Text(
              'Recent notifications from creators',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          // Content Section
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<List<AppNotification>>(
      stream: _contentApi.notificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading notifications',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final notifications = snapshot.data ?? [];
        return _buildNotificationsList(notifications);
      },
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ll see notifications when creators add new content',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.message),
            leading: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDate(notification.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _dismissNotification(notification.id),
                  tooltip: 'Dismiss',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'recipe_added':
      case 'recipe_updated':
        return Icons.restaurant;
      case 'guide_added':
      case 'guide_updated':
        return Icons.menu_book;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'recipe_added':
      case 'recipe_updated':
        return Colors.orange;
      case 'guide_added':
      case 'guide_updated':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Future<void> _dismissNotification(String notificationId) async {
    try {
      await _contentApi.deleteNotification(notificationId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to dismiss notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
