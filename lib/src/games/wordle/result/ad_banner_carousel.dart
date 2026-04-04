import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'ad_banner_data.dart';

class AdBannerCarousel extends StatefulWidget {
  final List<AdBannerData> ads;

  const AdBannerCarousel({
    super.key,
    this.ads = AdBannerData.pdaxGoldAds,
  });

  @override
  State<AdBannerCarousel> createState() => _AdBannerCarouselState();
}

class _AdBannerCarouselState extends State<AdBannerCarousel> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final next = (_currentPage + 1) % widget.ads.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.ads.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _AdBannerTile(ad: widget.ads[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.ads.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? widget.ads[_currentPage].accentColor
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

class _AdBannerTile extends StatelessWidget {
  final AdBannerData ad;

  const _AdBannerTile({required this.ad});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ad.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ad.accentColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(ad.icon, color: ad.accentColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.headline,
                  style: TextStyle(
                    color: ad.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ad.subline,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ad.accentColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ad.ctaLabel,
              style: const TextStyle(
                color: Color(0xFF112756),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
