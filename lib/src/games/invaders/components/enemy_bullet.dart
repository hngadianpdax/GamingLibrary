import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player_component.dart';

class EnemyBullet extends RectangleComponent with CollisionCallbacks {
  static const double speed = 280;

  EnemyBullet({required Vector2 position})
      : super(
          position: position,
          size: Vector2(4, 12),
          anchor: Anchor.topCenter,
          paint: Paint()..color = const Color(0xFFFF325F),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    if (position.y > (findGame()?.size.y ?? 900) + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      removeFromParent();
    }
  }
}
