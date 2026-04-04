import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy_component.dart';
import 'boss_component.dart';

class PlayerBullet extends RectangleComponent with CollisionCallbacks {
  static const double speed = 500;

  PlayerBullet({required Vector2 position})
      : super(
          position: position,
          size: Vector2(4, 14),
          anchor: Anchor.bottomCenter,
          paint: Paint()..color = const Color(0xFF5078FF),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= speed * dt;
    if (position.y < -size.y) removeFromParent();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyComponent || other is BossComponent) {
      removeFromParent();
    }
  }
}
