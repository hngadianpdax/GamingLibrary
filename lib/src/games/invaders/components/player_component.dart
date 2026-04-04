import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy_bullet.dart';
import 'player_bullet.dart';

class PlayerComponent extends PositionComponent with CollisionCallbacks {
  static const double shipWidth = 40;
  static const double shipHeight = 36;
  static const double fireInterval = 0.28; // seconds between bullets

  bool isAlive = true;
  double _fireTimer = 0;
  Function()? onHit;

  PlayerComponent({required Vector2 position, this.onHit})
      : super(
          position: position,
          size: Vector2(shipWidth, shipHeight),
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAlive) return;

    _fireTimer += dt;
    if (_fireTimer >= fireInterval) {
      _fireTimer = 0;
      _fire();
    }
  }

  void _fire() {
    parent?.add(PlayerBullet(
      position: Vector2(position.x, position.y - shipHeight),
    ));
  }

  void moveTo(double x) {
    final gameWidth = findGame()?.size.x ?? 400;
    position.x = x.clamp(shipWidth / 2, gameWidth - shipWidth / 2);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyBullet) {
      onHit?.call();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFF5078FF);
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h)
      ..lineTo(w * 0.65, h * 0.75)
      ..lineTo(w / 2, h * 0.85)
      ..lineTo(w * 0.35, h * 0.75)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, bodyPaint);

    // Cockpit
    final cockpitPaint = Paint()..color = const Color(0xFFB0C4FF);
    canvas.drawCircle(Offset(w / 2, h * 0.35), 5, cockpitPaint);

    // Engine glow
    final glowPaint = Paint()..color = const Color(0xFFFFC10A);
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.8, w * 0.12, h * 0.18),
        glowPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.53, h * 0.8, w * 0.12, h * 0.18),
        glowPaint);
  }
}
