import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class ControlPlayer extends SpriteComponent
    with HasGameReference, CollisionCallbacks {
  ControlPlayer() : super(size: Vector2(20, 10), anchor: Anchor.center);
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite('ember.png');

    // position = game.size / 2;
    position = Vector2(0, -10);
    add(CircleHitbox());
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart
    super.onCollisionStart(intersectionPoints, other);
  }
}
