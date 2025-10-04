import 'package:clock_sessions/db/database.dart';
import 'package:clock_sessions/main.dart';
import 'package:clock_sessions/ui/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsyncValue = ref.watch(allSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
      ),
      body: sessionsAsyncValue.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No summary available.'));
          }

          final groupedByYear = groupBy(sessions, (Session s) => s.date.year);

          return ListView.builder(
            itemCount: groupedByYear.length,
            itemBuilder: (context, yearIndex) {
              final year = groupedByYear.keys.elementAt(yearIndex);
              final yearSessions = groupedByYear[year]!;
              final yearlyEarnings = yearSessions.where((s) => s.durationInSeconds >= 5 * 3600).length * 150;

              final groupedByMonth = groupBy(yearSessions, (Session s) => s.date.month);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$year', style: Theme.of(context).textTheme.headlineSmall),
                        Text('৳${yearlyEarnings.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                  ...groupedByMonth.entries.map((entry) {
                    final month = entry.key;
                    final monthSessions = entry.value;
                    final monthlyEarnings = monthSessions.where((s) => s.durationInSeconds >= 5 * 3600).length * 150;
                    final monthName = DateFormat.MMMM().format(DateTime(0, month));

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(monthName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('৳${monthlyEarnings.toStringAsFixed(0)}'),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                await ref.read(dbServiceProvider).deleteSessionsByMonth(year, month);
                                ref.refresh(allSessionsProvider);
                                ref.refresh(monthlyEarningsProvider);
                                ref.refresh(monthlyDaysProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}