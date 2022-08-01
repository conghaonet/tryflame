import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:tryflame/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'dart:math' as math;
import '../stories/bridge_libraries/forge2d/utils/balls.dart';

void main() {
  runApp(GameWidget(game: MyAnimatedBodyExample()));
}

class MyAnimatedBodyExample extends Forge2DGame with HasTappables, HasGameRef {
  @override
  bool debugMode = true;
  // MyAnimatedBodyExample(): super(zoom: 1);
  @override
  Future<void>? onLoad() async {
    addAll(createBoundaries(this));
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
/*
    final position = event.canvasPosition /10;
    if (math.Random().nextInt(10) < 2) {
      add(WhiteBall(position));
    } else {
      add(Ball(position));
    }
*/
    if(!info.handled) {
      add(MyRingBody(info.eventPosition.game));
    }
    debugPrint('--------MyFlame---------');
  }
}

class MyRingBody extends BodyComponent with Tappable {
  final Vector2 position;
  MyRingBody(this.position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // add(MyRing(position));
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 3;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 1.0,
      density: 1.0,
      friction: 0.0,
    );

    final velocity = (Vector2.random() - Vector2.random()) * 400;
    final bodyDef = BodyDef(
      fixedRotation: true,
      position: position,
      angle: 0,
      linearVelocity: velocity,
      type: BodyType.dynamic,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    debugPrint('====MyRingBody====');
    info.handled = true;
    removeFromParent();
    return false;
  }

}

class MyRing extends CircleComponent {
  @override
  MyRing(Vector2 position)
      : super(
    position: Vector2.zero(),
    anchor: Anchor.center,
    radius: 4.5,
    // paint: Paint()..color = Colors.red,
    paint: Paint()..color = const Color(0xffffffff)..style = PaintingStyle.stroke..strokeWidth = 1,
  );

}