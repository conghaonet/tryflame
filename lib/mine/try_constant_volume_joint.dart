import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:tryflame/stories/bridge_libraries/forge2d/utils/boundaries.dart';

void main() {
  runApp(GameWidget(game: TryConstantVolumeJoint()));
}

class TryConstantVolumeJoint extends Forge2DGame with TapDetector {
  static const blobCount = 30;
  final blobRadius = Vector2.all(6.0);
  final velocity = (Vector2.random() - Vector2.random()) * 200;
  final List<Wall> walls = [];
  @override
  Future<void>? onLoad() async {
    walls.addAll(createBoundaries(this));
    await addAll(walls);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if(walls.isNotEmpty) {
      removeAll(walls);
      walls.clear();
      walls.addAll(createBoundaries(this));
      addAll(walls);
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    final jointDef = ConstantVolumeJointDef()
      ..frequencyHz = 0.0
      ..dampingRatio = 0.0
      ..collideConnected = false;

    Future(() async {
      final centerComponent = CircleBodyComponent(info.eventPosition.game, color: Colors.yellowAccent,);
      await add(centerComponent);
      await addAll([
        for (var i = 0; i < blobCount; i++) BlobPart(i, jointDef, blobRadius, centerComponent, blobCount, velocity)
      ]);
      if(jointDef.bodies.length >= 2) {
        world.createJoint(ConstantVolumeJoint(world, jointDef));
      }
    });
  }
}

class BlobPart extends BodyComponent {
  final ConstantVolumeJointDef jointDef;
  final int bodyNumber;
  final Vector2 blobRadius;
  final BodyComponent centerComponent;
  final int bodiesCount;
  final Vector2 velocity;

  BlobPart(
      this.bodyNumber,
      this.jointDef,
      this.blobRadius,
      this.centerComponent,
      this.bodiesCount,
      this.velocity,
      );

  @override
  Body createBody() {
    const bodyRadius = 0.5;
    final angle = (bodyNumber / bodiesCount) * math.pi * 2;
    final x = centerComponent.center.x + blobRadius.x * math.sin(angle);
    final y = centerComponent.center.y + blobRadius.y * math.cos(angle);

    final bodyDef = BodyDef(
      fixedRotation: false,
      position: Vector2(x, y),
      type: BodyType.dynamic,
      // linearVelocity: velocity,
      // linearVelocity: (Vector2.random() - Vector2.random()) * 200,
    );

    final shape = CircleShape()..radius = bodyRadius;
    final fixtureDef = FixtureDef(
      shape,
      density: 0.0,
      friction: 0.0,
      restitution: 1.0,
    );
    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef);
    jointDef.addBody(body);
    final distanceJointDef = DistanceJointDef()
      ..length = 1
      ..frequencyHz = 0.0
      ..dampingRatio = 0.0;
    distanceJointDef.initialize(centerComponent.body, body, centerComponent.center, body.position);
    world.createJoint(DistanceJoint(distanceJointDef));
    // jointDef.addBodyAndJoint(body, DistanceJoint(distanceJointDef));
    return body;
  }
}

class CircleBodyComponent extends BodyComponent {
  final Paint whiteLinePaint = Paint()..color = Colors.white;
  final Vector2 position;
  final double radius;
  final Color color;
  CircleBodyComponent(this.position, {this.radius = 2.0, this.color = Colors.white,}) {
    paint = PaintExtension.random(withAlpha: 0.9, base: 20);
  }
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 1,
      density: 0.0,
      friction: 0.0,
    );
    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.0,
      position: position,
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef);
    return body;
  }
  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);
    final lineRotation = Offset(0, radius);
    canvas.drawLine(center, center + lineRotation, whiteLinePaint);
  }
}