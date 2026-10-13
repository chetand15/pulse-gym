import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/trainer_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _weightController = TextEditingController(text: '78.5');
  final _bodyFatController = TextEditingController(text: '14.5');
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitCheckIn(TrainerService trainer) {
    final weight = double.tryParse(_weightController.text) ?? 78.5;
    final notes = _notesController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Weekly Check-in sent to Coach Alex!')),
    );
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = context.watch<TrainerService>();
    final checkIns = trainer.pendingCheckIns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & Check-ins'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Weight Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeightStat('Starting', '84.0 kg', AppColors.textSecondary),
                Container(width: 1, height: 40, color: AppColors.divider),
                _buildWeightStat('Current', '78.5 kg', AppColors.primary),
                Container(width: 1, height: 40, color: AppColors.divider),
                _buildWeightStat('Lost', '-5.5 kg', AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit New Check-In Form
          const Text(
            'Weekly Coach Check-In',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Body Weight (kg)',
                          prefixIcon: Icon(Icons.monitor_weight_outlined, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _bodyFatController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Body Fat %',
                          prefixIcon: Icon(Icons.pie_chart_outline, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Notes for Trainer',
                    hintText: 'Energy levels, sleep, recovery, cravings, highlights...',
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('SUBMIT CHECK-IN TO TRAINER'),
                  onPressed: () => _submitCheckIn(trainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Check-in history & Coach Feedback
          const Text(
            'Past Check-ins & Trainer Feedback',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...checkIns.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.weightKg} kg  ${item.bodyFatPercentage != null ? "• ${item.bodyFatPercentage}% BF" : ""}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        Text(
                          '${item.date.day}/${item.date.month}/${item.date.year}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${item.clientNotes}"',
                      style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary, fontSize: 13),
                    ),
                    if (item.trainerFeedback != null) ...[
                      const Divider(color: AppColors.divider, height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified, color: AppColors.secondary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Coach Feedback:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.trainerFeedback!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.hourglass_empty, size: 14, color: AppColors.warning),
                          SizedBox(width: 4),
                          Text('Pending coach review', style: TextStyle(fontSize: 12, color: AppColors.warning)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
