import 'package:clock_sessions/main.dart';
import 'package:clock_sessions/ui/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data?'),
          content: const Text('This will permanently delete all your time tracking history. This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                final dbService = ref.read(dbServiceProvider);
                dbService.deleteAllSessions().then((_) {
                  ref.refresh(allSessionsProvider);
                  ref.refresh(monthlyEarningsProvider);
                  ref.refresh(monthlyDaysProvider);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data has been deleted.')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Daily Goal'),
            subtitle: const Text('5h 00m'),
            onTap: () {
              // Placeholder for daily goal setting
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Reminder'),
            onTap: () {
              // Placeholder for reminder setting
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (bool value) {
              // This requires a ThemeMode provider to actually change the theme
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text('Rate this app'),
            onTap: () {
              // Placeholder for rating the app
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete All Data', style: TextStyle(color: Colors.red)),
            onTap: () => _showDeleteConfirmationDialog(context, ref),
          ),
        ],
      ),
    );
  }
}