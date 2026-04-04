import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy_bullet.dart';
import 'player_bullet.dart';

class BossComponent extends PositionComponent with CollisionCallbacks {
  final int maxHp;
  int hp;
  final int stage;
  final void Function(int points) onKilled;
  final void Function()? onReachedBottom;

  double _shootTimer = 0;
  double _moveDirection = 1;
  bool _phase2 = false;

  static const double bossSize = 64;
  static const double moveSpeed = 90;
  static const double shootInterval1 = 1.2;
  static const double shootInterval2 = 0.7;

  BossComponent({
    required Vector2 position,
    required this.maxHp,
    required this.stage,
    required this.onKilled,
    this.onReachedBottom,
  })  : hp = maxHp,
        super(
          position: position,
          size: Vector2.all(bossSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_phase2 && hp <= maxHp ~/ 2) {
      _phase2 = true;
    }

    // Horizontal patrol
    final gameWidth = findGame()?.size.x ?? 400;
    position.x += _moveDirection * moveSpeed * (_phase2 ? 1.5 : 1.0) * dt;
    if (position.x >= gameWidth - bossSize / 2) {
      position.x = gameWidth - bossSize / 2;
      _moveDirection = -1;
    } else if (position.x <= bossSize / 2) {
      position.x = bossSize / 2;
      _moveDirection = 1;
    }

    // Slow descent
    position.y += 12 * dt;
    final gameHeight = findGame()?.size.y ?? 700;
    if (position.y > gameHeight - 80) {
      onReachedBottom?.call();
      removeFromParent();
      return;
    }

    // Shooting
    _shootTimer += dt;
    final interval = _phase2 ? shootInterval2 : shootInterval1;
    if (_shootTimer >= interval) {
      _shootTimer = 0;
      _shoot();
    }
  }

  void _shoot() {
    if (_phase2) {
      // Spread shot: 3 bullets
      for (final angle in [-0.3, 0.0, 0.3]) {
        final dir = Vector2(sin(angle), cos(angle));
        parent?.add(_DirectedBullet(
          position: Vector2(position.x, position.y + bossSize / 2),
          direction: dir,
        ));
      }
    } else {
      parent?.add(EnemyBullet(
        position: Vector2(position.x, position.y + bossSize / 2),
      ));
    }
  }

  void hit() {
    hp--;
    if (hp <= 0) {
      onKilled(200);
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerBullet) {
      hit();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final s = bossSize;
    final phase2Color =
        _phase2 ? const Color(0xFFFF325F) : const Color(0xFFAA00FF);
    final paint = Paint()..color = phase2Color;
    final darkPaint = Paint()..color = phase2Color.withValues(alpha: 0.5);

    // Outer octagon
    final cx = s / 2, cy = s / 2, r = s / 2 - 2;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * 45 * pi / 180 - pi / 8;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Inner circle
    canvas.drawCircle(Offset(cx, cy), r * 0.4, darkPaint);

    // Eye
    final eyePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx, cy), r * 0.18, eyePaint);
    final pupilPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawCircle(Offset(cx, cy), r * 0.09, pupilPaint);

    // HP bar
    _renderHpBar(canvas, s);
  }

  void _renderHpBar(Canvas canvas, double s) {
    const barH = 6.0;
    const barY = -14.0;
    final barW = s;
    final bgPaint = Paint()..color = const Color(0x55FFFFFF);
    final fgPaint = Paint()
      ..color = _phase2 ? const Color(0xFFFF325F) : const Color(0xFF39B402);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, barY, barW, barH), const Radius.circular(3)),
      bgPaint,
    );
    final fillW = (hp / maxHp).clamp(0.0, 1.0) * barW;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, barY, fillW, barH), const Radius.circular(3)),
      fgPaint,
    );
  }
}

// Directed bullet for boss phase 2 spread shot
class _DirectedBullet extends PositionComponent {
  final Vector2 direction;
  static const double speed = 260;

  _DirectedBullet({required Vector2 position, required this.direction})
      : super(
          position: position,
          size: Vector2(4, 12),
          anchor: Anchor.topCenter,
        );

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;
    final game = findGame();
    if (game != null &&
        (position.y > game.size.y + 20 ||
            position.x < -20 ||
            position.x > game.size.x + 20)) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFF325F),
    );
  }
}
