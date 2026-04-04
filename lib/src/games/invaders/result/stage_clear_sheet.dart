import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../games/wordle/result/ad_banner_carousel.dart';
import '../invaders_game.dart';

class StageClearSheet extends StatelessWidget {
  final InvadersGame game;
  final VoidCallback onNextStage;

  const StageClearSheet({
    super.key,
    required this.game,
    required this.onNextStage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLastStage = game.stageIndex >= game.totalStages - 1;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.success),
            ),
            child: Text(
              'STAGE ${game.stageIndex + 1} CLEARED',
              style: TextStyle(
                color: colors.success,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            game.currentStage.title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          _StatRow(label: 'SCORE', value: '${game.score} pts'),
          const SizedBox(height: 8),
          _StatRow(
            label: 'LIVES REMAINING',
            value: '${game.lives}',
            valueColor: colors.error,
          ),
          const SizedBox(height: 24),

          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNextStage,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isLastStage ? 'FINISH' : 'NEXT STAGE →',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const AdBannerCarousel(),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                letterSpacing: 1)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? colors.warning,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
