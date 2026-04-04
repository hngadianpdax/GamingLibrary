import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/services/providers.dart';
import '../games/wordle/wordle_screen.dart';
import '../games/memory/memory_screen.dart';
import 'leaderboard_screen.dart';
import 'nickname_screen.dart';
import 'partner_token_data.dart';

class GamesHubScreen extends ConsumerWidget {
  final String userId;
  final VoidCallback? onClose;

  const GamesHubScreen({super.key, required this.userId, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final playerAsync = ref.watch(playerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('PDAX ARCADE'),
        backgroundColor: colors.surface,
        leading: onClose != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                onPressed: onClose,
              )
            : null,
        actions: [
          playerAsync.whenOrNull(
            data: (player) => player != null
                ? TextButton.icon(
                    onPressed: () => _openNicknameEdit(context, ref),
                    icon: Icon(Icons.person, color: colors.textSecondary, size: 16),
                    label: Text(
                      player.nickname,
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                    ),
                  )
                : const SizedBox.shrink(),
          ) ?? const SizedBox.shrink(),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: colors.textSecondary,
            ),
            tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: playerAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (e, st) {
          debugPrint('[HUB] Profile load error: $e\n$st');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: colors.error, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading profile\n$e',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(playerProvider.notifier).load(userId),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (player) {
          if (player == null) {
            return NicknameScreen(
              userId: userId,
              onDone: () => ref.read(playerProvider.notifier).load(userId),
            );
          }
          return _GameGrid(userId: userId, nickname: player.nickname);
        },
      ),
    );
  }

  void _openNicknameEdit(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NicknameScreen(
          userId: userId,
          isEditing: true,
          onDone: () {
            ref.read(playerProvider.notifier).load(userId);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _GameGrid extends StatelessWidget {
  final String userId;
  final String nickname;

  const _GameGrid({required this.userId, required this.nickname});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final games = [
      _GameCard(
        id: 'tradle',
        title: 'TRADLE',
        description: 'Guess the 5-letter finance & trading term in 6 tries.',
        icon: Icons.grid_on,
        accentColor: colors.success,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => WordleScreen(userId: userId, nickname: nickname),
        )),
        onLeaderboard: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LeaderboardScreen(gameId: 'tradle', gameTitle: 'TRADLE', userId: userId),
        )),
      ),
      _GameCard(
        id: 'memory',
        title: 'MEMORY GRID',
        description: 'Memorize the tiles. Recall them. Survive.',
        icon: Icons.grid_view,
        accentColor: colors.warning,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MemoryScreen(userId: userId, nickname: nickname),
        )),
        onLeaderboard: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LeaderboardScreen(
            gameId: 'memory',
            gameTitle: 'MEMORY GRID',
            userId: userId,
          ),
        )),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'SELECT A GAME',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 2,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 16),
        ...games,
        const SizedBox(height: 8),
        const _PartnerTokenStrip(),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onLeaderboard;

  const _GameCard({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    required this.onLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    letterSpacing: 1.5,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(description, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              ...[
                const SizedBox(height: 16),
                Divider(color: colors.border, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                        child: const Text('PLAY'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: onLeaderboard,
                      icon: const Icon(Icons.leaderboard, size: 16),
                      label: const Text('Scores'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Partner Token Strip ───────────────────────────────────────────────────────

class _PartnerTokenStrip extends StatefulWidget {
  const _PartnerTokenStrip();

  @override
  State<_PartnerTokenStrip> createState() => _PartnerTokenStripState();
}

class _PartnerTokenStripState extends State<_PartnerTokenStrip> {
  late final ScrollController _scrollController;
  late final Timer _timer;
  int _currentIndex = 0;

  static const _cardWidth = 148.0;
  static const _cardSpacing = 10.0;
  static const _scrollDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final tokens = PartnerTokenData.featured;
      final next = (_currentIndex + 1) % tokens.length;
      final offset = next * (_cardWidth + _cardSpacing);
      _scrollController.animateTo(
        offset,
        duration: _scrollDuration,
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = next);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = PartnerTokenData.featured;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'FEATURED TOKENS',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
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
        const SizedBox(height: 10),
        SizedBox(
          height: 124,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: tokens.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: _cardSpacing),
            itemBuilder: (_, index) => _TokenCard(
              token: tokens[index],
              isActive: index == _currentIndex,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(tokens.length, (i) {
            final isActive = i == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? tokens[_currentIndex].accentColor
                    : colors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TokenCard extends StatelessWidget {
  final PartnerTokenData token;
  final bool isActive;

  const _TokenCard({required this.token, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: token.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 148,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? token.accentColor.withValues(alpha: 0.6)
                : colors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: token.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(token.icon, color: token.accentColor, size: 18),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: token.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TRADE',
                    style: TextStyle(
                      color: token.accentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              token.ticker,
              style: TextStyle(
                color: token.accentColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              token.name,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              token.price,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
