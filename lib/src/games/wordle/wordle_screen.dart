import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/providers.dart';
import 'wordle_game.dart';
import '../../screens/leaderboard_screen.dart';
import 'result/tradle_result_sheet.dart';

final _wordleProvider = StateProvider<WordleGame>((ref) => WordleGame.start());

class WordleScreen extends ConsumerStatefulWidget {
  final String userId;
  final String nickname;

  const WordleScreen({super.key, required this.userId, required this.nickname});

  @override
  ConsumerState<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends ConsumerState<WordleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _toastController;
  late final Animation<double> _toastOpacity;
  String? _toastMessage;

  @override
  void initState() {
    super.initState();

    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _toastOpacity = CurvedAnimation(
      parent: _toastController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(_wordleProvider, (prev, next) {
        // Show toast for "Word not found" and "Not enough letters"
        if (next.status == GameStatus.playing &&
            next.message != null &&
            next.message != prev?.message) {
          _showToast(next.message!);
        }

        if (prev?.status == GameStatus.playing && next.status == GameStatus.won) {
          _submitScore(next.score, next.currentRow - 1, next.elapsedSeconds ?? 0);
        }

        if (prev?.status == GameStatus.playing &&
            (next.status == GameStatus.won || next.status == GameStatus.lost)) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (!mounted) return;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
              enableDrag: false,
              backgroundColor: Colors.transparent,
              builder: (_) => TradleResultSheet(
                game: next,
                userId: widget.userId,
                nickname: widget.nickname,
                onPlayAgain: () {
                  Navigator.of(context).pop();
                  ref.read(_wordleProvider.notifier).state = WordleGame.start();
                },
                onLeaderboard: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => LeaderboardScreen(
                      gameId: 'tradle',
                      gameTitle: 'TRADLE',
                      userId: widget.userId,
                    ),
                  ));
                },
              ),
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _toastController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    setState(() => _toastMessage = message);
    _toastController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _toastController.reverse();
      });
    });
  }

  Future<void> _submitScore(int score, int attemptsUsed, int elapsedSeconds) async {
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.submitScore(
        userId: widget.userId,
        gameId: 'tradle',
        score: score,
        metadata: {
          'attempts': attemptsUsed + 1,
          'elapsed_seconds': elapsedSeconds,
          'nickname': widget.nickname,
        },
      );
    } catch (e) {
      debugPrint('[TRADLE] Score submission failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final game = ref.watch(_wordleProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('TRADLE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(_wordleProvider.notifier).state = WordleGame.start(),
            tooltip: 'New game',
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LeaderboardScreen(
                gameId: 'tradle',
                gameTitle: 'TRADLE',
                userId: widget.userId,
              ),
            )),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _WordleBoard(game: game),
                ),
                const SizedBox(height: 16),
                const _ColorLegend(),
                const SizedBox(height: 16),
                _WordleKeyboard(
                  keyboardState: game.keyboardState,
                  onKey: (key) {
                    if (game.status != GameStatus.playing) return;
                    if (key == 'ENTER') {
                      ref.read(_wordleProvider.notifier).state =
                          ref.read(_wordleProvider).submitGuess();
                    } else if (key == '⌫') {
                      ref.read(_wordleProvider.notifier).state =
                          ref.read(_wordleProvider).deleteLetter();
                    } else {
                      ref.read(_wordleProvider.notifier).state =
                          ref.read(_wordleProvider).addLetter(key);
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
            // Floating toast for "Word not found" etc.
            if (_toastMessage != null)
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _toastOpacity,
                  child: Center(
                    child: ScaleTransition(
                      scale: Tween(begin: 0.85, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _toastController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colors.error.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _toastMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Color legend ──────────────────────────────────────────────────────────────

class _ColorLegend extends StatelessWidget {
  const _ColorLegend();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: colors.success, label: 'Correct'),
          const SizedBox(width: 16),
          _LegendItem(color: colors.warning, label: 'Wrong spot'),
          const SizedBox(width: 16),
          _LegendItem(color: colors.surfaceElevated, label: 'Not in word'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── Wordle board ──────────────────────────────────────────────────────────────

class _WordleBoard extends StatelessWidget {
  final WordleGame game;

  const _WordleBoard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: WordleGame.maxAttempts * WordleGame.wordLength,
          itemBuilder: (context, index) {
            final row = index ~/ WordleGame.wordLength;
            final col = index % WordleGame.wordLength;
            final tile = game.board[row][col];
            return _LetterTileWidget(tile: tile);
          },
        ),
      ),
    );
  }
}

class _LetterTileWidget extends StatelessWidget {
  final LetterTile tile;

  const _LetterTileWidget({required this.tile});

  Color _bgColor(AppColors colors) {
    switch (tile.state) {
      case LetterState.correct:
        return colors.success;
      case LetterState.present:
        return colors.warning;
      case LetterState.absent:
        return colors.surfaceElevated;
      case LetterState.filled:
        return colors.surfaceElevated;
      case LetterState.empty:
        return colors.surface;
    }
  }

  Color _borderColor(AppColors colors) {
    switch (tile.state) {
      case LetterState.correct:
        return colors.success;
      case LetterState.present:
        return colors.warning;
      case LetterState.absent:
        return colors.surfaceElevated;
      case LetterState.filled:
        return colors.primary;
      case LetterState.empty:
        return colors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _bgColor(colors),
        border: Border.all(color: _borderColor(colors), width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          tile.letter,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Keyboard ──────────────────────────────────────────────────────────────────

class _WordleKeyboard extends StatelessWidget {
  final Map<String, LetterState> keyboardState;
  final void Function(String key) onKey;

  const _WordleKeyboard({
    required this.keyboardState,
    required this.onKey,
  });

  // ENTER removed from rows — shown as full-width button below
  static const _rows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
  ];

  Color _keyColor(String key, AppColors colors) {
    final state = keyboardState[key.toLowerCase()];
    switch (state) {
      case LetterState.correct:
        return colors.success;
      case LetterState.present:
        return colors.warning;
      case LetterState.absent:
        return const Color(0xFF1E2D4A);
      default:
        return colors.surfaceElevated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        // Letter rows
        ..._rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final isWide = key == '⌫';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: GestureDetector(
                    onTap: () => onKey(key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isWide ? 50 : 32,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _keyColor(key, colors),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          key,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: isWide ? 18 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),
        // Full-width ENTER button
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: GestureDetector(
            onTap: () => onKey('ENTER'),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'ENTER',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
