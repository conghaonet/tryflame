import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, Timer;
import 'package:flutter/material.dart';
import 'package:tryflame/stories/bridge_libraries/forge2d/utils/boundaries.dart';
void main() {
  runApp(GameWidget(game: TryParticle()));
}

class TryParticle extends Forge2DGame with HasTappables {
  final _fpsComponent = FpsTextComponent();
  final List<Wall> walls = [];

  @override
  Future<void> onLoad() async {
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
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    if(!info.handled) {
      final velocity = (Vector2.random() - Vector2.random()) * 20;
      Future(() async {
        final centerComponent = EntityComponent(info.eventPosition.game, linearVelocity: velocity);
        await add(centerComponent);
      });
    }
  }
}

class EntityComponent extends BodyComponent with Tappable, ScaleProvider {
  static const jointCount = 24;
  final Vector2 entityPosition;
  final double circleShapeRadius = 6.0;
  final entityRadius = 6.0;
  final Color? circleShapeColor;
  final Vector2? linearVelocity;
  Timer? spawnTimer;
  Vector2 get cellSize => gameRef.size / 3.0;
  final Random rnd = Random();
  @override Vector2 scale = Vector2(1, 1);
  ConstantVolumeJoint? _constantVolumeJoint;
  final constantVolumeJointDef = ConstantVolumeJointDef()
    ..frequencyHz = 0.0
    ..dampingRatio = 0.0;

  EntityComponent(this.entityPosition, {this.circleShapeColor, this.linearVelocity}) {
    priority = 1;
    paint = Paint()..color = circleShapeColor ?? ColorExtension.random(withAlpha: 1.0, base: 20);
  }

  @override
  void onMount() {
    super.onMount();
    _showParticles();
    /// Spawn new particles every second
    spawnTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _showParticles();
    });
    Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _showParticles();
    });
  }
  void _showParticles() {
    for (var i = 0; i < jointCount; i++) {
      final angle = (i / jointCount) * math.pi * 2;
      final x = (entityRadius - 0.5) * math.sin(angle);
      final y = (entityRadius - 0.5)  * math.cos(angle);
      add(ParticleSystemComponent(
        particle: TranslatedParticle(
          lifespan: 1,
          offset: Vector2(x, y),
          child: _fireworkParticle(),
          // child: CircleParticle(paint: Paint()..color = Colors.white, radius: 0.2,),
        ),
      ));
    }
  }

  Particle _fireworkParticle() {
    return Particle.generate(
      count: 4,
      generator: (i) {
        final initialSpeed = (Vector2.random() - Vector2.random())..multiply(Vector2.all(10.0));
        final deceleration = initialSpeed * 0.1;
        final gravity = Vector2(0, 0);
        return AcceleratedParticle(
          speed: initialSpeed,
          acceleration: deceleration + gravity,
          child: ComputedParticle(
            renderer: (canvas, particle) {
              canvas.drawCircle(
                Offset.zero,
                0.1,
                paint,
              );
            },
          ),
        );
      },
    );
  }

  @override
  void onRemove() {
    super.onRemove();
    spawnTimer?.cancel();
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
    double targetRadius = radius * scale.x;
    super.renderCircle(canvas, center, targetRadius);
    final lineRotation = Offset(0, targetRadius);
    canvas.drawLine(center, center + lineRotation, Paint()..color = Colors.white);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    add(ScaleEffect.to(Vector2.all(0), EffectController(duration: 0.5, curve: Curves.bounceOut,), onComplete: () {
      removeFromParent();
    }));
    spawnTimer?.cancel();
    info.handled = true;
    return true;
  }

}
