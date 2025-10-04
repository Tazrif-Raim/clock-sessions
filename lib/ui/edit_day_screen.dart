import 'package:clock_sessions/db/database.dart';
import 'package:clock_sessions/main.dart';
import 'package:clock_sessions/ui/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditDayScreen extends ConsumerStatefulWidget {
  final Session session;
  const EditDayScreen({super.key, required this.session});

  @override
  ConsumerState<EditDayScreen> createState() => _EditDayScreenState();
}

class _EditDayScreenState extends ConsumerState<EditDayScreen> {
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final duration = Duration(seconds: widget.session.durationInSeconds);
    _hoursController = TextEditingController(text: duration.inHours.toString());
    _minutesController = TextEditingController(text: duration.inMinutes.remainder(60).toString());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final newDurationInSeconds = (hours * 3600) + (minutes * 60);

      final dbService = ref.read(dbServiceProvider);
      dbService.updateSession(widget.session.id, newDurationInSeconds).then((_) {
        ref.refresh(allSessionsProvider);
        ref.refresh(monthlyEarningsProvider);
        ref.refresh(monthlyDaysProvider);
        Navigator.pop(context);
      });
    }
  }

  void _deleteEntry() {
    final dbService = ref.read(dbServiceProvider);
    dbService.deleteSession(widget.session.id).then((_) {
      ref.refresh(allSessionsProvider);
      ref.refresh(monthlyEarningsProvider);
      ref.refresh(monthlyDaysProvider);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(widget.session.date);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Day'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedDate, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hours',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hours';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter minutes';
                        }
                        final minutes = int.tryParse(value);
                        if (minutes == null) {
                          return 'Please enter a valid number';
                        }
                        if (minutes < 0 || minutes > 59) {
                          return 'Minutes must be between 0-59';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _deleteEntry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Delete Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}