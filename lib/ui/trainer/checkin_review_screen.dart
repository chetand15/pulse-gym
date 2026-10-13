import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/trainer_service.dart';

class CheckInReviewScreen extends StatefulWidget {
  const CheckInReviewScreen({super.key});

  @override
  State<CheckInReviewScreen> createState() => _CheckInReviewScreenState();
}

class _CheckInReviewScreenState extends State<CheckInReviewScreen> {
  final Map<String, TextEditingController> _feedbackControllers = {};

  @override
  void dispose() {
    for (final controller in _feedbackControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String id) {
    return _feedbackControllers.putIfAbsent(id, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    final trainer = context.watch<TrainerService>();
    final checkIns = trainer.pendingCheckIns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Check-in Reviews'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Weekly Submissions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...checkIns.map((item) {
            final controller = _getController(item.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.clientId == 'client_demo_1' ? 'Jordan Smith' : 'Sarah Jenkins',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.isReviewed
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.isReviewed ? 'Reviewed' : 'Needs Review',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.isReviewed ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Weight: ${item.weightKg} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                        if (item.bodyFatPercentage != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            'BF: ${item.bodyFatPercentage}%',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${item.date.day}/${item.date.month}/${item.date.year}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Client Note: "${item.clientNotes}"',
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (item.trainerFeedback != null) ...[
                      const Text(
                        'Sent Feedback:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(item.trainerFeedback!, style: const TextStyle(fontSize: 13, color: AppColors.success)),
                    ] else ...[
                      TextField(
                        controller: controller,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Write constructive feedback, macro tweak, or encouragement...',
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 42),
                        ),
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('SUBMIT FEEDBACK TO CLIENT'),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            trainer.submitTrainerFeedback(item.id, text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feedback sent to client!')),
                            );
                          }
                        },
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
}
