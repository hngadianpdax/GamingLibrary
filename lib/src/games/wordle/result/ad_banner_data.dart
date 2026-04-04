import 'package:flutter/material.dart';

class AdBannerData {
  final String headline;
  final String subline;
  final String ctaLabel;
  final Color accentColor;
  final IconData icon;

  const AdBannerData({
    required this.headline,
    required this.subline,
    required this.ctaLabel,
    required this.accentColor,
    required this.icon,
  });

  static const List<AdBannerData> pdaxGoldAds = [
    AdBannerData(
      headline: 'OWN GOLD. ON-CHAIN.',
      subline: 'Buy tokenized gold starting at ₱500.',
      ctaLabel: 'GET PDAX GOLD',
      accentColor: Color(0xFFFFC10A),
      icon: Icons.monetization_on_outlined,
    ),
    AdBannerData(
      headline: 'GOLD. SECURED. YOURS.',
      subline: 'BSP-regulated. 1:1 backed. Trade anytime.',
      ctaLabel: 'LEARN MORE',
      accentColor: Color(0xFF39B402),
      icon: Icons.shield_outlined,
    ),
    AdBannerData(
      headline: 'GOLD BEATS INFLATION.',
      subline: 'Diversify your portfolio with PDAX Gold.',
      ctaLabel: 'START NOW',
      accentColor: Color(0xFF5078FF),
      icon: Icons.trending_up,
    ),
  ];
}
