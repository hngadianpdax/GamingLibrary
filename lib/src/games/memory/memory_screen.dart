import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/providers.dart';
import '../../screens/leaderboard_screen.dart';
import 'memory_game.dart';
import 'result/memory_level_sheet.dart';
import 'result/memory_gameover_sheet.dart';

final _memoryProvider =
    StateProvider.autoDispose<MemoryGame>((ref) => MemoryGame.startSession());

class MemoryScreen extends ConsumerStatefulWidget {
  final String userId;
  final String nickname;

  const MemoryScreen({
    super.key,
    required this.userId,
    required this.nickname,
  });

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  Timer? _countdownTimer;
  Timer? _revealTimer;
  Timer? _gameTimer;
  bool _beginPlayingPending = false;
  bool _tapLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCountdown();
      ref.listenManual(_memoryProvider, _onPhaseChange);
    });
  }

  @override
  void dispose() {
    _cancelAllTimers();
    super.dispose();
  }

  void _cancelAllTimers() {
    _countdownTimer?.cancel();
    _revealTimer?.cancel();
    _gameTimer?.cancel();
    _countdownTimer = null;
    _revealTimer = null;
    _gameTimer = null;
  }

  void _onPhaseChange(MemoryGame? prev, MemoryGame next) {
    if (prev?.phase == next.phase) return;

    switch (next.phase) {
      case MemoryPhase.countdown:
        _cancelAllTimers();
        _startCountdown();

      case MemoryPhase.reveal:
        _cancelAllTimers();
        _startRevealTimer();

      case MemoryPhase.hidden:
        _cancelAllTimers();
        if (!_beginPlayingPending) {
          _beginPlayingPending = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _beginPlayingPending = false;
            if (!mounted) return;
            ref.read(_memoryProvider.notifier).state =
                ref.read(_memoryProvider).beginPlaying();
          });
        }

      case MemoryPhase.playing:
        _tapLocked = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _tapLocked = false);
        });
        _startGameTimer();

      case MemoryPhase.levelComplete:
        _cancelAllTimers();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _showLevelSheet();
        });

      case MemoryPhase.gameOver:
        _cancelAllTimers();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          _submitScore();
          _showGameOverSheet();
        });
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      ref.read(_memoryProvider.notifier).state =
          ref.read(_memoryProvider).tickCountdown();
    });
  }

  void _startRevealTimer() {
    _revealTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      ref.read(_memoryProvider.notifier).state =
          ref.read(_memoryProvider).hideGrid();
    });
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      ref.read(_memoryProvider.notifier).state =
          ref.read(_memoryProvider).tickTimer();
    });
  }

  Future<void> _submitScore() async {
    final game = ref.read(_memoryProvider);
    try {
      await ref.read(supabaseServiceProvider).submitScore(
        userId: widget.userId,
        gameId: 'memory',
        score: game.totalScore + game.levelScore,
        metadata: {
          'level_reached': game.level,
          'lives_remaining': game.lives,
          'game_over_reason': game.gameOverReason?.name,
          'nickname': widget.nickname,
        },
      );
    } catch (e) {
      debugPrint('[MEMORY] Score submission failed: $e');
    }
  }

  void _showLevelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => MemoryLevelSheet(
        game: ref.read(_memoryProvider),
        onNextLevel: () {
          Navigator.of(context).pop();
          ref.read(_memoryProvider.notifier).state =
              ref.read(_memoryProvider).advanceLevel();
        },
      ),
    );
  }

  void _showGameOverSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => MemoryGameOverSheet(
        game: ref.read(_memoryProvider),
        userId: widget.userId,
        onPlayAgain: () {
          Navigator.of(context).pop();
          ref.read(_memoryProvider.notifier).state = MemoryGame.startSession();
        },
        onLeaderboard: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => LeaderboardScreen(
              gameId: 'memory',
              gameTitle: 'MEMORY GRID',
              userId: widget.userId,
            ),
          ));
        },
      ),
    );
  }

  void _onTileTap(int index) {
    if (_tapLocked) return;
    final game = ref.read(_memoryProvider);
    if (game.phase != MemoryPhase.playing) return;

    final updated = game.tapTile(index);
    ref.read(_memoryProvider.notifier).state = updated;

    if (updated.tiles[index] == TileState.wrong) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final current = ref.read(_memoryProvider);
        if (current.phase == MemoryPhase.playing) {
          ref.read(_memoryProvider.notifier).state =
              current.clearWrongTile(index);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Watch only phase — timer ticks and tile taps no longer rebuild the Scaffold.
    final phase = ref.watch(_memoryProvider.select((g) => g.phase));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('MEMORY GRID'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart',
            onPressed: () {
              _cancelAllTimers();
              ref.read(_memoryProvider.notifier).state =
                  MemoryGame.startSession();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _LevelIndicator(),
            const _StreakBadge(),
            Expanded(child: _phaseBody(phase)),
          ],
        ),
      ),
    );
  }

  Widget _phaseBody(MemoryPhase phase) {
    if (phase == MemoryPhase.countdown) {
      return Consumer(
        builder: (_, ref, _) {
          final value =
              ref.watch(_memoryProvider.select((g) => g.countdownValue));
          return _CountdownOverlay(value: value);
        },
      );
    }
    return _MemoryGrid(onTileTap: _onTileTap);
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _StreakBadge extends ConsumerWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label =
        ref.watch(_memoryProvider.select((g) => g.streakLabel));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: label == null
          ? const SizedBox.shrink(key: ValueKey('none'))
          : Container(
              key: ValueKey(label),
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC10A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFC10A).withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFFFC10A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
    );
  }
}

