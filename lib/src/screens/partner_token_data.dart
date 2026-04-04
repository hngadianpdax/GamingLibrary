import 'package:flutter/material.dart';

class PartnerTokenData {
  final String ticker;
  final String name;
  final String tagline;
  final String price;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? onTap;

  const PartnerTokenData({
    required this.ticker,
    required this.name,
    required this.tagline,
    required this.price,
    required this.accentColor,
    required this.icon,
    this.onTap,
  });

  static const List<PartnerTokenData> featured = [
    PartnerTokenData(
      ticker: 'USDT0',
      name: 'Tether on zkSync',
      tagline: 'Native stablecoin, 1:1 USD',
      price: '\$1.0001',
      accentColor: Color(0xFF26A17B),
      icon: Icons.attach_money,
    ),
    PartnerTokenData(
      ticker: 'PDAX Gold',
      name: 'PDAX Gold Token',
      tagline: 'BSP-regulated. 1:1 gold-backed.',
      price: '₱4,820',
      accentColor: Color(0xFFFFC10A),
      icon: Icons.monetization_on_outlined,
    ),
    PartnerTokenData(
      ticker: 'USDT',
      name: 'Tether',
      tagline: 'Most liquid stablecoin',
      price: '\$1.0000',
      accentColor: Color(0xFF26A17B),
      icon: Icons.currency_exchange,
    ),
    PartnerTokenData(
      ticker: 'SOL',
      name: 'Solana',
      tagline: 'High-speed Layer 1 blockchain',
      price: '\$148.32',
      accentColor: Color(0xFF9945FF),
      icon: Icons.flash_on,
    ),
  ];
}
