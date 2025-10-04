import 'package:clock_sessions/db/database.dart';
import 'package:clock_sessions/main.dart';
import 'package:clock_sessions/ui/edit_day_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

final allSessionsProvider = FutureProvider<List<Session>>((ref) {
  final dbService = ref.watch(dbServiceProvider);
  return dbService.getAllSessions();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsyncValue = ref.watch(allSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: sessionsAsyncValue.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No history yet.'));
          }

          final groupedByMonth = groupBy(sessions, (Session s) => DateFormat('MMMM yyyy').format(s.date));

          return ListView.builder(
            itemCount: groupedByMonth.length,
            itemBuilder: (context, index) {
              final month = groupedByMonth.keys.elementAt(index);
              final monthSessions = groupedByMonth[month]!;

              final totalHours = monthSessions.fold<int>(0, (sum, s) => sum + s.durationInSeconds) / 3600;
              final totalEarnings = monthSessions.where((s) => s.durationInSeconds >= 5 * 3600).length * 150;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(month, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('${monthSessions.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Text('Days'),
                            ],
                          ),
                          Column(
                            children: [
                              Text(totalHours.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Text('Hours'),
                            ],
                          ),
                           Column(
                            children: [
                              Text('৳${totalEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Text('Earning'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...monthSessions.map((session) {
                    final duration = Duration(seconds: session.durationInSeconds);
                    final earning = duration.inHours >= 5 ? '+150' : '+0';
                    final durationString = "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
                    return Dismissible(
                      key: Key(session.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        ref.read(dbServiceProvider).deleteSession(session.id);
                        ref.refresh(allSessionsProvider);
                        ref.refresh(monthlyEarningsProvider);
                        ref.refresh(monthlyDaysProvider);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(DateFormat('d').format(session.date))),
                        title: Text(DateFormat('EEEE').format(session.date)),
                        subtitle: Text(durationString),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(earning, style: TextStyle(color: earning == '+150' ? Colors.green : Colors.red)),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditDayScreen(session: session)),
                                );
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