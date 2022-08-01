import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:tryflame/stories/bridge_libraries/forge2d/utils/boundaries.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

void main() {
  runApp(GameWidget(game: BlobExample()));
}

class BlobExample extends Forge2DGame with TapDetector {
  static const String description = '''
    In this example we show the power of joints by showing interactions between
    bodies tied together.
    
    Tap the screen to add boxes that will bounce on the "blob" in the center.
  ''';
  static const bodiesCount = 30;
  @override
  Future<void> onLoad() async {
    final worldCenter = screenToWorld(size * camera.zoom / 2);
    final blobCenter = worldCenter + Vector2(0, 0);
    final blobRadius = Vector2.all(6.0);
    final velocity = (Vector2.random() - Vector2.random()) * 200;

    addAll(createBoundaries(this));
    // add(Ground(worldCenter));
    final jointDef = ConstantVolumeJointDef()
      ..frequencyHz = 0.0
      ..dampingRatio = 0.0
      ..collideConnected = false;

    await addAll([
      for (var i = 0; i < bodiesCount; i++) BlobPart(i, jointDef, blobRadius, blobCenter, bodiesCount, velocity)
    ]);
    world.createJoint(ConstantVolumeJoint(world, jointDef));
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    add(FallingBox(details.eventPosition.game));
  }
}

class Ground extends BodyComponent {
  final Vector2 worldCenter;

  Ground(this.worldCenter);

  @override
  Body createBody() {
    final shape = PolygonShape();
    shape.setAsBoxXY(20.0, 0.4);
    final fixtureDef = FixtureDef(shape, friction: 0.2);

    final bodyDef = BodyDef(position: worldCenter.clone());
    final ground = world.createBody(bodyDef);
    ground.createFixture(fixtureDef);

    shape.setAsBox(0.4, 20.0, Vector2(-10.0, 0.0), 0.0);
    ground.createFixture(fixtureDef);
    shape.setAsBox(0.4, 20.0, Vector2(10.0, 0.0), 0.0);
    ground.createFixture(fixtureDef);
    return ground;
  }
}

class BlobPart extends BodyComponent {
  final ConstantVolumeJointDef jointDef;
  final int bodyNumber;
  final Vector2 blobRadius;
  final Vector2 blobCenter;
  final int bodiesCount;
  final Vector2 velocity;

  BlobPart(
      this.bodyNumber,
      this.jointDef,
      this.blobRadius,
      this.blobCenter,
      this.bodiesCount,
      this.velocity,
      );

  @override
  Body createBody() {
    // const nBodies = 20.0;
    const bodyRadius = 0.5;
    final angle = (bodyNumber / bodiesCount) * math.pi * 2;
    final x = blobCenter.x + blobRadius.x * math.sin(angle);
    final y = blobCenter.y + blobRadius.y * math.cos(angle);

    final bodyDef = BodyDef(
      fixedRotation: false,
      position: Vector2(x, y),
      type: BodyType.dynamic,
      linearVelocity: velocity,
      // linearVelocity: (Vector2.random() - Vector2.random()) * 200,
    );

    final shape = CircleShape()..radius = bodyRadius;
    final fixtureDef = FixtureDef(
      shape,
      density: 501.1,
      friction: 0.0,
      restitution: 1.0,
    );
    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef);
    jointDef.addBody(body);
    return body;
  }
}

class FallingBox extends BodyComponent {
  final Vector2 position;

  FallingBox(this.position);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.kinematic,
      position: position,
    );
    final shape = PolygonShape()..setAsBoxXY(4, 4);
    final body = world.createBody(bodyDef);
    body.createFixtureFromShape(shape, 1.0);
    return body;
  }
}
