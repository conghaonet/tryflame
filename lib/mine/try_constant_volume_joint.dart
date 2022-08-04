import 'dart:math' as math;

import 'package:flame/components.dart';
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
  static const blobCount = 24;
  final blobRadius = 6.0;
  final _fpsComponent = FpsTextComponent();

  final List<Wall> walls = [];
  TryConstantVolumeJoint() : super(gravity: Vector2.zero());
  @override
  Future<void>? onLoad() async {
    await add(_fpsComponent);
    walls.addAll(createBoundaries(this));
    await addAll(walls);

  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    debugPrint('${camera.zoom}');
    debugPrint('${camera.gameSize}');
    _fpsComponent.position = Vector2(24, 28);
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
      ..dampingRatio = 0.0;
    final velocity = (Vector2.random() - Vector2.random()) * 20;
    Future(() async {
      final centerComponent = CenterPart(info.eventPosition.game, color: Colors.yellowAccent, linearVelocity: velocity);
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
  final double blobRadius;
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
    const bodyRadius = 0.6;
    final angle = (bodyNumber / bodiesCount) * math.pi * 2;
    final x = centerComponent.center.x + blobRadius * math.sin(angle);
    final y = centerComponent.center.y + blobRadius * math.cos(angle);

    final bodyDef = BodyDef(
      fixedRotation: false,
      position: Vector2(x, y),
      type: BodyType.dynamic,
      // linearVelocity: velocity,
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
    return body;
  }
}

class CenterPart extends BodyComponent {
  final Paint whiteLinePaint = Paint()..color = Colors.white;
  final Vector2 position;
  final double radius;
  final Color color;
  final Vector2? linearVelocity;
  CenterPart(this.position, {this.radius = 5.8, this.color = Colors.white, this.linearVelocity}) {
    paint = PaintExtension.random(withAlpha: 0.9, base: 20);
  }
  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 1,
      density: 20.0,
      friction: 0.0,
    );
    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.0,
      position: position,
      type: BodyType.dynamic,
      linearVelocity: linearVelocity,
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