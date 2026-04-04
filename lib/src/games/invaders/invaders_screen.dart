import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/leaderboard_screen.dart';
import 'invaders_game.dart';
import 'result/game_over_sheet.dart';
import 'result/stage_clear_sheet.dart';
import 'result/victory_sheet.dart';

class InvadersScreen extends ConsumerStatefulWidget {
  final String userId;
  final String nickname;

  const InvadersScreen({
    super.key,
    required this.userId,
    required this.nickname,
  });

  @override
  ConsumerState<InvadersScreen> createState() => _InvadersScreenState();
}

class _InvadersScreenState extends ConsumerState<InvadersScreen> {
  late InvadersGame _game;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _game = InvadersGame(onPhaseChange: _onPhaseChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game.bgColor = context.colors.background;
  }

  void _onPhaseChange(InvadersPhase phase) {
    if (!mounted) return;

    switch (phase) {
      case InvadersPhase.stageClear:
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.transparent,
            builder: (_) => StageClearSheet(
              game: _game,
              onNextStage: () {
                Navigator.of(context).pop();
                _game.advanceToNextStage();
              },
            ),
          );
        });

      case InvadersPhase.gameOver:
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _submitScore();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.transparent,
            builder: (_) => InvadersGameOverSheet(
              game: _game,
              userId: widget.userId,
              nickname: widget.nickname,
              onPlayAgain: () {
                Navigator.of(context).pop();
                setState(() => _startNewGame());
              },
              onLeaderboard: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(
                    gameId: 'invaders',
                    gameTitle: 'INVADERS',
                    userId: widget.userId,
                  ),
                ));
              },
            ),
          );
        });

      case InvadersPhase.victory:
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _submitScore();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.transparent,
            builder: (_) => VictorySheet(
              game: _game,
              onPlayAgain: () {
                Navigator.of(context).pop();
                setState(() => _startNewGame());
              },
              onLeaderboard: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(
                    gameId: 'invaders',
                    gameTitle: 'INVADERS',
                    userId: widget.userId,
                  ),
                ));
              },
            ),
          );
        });

      default:
        break;
    }
  }

  Future<void> _submitScore() async {
    try {
      await ref.read(supabaseServiceProvider).submitScore(
        userId: widget.userId,
        gameId: 'invaders',
        score: _game.score,
        metadata: {
          'stage_reached': _game.stageIndex + 1,
          'wave_reached': _game.waveIndex + 1,
          'lives_remaining': _game.lives,
          'nickname': widget.nickname,
        },
      );
    } catch (e) {
      debugPrint('[INVADERS] Score submission failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('INVADERS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart',
            onPressed: () => setState(() => _startNewGame()),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LeaderboardScreen(
                gameId: 'invaders',
                gameTitle: 'INVADERS',
                userId: widget.userId,
              ),
            )),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Game canvas — GestureDetector forwards input to the Flame game
          GestureDetector(
            onPanUpdate: (d) =>
                _game.movePlayerTo(d.globalPosition.dx),
            onTapDown: (d) =>
                _game.movePlayerTo(d.globalPosition.dx),
            child: GameWidget(game: _game),
          ),

          // HUD overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _HudOverlay(game: _game),
            ),
          ),
        ],
      ),
    );
  }
}

// ── HUD overlay ───────────────────────────────────────────────────────────────

class _HudOverlay extends StatefulWidget {
  final InvadersGame game;

  const _HudOverlay({required this.game});

  @override
  State<_HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<_HudOverlay> {
  @override
  void initState() {
    super.initState();
    // Refresh HUD every frame via the game's post-frame hook
    widget.game.images; // ensure game is referenced
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Rebuild HUD every 100ms to reflect live game state
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (_, _) {
        final game = widget.game;
        return Row(
          children: [
            // Lives (hearts)
            Row(
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  i < game.lives ? Icons.favorite : Icons.favorite_border,
                  color: i < game.lives ? colors.error : colors.border,
                  size: 20,
                ),
              )),
            ),
            const Spacer(),
            // Score
            Text(
              '${game.score} pts',
              style: TextStyle(
                color: colors.warning,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            // Stage / Wave
            Text(
              'S${game.stageIndex + 1} W${game.waveIndex + 1}',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
