import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/trainer_service.dart';

class ClientRosterScreen extends StatelessWidget {
  const ClientRosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainer = context.watch<TrainerService>();
    final auth = context.watch<AuthService>();
    final clients = trainer.clients;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coach ${auth.currentUser?.displayName ?? "Trainer"} 🏋️‍♂️', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Personal Trainer Dashboard', style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textMuted),
            tooltip: 'Sign Out / Switch Role',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Trainer Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRosterMetric('Active Clients', '${clients.length}', AppColors.secondary),
                Container(width: 1, height: 40, color: AppColors.divider),
                _buildRosterMetric('Avg Compliance', '82%', AppColors.success),
                Container(width: 1, height: 40, color: AppColors.divider),
                _buildRosterMetric('Reviews Pending', '${trainer.pendingCheckIns.where((c) => !c.isReviewed).length}', AppColors.warning),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Clients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${clients.length} Total',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...clients.map((clientInfo) {
            final compliancePct = (clientInfo.complianceRate * 100).toInt();
            final complianceColor = compliancePct >= 80 ? AppColors.success : (compliancePct >= 65 ? AppColors.warning : AppColors.error);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.surfaceLight,
                          radius: 22,
                          child: Text(
                            clientInfo.user.displayName.isNotEmpty
                                ? clientInfo.user.displayName[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clientInfo.user.displayName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                clientInfo.currentProgramTitle,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: complianceColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$compliancePct% Compliant',
                            style: TextStyle(
                              color: complianceColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.divider, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last active: ${clientInfo.lastActiveText}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        Text(
                          'Weight: ${clientInfo.currentWeightKg} kg',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRosterMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
