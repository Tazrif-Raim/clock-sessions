import 'package:clock_sessions/main.dart';
import 'package:clock_sessions/services/stopwatch_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopwatchService = ref.watch(stopwatchServiceProvider);
    final monthlyEarnings = ref.watch(monthlyEarningsProvider);
    final monthlyDays = ref.watch(monthlyDaysProvider);
    final today = DateTime.now();
    final formattedDate = DateFormat('E, d MMM').format(today).toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly Earning', style: TextStyle(fontSize: 16)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          monthlyEarnings.when(
                            data: (earnings) => Text(
                              '৳${earnings.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (err, stack) => const Text('Error'),
                          ),
                          monthlyDays.when(
                            data: (days) => Text('$days Days'),
                            loading: () => const SizedBox(),
                            error: (err, stack) => const SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDuration(stopwatchService.elapsed),
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w300),
              ),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              SizedBox(
                width: 150,
                height: 150,
                child: FilledButton(
                  onPressed: () {
                    if (stopwatchService.isRunning) {
                      ref.read(stopwatchServiceProvider.notifier).stop();
                      final dbService = ref.read(dbServiceProvider);
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      dbService.upsertSession(today, stopwatchService.elapsed.inSeconds).then((_) {
                        ref.refresh(monthlyEarningsProvider);
                        ref.refresh(monthlyDaysProvider);
                      });
                    } else {
                      ref.read(stopwatchServiceProvider.notifier).start();
                    }
                  },
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  child: Text(
                    stopwatchService.isRunning ? 'STOP' : 'START',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}