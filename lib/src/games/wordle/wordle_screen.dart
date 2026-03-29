import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/providers.dart';
import 'wordle_game.dart';
import '../../screens/leaderboard_screen.dart';

final _wordleProvider = StateProvider<WordleGame>((ref) => WordleGame.start());

class WordleScreen extends ConsumerWidget {
  final String userId;
  final String nickname;

  const WordleScreen({super.key, required this.userId, required this.nickname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(_wordleProvider);

    // Submit score when game ends
    ref.listen(_wordleProvider, (prev, next) {
      if (prev?.status == GameStatus.playing &&
          next.status == GameStatus.won) {
        _submitScore(ref, next.score, next.currentRow - 1);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CRYPTODLE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(_wordleProvider.notifier).state = WordleGame.start(),
            tooltip: 'New game',
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const LeaderboardScreen(
                gameId: 'wordle',
                gameTitle: 'CRYPTODLE',
              ),
            )),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (game.message != null)
              _MessageBanner(message: game.message!, status: game.status),
            const SizedBox(height: 12),
            Expanded(
              child: _WordleBoard(game: game),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _submitScore(WidgetRef ref, int score, int attemptsUsed) async {
    final service = ref.read(supabaseServiceProvider);
    await service.submitScore(
      userId: userId,
      gameId: 'wordle',
      score: score,
      metadata: {'attempts': attemptsUsed + 1, 'nickname': nickname},
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final GameStatus status;

  const _MessageBanner({required this.message, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == GameStatus.won
        ? AppColors.success
        : status == GameStatus.lost
            ? AppColors.error
            : AppColors.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: color.withValues(alpha: 0.15),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

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

  Color get _bgColor {
    switch (tile.state) {
      case LetterState.correct:
        return AppColors.success;
      case LetterState.present:
        return AppColors.warning;
      case LetterState.absent:
        return AppColors.surfaceElevated;
      case LetterState.filled:
        return AppColors.surfaceElevated;
      case LetterState.empty:
        return AppColors.surface;
    }
  }

  Color get _borderColor {
    switch (tile.state) {
      case LetterState.correct:
        return AppColors.success;
      case LetterState.present:
        return AppColors.warning;
      case LetterState.absent:
        return AppColors.surfaceElevated;
      case LetterState.filled:
        return AppColors.primary;
      case LetterState.empty:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _borderColor, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          tile.letter,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _WordleKeyboard extends StatelessWidget {
  final Map<String, LetterState> keyboardState;
  final void Function(String key) onKey;

  const _WordleKeyboard({
    required this.keyboardState,
    required this.onKey,
  });

  static const _rows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
  ];

  Color _keyColor(String key) {
    final state = keyboardState[key.toLowerCase()];
    switch (state) {
      case LetterState.correct:
        return AppColors.success;
      case LetterState.present:
        return AppColors.warning;
      case LetterState.absent:
        return const Color(0xFF1E2D4A);
      default:
        return AppColors.surfaceElevated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              final isWide = key == 'ENTER' || key == '⌫';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: GestureDetector(
                  onTap: () => onKey(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isWide ? 56 : 32,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _keyColor(key),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        key,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isWide ? 11 : 14,
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
      }).toList(),
    );
  }
}
