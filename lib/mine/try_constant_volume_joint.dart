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
    final velocity = (Vector2.random() - Vector2.random()) * 20;
    Future(() async {
      final centerComponent = EntityComponent(info.eventPosition.game, linearVelocity: velocity);
      await add(centerComponent);
    });
  }
}

class BlobComponent extends BodyComponent {
  final ConstantVolumeJointDef constantVolumeJointDef;
  final int jointIndex;
  final double entityRadius;
  final BodyComponent centerComponent;
  final int jointCount;

  BlobComponent(
      this.jointIndex,
      this.constantVolumeJointDef,
      this.entityRadius,
      this.centerComponent,
      this.jointCount,
      );

  @override
  Body createBody() {
    const bodyRadius = 0.6;
    final angle = (jointIndex / jointCount) * math.pi * 2;
    final x = centerComponent.center.x + entityRadius * math.sin(angle);
    final y = centerComponent.center.y + entityRadius * math.cos(angle);

    final bodyDef = BodyDef(
      fixedRotation: false,
      position: Vector2(x, y),
      type: BodyType.dynamic,
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
    constantVolumeJointDef.addBody(body);
    final distanceJointDef = DistanceJointDef()
      ..length = 1
      ..frequencyHz = 0.0
      ..dampingRatio = 0.0;
    distanceJointDef.initialize(centerComponent.body, body, centerComponent.body.position, body.position);
    world.createJoint(DistanceJoint(distanceJointDef));
    return body;
  }
}

class EntityComponent extends BodyComponent {
  static const jointCount = 24;
  final Vector2 entityPosition;
  final double circleShapeRadius = 5.8;
  final entityRadius = 6.0;
  final Color? circleShapeColor;
  final Vector2? linearVelocity;
  final constantVolumeJointDef = ConstantVolumeJointDef()
    ..frequencyHz = 0.0
    ..dampingRatio = 0.0;

  EntityComponent(this.entityPosition, {this.circleShapeColor, this.linearVelocity}) {
    if (circleShapeColor == null) {
      paint = PaintExtension.random(withAlpha: 0.9, base: 20);
    } else {
      paint = Paint()..color = circleShapeColor!;
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await gameRef.addAll([
      for (var i = 0; i < jointCount; i++) BlobComponent(i, constantVolumeJointDef, entityRadius, this, jointCount,)
    ]);
    if(constantVolumeJointDef.bodies.length >= 2) {
      world.createJoint(ConstantVolumeJoint(world, constantVolumeJointDef));
    }
  }
  @override
  Body createBody() {
    final shape = CircleShape()..radius = circleShapeRadius;
    final fixtureDef = FixtureDef(
      shape,
      restitution: 1,
      density: 20.0,
      friction: 0.0,
    );
    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.0,
      position: entityPosition,
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
    canvas.drawLine(center, center + lineRotation, Paint()..color = Colors.white);
  }
}