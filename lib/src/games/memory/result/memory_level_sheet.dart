import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../memory_game.dart';
import '../../wordle/result/ad_banner_carousel.dart';

class MemoryLevelSheet extends StatelessWidget {
  final MemoryGame game;
  final VoidCallback onNextLevel;

  const MemoryLevelSheet({
    super.key,
    required this.game,
    required this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLastLevel = game.level >= MemoryGame.maxLevel;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Headline
            Text(
              'LEVEL ${game.level} COMPLETE',
              style: TextStyle(
                color: colors.success,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),

            // Stats card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  _StatRow(
                    label: 'TILES FOUND',
                    value: '${game.config.tileCount} / ${game.config.tileCount}',
                    color: colors.success,
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    label: 'POINTS THIS LEVEL',
                    value: '+${game.levelScore} pts',
                    color: colors.warning,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: colors.border, height: 1),
                  ),
                  _StatRow(
                    label: 'TOTAL SCORE',
                    value: '${game.totalScore + game.levelScore} pts',
                    color: colors.primary,
                    bold: true,
                    large: true,
                  ),
                  const SizedBox(height: 8),
                  _LivesRow(lives: game.lives),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Next level button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNextLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                ),
                child: Text(isLastLevel ? 'FINISH' : 'NEXT LEVEL →'),
              ),
            ),
            const SizedBox(height: 20),

            // Ad section
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'SPONSORED',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const AdBannerCarousel(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;
  final bool large;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: large ? 13 : 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: large ? 16 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LivesRow extends StatelessWidget {
  final int lives;

  const _LivesRow({required this.lives});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            'LIVES REMAINING',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          children: List.generate(MemoryGame.startingLives, (i) {
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                i < lives ? Icons.favorite : Icons.favorite_border,
                color: i < lives ? colors.error : colors.border,
                size: 18,
              ),
            );
          }),
        ),
      ],
    );
  }
}
