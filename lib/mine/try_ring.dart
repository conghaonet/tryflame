import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart' hide Timer;
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, Timer;
import 'package:flutter/material.dart';
import 'package:tryflame/stories/bridge_libraries/forge2d/utils/boundaries.dart';

void main() {
  runApp(GameWidget(game: TryRing()));
}

class TryRing extends Forge2DGame with HasTappables {
  TryRing() : super(gravity: Vector2.zero());
  @override
  Future<void>? onLoad() async {
    await add(FpsTextComponent()..position = Vector2(24, 28)..priority = 0);
    await addAll(createBoundaries(this));
  }
  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    if(!info.handled) {
      final velocity = (Vector2.random() - Vector2.random()) * 20;
      Future(() async {
        await add(RingComponent(info.eventPosition.game, linearVelocity: velocity));
      });
    }
  }
}

class RingComponent extends BodyComponent with Tappable {
  static const jointCount = 8;
  final Vector2 position;
  final double ringRadius = 8.0;
  final Vector2? linearVelocity;
  Timer? spawnTimer;

  RingComponent(this.position, {this.linearVelocity, super.priority = 1});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await add(ColorfulRing(radius: ringRadius));
  }
  @override
  void onMount() {
    super.onMount();
    _showParticles();
    /// Spawn new particles every second
    spawnTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _showParticles();
    });
    Timer.periodic(const Duration(milliseconds: 750), (_) {
      _showParticles();
    });
  }
  void _showParticles() {
    for (var i = 0; i < jointCount; i++) {
      final angle = (i / jointCount) * math.pi * 2;
      final x = (ringRadius - 0.5) * math.sin(angle);
      final y = (ringRadius - 0.5)  * math.cos(angle);
      add(ParticleSystemComponent(
        priority: 0,
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
      count: 2,
      generator: (i) {
        final initialSpeed = (Vector2.random() - Vector2.random())..multiply(Vector2.all(5.0));
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
                Paint()..color = Colors.red,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Body createBody() {
    paint.color = Colors.transparent;
    final fixtureDef = FixtureDef(
      CircleShape()..radius = ringRadius,
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
}

class ColorfulRing extends CircleComponent {
  ColorfulRing({super.radius}): super(anchor: Anchor.center,) {
    super.paint = Paint()
      ..color = const Color(0x00FF0000);
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Paint subPaintA = Paint()..color = const Color(0x44FF0000)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle((size / 2).toOffset(), radius, subPaintA);
    Paint subPaintB = Paint()..color = const Color(0x77FF0000)..style = PaintingStyle.stroke..strokeWidth = 1.1;
    canvas.drawCircle((size / 2).toOffset(), radius, subPaintB);
    Paint subPaintC = Paint()..color = const Color(0xAAFF0000)..style = PaintingStyle.stroke..strokeWidth = 0.7;
    canvas.drawCircle((size / 2).toOffset(), radius, subPaintC);
    Paint myPaint = Paint()..color = const Color(0xFFFFFFFF)..style = PaintingStyle.stroke..strokeWidth = 0.3;
    canvas.drawCircle((size / 2).toOffset(), radius, myPaint);
  }
}