class _CountdownOverlay extends StatelessWidget {
  final int value;

  const _CountdownOverlay({required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isGo = value == 0;
    final label = isGo ? 'GO!' : '$value';
    final color = isGo ? colors.success : colors.warning;

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Text(
          label,
          key: ValueKey(label),
          style: TextStyle(
            color: color,
            fontSize: 96,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _LevelIndicator extends ConsumerWidget {
  const _LevelIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final level = ref.watch(_memoryProvider.select((g) => g.level));
    final totalScore =
        ref.watch(_memoryProvider.select((g) => g.totalScore + g.levelScore));
    final lives = ref.watch(_memoryProvider.select((g) => g.lives));
    final timerSeconds =
        ref.watch(_memoryProvider.select((g) => g.timerSeconds));
    final phase = ref.watch(_memoryProvider.select((g) => g.phase));
    final progress = level / MemoryGame.maxLevel;
    final showTimer = phase == MemoryPhase.playing ||
        phase == MemoryPhase.hidden ||
        phase == MemoryPhase.reveal;
    final timerColor = timerSeconds <= 5
        ? colors.error
        : timerSeconds <= 10
            ? colors.warning
            : colors.textSecondary;
    final mins = timerSeconds ~/ 60;
    final secs = timerSeconds % 60;
    final timerLabel = '$mins:${secs.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        children: [
          // Top row: level label + score
          Row(
            children: [
              Text(
                'LEVEL $level / ${MemoryGame.maxLevel}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '$totalScore pts',
                style: TextStyle(
                  color: colors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          // Bottom row: lives (left) + timer (right)
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(MemoryGame.startingLives, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      i < lives ? Icons.favorite : Icons.favorite_border,
                      color: i < lives ? colors.error : colors.border,
                      size: 18,
                    ),
                  );
                }),
              ),
              const Spacer(),
              if (showTimer)
                Text(
                  timerLabel,
                  style: TextStyle(
                    color: timerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemoryGrid extends ConsumerWidget {
  final void Function(int index) onTileTap;

  const _MemoryGrid({required this.onTileTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size =
        ref.watch(_memoryProvider.select((g) => g.config.gridSize));
    const padding = 16.0;
    const spacing = 4.0;
    final available = MediaQuery.of(context).size.width - padding * 2;
    final tileSize = (available - spacing * (size - 1)) / size;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: SizedBox(
          width: available,
          height: tileSize * size + spacing * (size - 1),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
            ),
            itemCount: size * size,
            itemBuilder: (_, index) => Consumer(
              builder: (_, ref, _) {
                final tileState = ref.watch(
                  _memoryProvider.select((g) => g.tiles[index]),
                );
                return _MemoryTile(
                  state: tileState,
                  onTap: () => onTileTap(index),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  final TileState state;
  final VoidCallback onTap;

  const _MemoryTile({required this.state, required this.onTap});

  Color _color(AppColors colors) {
    switch (state) {
      case TileState.highlighted:
        return colors.primary;
      case TileState.correct:
        return colors.success;
      case TileState.wrong:
        return colors.error;
      case TileState.unrevealed:
      case TileState.neutral:
        return colors.surfaceElevated;
    }
  }

  Color _border(AppColors colors) {
    switch (state) {
      case TileState.highlighted:
        return colors.primary;
      case TileState.correct:
        return colors.success;
      case TileState.wrong:
        return colors.error;
      default:
        return colors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _color(colors),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _border(colors), width: 2),
        ),
      ),
    );
  }
}
