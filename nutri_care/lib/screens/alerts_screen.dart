import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/content_models.dart';
import '../constants/colors.dart';
import '../bloc/content/content_bloc.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    context.read<SearchBloc>().add(SearchAlerts(query: _searchController.text));
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
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.secondaryBackground,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Search alerts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchBloc>().add(ClearSearch());
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Content Section
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        if (searchState is SearchResults) {
          return _buildAlertsList(searchState.alerts);
        }

        return BlocBuilder<ContentBloc, ContentState>(
          builder: (context, contentState) {
            if (contentState is ContentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (contentState is ContentError) {
              return Center(child: Text('Error: ${contentState.message}'));
            }

            final alerts = contentState is ContentLoaded
                ? contentState.alerts
                : <HealthAlert>[];
            return _buildAlertsList(alerts);
          },
        );
      },
    );
  }

  Widget _buildAlertsList(List<HealthAlert> alerts) {
    if (alerts.isEmpty) {
      return const Center(
        child: Text(
          'No alerts found',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(alert.title),
            subtitle: Text(alert.description),
            leading: const Icon(Icons.warning, color: Colors.red),
            trailing: Text(
              _formatDate(alert.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
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
