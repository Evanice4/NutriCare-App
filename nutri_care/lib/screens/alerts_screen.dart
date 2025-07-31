import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/content_models.dart';
import '../constants/colors.dart';
import '../bloc/content/content_bloc.dart';
import '../bloc/content/content_event.dart';
import '../bloc/content/content_state.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: AppColors.secondaryBackground,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (state is ContentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ContentError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          final alerts = state is ContentLoaded ? state.alerts : <HealthAlert>[];

          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts found', style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(alert.title),
                  subtitle: Text(alert.description),
                  leading: const Icon(Icons.warning, color: Colors.red),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
