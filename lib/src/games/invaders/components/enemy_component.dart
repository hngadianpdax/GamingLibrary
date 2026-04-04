import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../data/stage_data.dart';
import 'enemy_bullet.dart';
import 'player_bullet.dart';

class EnemyComponent extends PositionComponent with CollisionCallbacks {
  final EnemyType type;
  int hp;
  final double descentSpeed;
  final void Function(EnemyComponent enemy, int points) onKilled;
  final void Function()? onReachedBottom;

  double _shootTimer = 0;
  final _rng = Random();
  double _driftTimer = 0;
  static const double _driftAmplitude = 30;
  static const double _driftSpeed = 1.2;
  double _driftOriginX = 0;
  bool _settled = false;
  static const double _settleSpeed = 120;
  Vector2? _targetPosition;

  EnemyComponent({
    required this.type,
    required Vector2 position,
    required this.descentSpeed,
    required this.onKilled,
    this.onReachedBottom,
    Vector2? targetPosition,
  })  : hp = type.maxHp,
        super(
          position: position,
          size: Vector2.all(type.size),
          anchor: Anchor.center,
        ) {
    _targetPosition = targetPosition;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    _driftOriginX = position.x;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_settled && _targetPosition != null) {
      final diff = _targetPosition! - position;
      final dist = diff.length;
      if (dist < 2) {
        position.setFrom(_targetPosition!);
        _settled = true;
        _driftOriginX = position.x;
      } else {
        final step = min(_settleSpeed * dt, dist.toDouble());
        position += diff.normalized() * step;
      }
      return;
    }

    position.y += descentSpeed * dt;
    _driftTimer += dt;
    position.x = _driftOriginX + sin(_driftTimer * _driftSpeed) * _driftAmplitude;

    final gameHeight = findGame()?.size.y ?? 700;
    if (position.y > gameHeight - 60) {
      onReachedBottom?.call();
      removeFromParent();
      return;
    }

    if (type.canShoot) {
      _shootTimer += dt;
      final interval = type.shootInterval + _rng.nextDouble() * 1.5;
      if (_shootTimer >= interval) {
        _shootTimer = 0;
        _shoot();
      }
    }
  }

  void _shoot() {
    parent?.add(EnemyBullet(
      position: Vector2(position.x, position.y + size.y / 2),
    ));
  }

  void hit() {
    hp--;
    if (hp <= 0) {
      onKilled(this, type.points);
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
    final s = size.x;
    _renderBody(canvas, s);
    _renderHpDots(canvas, s);
  }

  void _renderBody(Canvas canvas, double s) {
    final color = _bodyColor();
    final paint = Paint()..color = color;
    final darkPaint = Paint()..color = color.withValues(alpha: 0.6);

    switch (type) {
      case EnemyType.level1:
        final path = Path()
          ..moveTo(s / 2, 0)
          ..lineTo(s, s / 2)
          ..lineTo(s / 2, s)
          ..lineTo(0, s / 2)
          ..close();
        canvas.drawPath(path, paint);

      case EnemyType.level2:
        final cx = s / 2, cy = s / 2, r = s / 2 - 1;
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * pi / 180;
          final x = cx + r * cos(angle);
          final y = cy + r * sin(angle);
          if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
        }
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(cx, cy), r * 0.35, darkPaint);

      case EnemyType.level3:
        final cx = s / 2, cy = s / 2;
        final outer = s / 2 - 1;
        final inner = s / 4;
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final angle = i * 45 * pi / 180;
          final r = i.isEven ? outer : inner;
          final x = cx + r * cos(angle - pi / 2);
          final y = cy + r * sin(angle - pi / 2);
          if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
        }
        path.close();
        canvas.drawPath(path, paint);

      case EnemyType.boss:
        break;
    }
  }

  Color _bodyColor() {
    switch (type) {
      case EnemyType.level1: return const Color(0xFF39B402);
      case EnemyType.level2: return const Color(0xFFFFC10A);
      case EnemyType.level3: return const Color(0xFFFF325F);
      case EnemyType.boss:   return const Color(0xFFAA00FF);
    }
  }

  void _renderHpDots(Canvas canvas, double s) {
    if (type.maxHp <= 1) return;
    const dotR = 3.0;
    const spacing = 8.0;
    final totalW = type.maxHp * dotR * 2 + (type.maxHp - 1) * (spacing - dotR * 2);
    var x = (s - totalW) / 2 + dotR;
    for (int i = 0; i < type.maxHp; i++) {
      final filled = i < hp;
      final dotPaint = Paint()
        ..color = filled ? const Color(0xFFFFFFFF) : const Color(0x55FFFFFF);
      canvas.drawCircle(Offset(x, s + 5), dotR, dotPaint);
      x += spacing;
    }
  }
}
