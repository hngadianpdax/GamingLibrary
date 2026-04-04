import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaming_library/gaming_library.dart';

void main() {
  runApp(const ProviderScope(child: ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDAX',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const PdaxHomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF39B402),
        secondary: Color(0xFF39B402),
        surface: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF39B402),
        unselectedLabelColor: Color(0xFF9E9E9E),
        indicatorColor: Color(0xFF39B402),
        dividerColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }
}

// ── Constants ─────────────────────────────────────────────────────────────────

const _kGreen = Color(0xFF39B402);

// ── Home Screen ───────────────────────────────────────────────────────────────

class PdaxHomeScreen extends StatelessWidget {
  const PdaxHomeScreen({super.key});

  static const String _demoUserId = '00000000-0000-0000-0000-000000000001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TopBar()),
            SliverToBoxAdapter(child: _BalanceCard()),
            SliverToBoxAdapter(
              child: _QuickActions(
                onArcadeTap: () => GamingLibrary.launch(context, userId: _demoUserId),
              ),
            ),
            SliverToBoxAdapter(child: _GainersLosers()),
            SliverToBoxAdapter(child: _PdaxBanner()),
            SliverToBoxAdapter(child: _FeedSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Icon(Icons.person_outline, size: 20, color: Color(0xFF424242)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _kGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.white, size: 13),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_none, size: 26, color: Color(0xFF424242)),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Balance Card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '₱ 8,000.00',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.remove_red_eye_outlined, size: 20, color: _kGreen),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Today's P&L",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 12, color: _kGreen),
              const SizedBox(width: 4),
              const Text(
                '+₱ 2,435.00 (43.75%)',
                style: TextStyle(
                  fontSize: 12,
                  color: _kGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final VoidCallback onArcadeTap;

  const _QuickActions({required this.onArcadeTap});

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionItem>[
      _ActionItem(label: 'Cash in',     svgAsset: 'assets/icons/cash_in.svg'),
      _ActionItem(label: 'Crypto',      svgAsset: 'assets/icons/crypto.svg'),
      _ActionItem(label: 'Bonds',       svgAsset: 'assets/icons/bonds.svg'),
      _ActionItem(label: 'Gold',        svgAsset: 'assets/icons/gold.svg'),
      _ActionItem(label: 'Hold & Earn', svgAsset: 'assets/icons/hold_and_earn.svg'),
      _ActionItem(label: 'Promos',      svgAsset: 'assets/icons/promos.svg'),
      _ActionItem(label: 'Referral',    svgAsset: 'assets/icons/referral.svg'),
      _ActionItem(label: 'Arcade',      svgAsset: 'assets/icons/arcade.svg', isArcade: true),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        children: actions.map((item) {
          return _ActionTile(
            item: item,
            onTap: item.isArcade ? onArcadeTap : null,
          );
        }).toList(),
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final String svgAsset;
  final bool isArcade;

  const _ActionItem({
    required this.label,
    required this.svgAsset,
    this.isArcade = false,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;
  final VoidCallback? onTap;

  const _ActionTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(item.svgAsset, width: 64, height: 47),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF424242)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Gainers / Losers ──────────────────────────────────────────────────────────

class _GainersLosers extends StatefulWidget {
  @override
  State<_GainersLosers> createState() => _GainersLosersState();
}

class _GainersLosersState extends State<_GainersLosers>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _gainers = [
    ('AAVE', '₱ 5,302.02', '+12.80%'),
    ('BTC',  '₱ 3,753,166.00', '+2.70%'),
    ('ALGO', '₱ 8.04',         '+4.60%'),
    ('APE',  '₱ 56.98',        '+9.20%'),
    ('AVAX', '₱ 1,477.01',     '+2.80%'),
  ];

  static const _losers = [
    ('ETH',  '₱ 197,340.00', '-3.10%'),
    ('SOL',  '₱ 8,220.50',   '-1.80%'),
    ('DOT',  '₱ 302.14',     '-2.40%'),
    ('MATIC','₱ 37.60',      '-5.20%'),
    ('LINK', '₱ 720.88',     '-0.90%'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          TabBar(
            controller: _tab,
            tabs: const [Tab(text: 'Gainers'), Tab(text: 'Losers')],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Crypto',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Current price',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('24h change %',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 240,
            child: TabBarView(
              controller: _tab,
              children: [
                _CryptoList(rows: _gainers, isGainer: true),
                _CryptoList(rows: _losers, isGainer: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CryptoList extends StatelessWidget {
  final List<(String, String, String)> rows;
  final bool isGainer;

  const _CryptoList({required this.rows, required this.isGainer});

  @override
  Widget build(BuildContext context) {
    final pillColor = isGainer ? _kGreen : const Color(0xFFE53935);
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final (symbol, price, change) = rows[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(symbol,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Expanded(
                flex: 3,
                child: Text(price,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      change,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── PDAX Banner ───────────────────────────────────────────────────────────────

class _PdaxBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2A5C), Color(0xFF1A3A7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt, color: _kGreen, size: 14),
                      SizedBox(width: 4),
                      Text('PDAX',
                          style: TextStyle(
                              color: _kGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Welcome to the new',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('PDAX Trading Platform',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_android, color: Colors.white54, size: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feed Section ──────────────────────────────────────────────────────────────

class _FeedSection extends StatelessWidget {
  static const _articles = [
    (
      'PDAXScope',
      "PDAXScope: SEC issues 'FOMO' warning ahead of spot BTC ETF decision",
      'Jan 12, 2024',
    ),
    (
      'Tokens • BTC • Trading',
      'PDAXScope: Bitcoin Surges, Ethereum Eyes ETFs',
      'Jan 12, 2024',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Feed',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A))),
              Text('View more',
                  style: TextStyle(
                      fontSize: 13,
                      color: _kGreen,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _articles
                .map((a) => Expanded(child: _FeedCard(article: a)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final (String, String, String) article;

  const _FeedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final (tags, title, date) = article;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1A3060),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: const Center(
              child: Icon(Icons.newspaper, color: Colors.white38, size: 32),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TagRow(tags: tags.split(' • ')),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A)),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(date,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  final List<String> tags;
  const _TagRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags
          .map((t) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(t,
                    style: const TextStyle(
                        fontSize: 9,
                        color: _kGreen,
                        fontWeight: FontWeight.w600)),
              ))
          .toList(),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: _kGreen,
      unselectedItemColor: Colors.grey.shade500,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.candlestick_chart_outlined), label: 'Markets'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Portfolio'),
      ],
    );
  }
}
