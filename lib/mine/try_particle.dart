import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(GameWidget(game: TryParticle()));
}

class TryParticle extends FlameGame {
  final rnd = Random();
  Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 100;


  @override
  Future<void> onLoad() async {

    await images.load('zap.png');
    add(
      ParticleSystemComponent(
        particle: AcceleratedParticle(
          lifespan: 5,
          // Will fire off in the center of game canvas
          position: canvasSize/2,
          // With random initial speed of Vector2(-100..100, 0..-100)
          speed: Vector2(rnd.nextDouble() * 200 - 100, -rnd.nextDouble() * 100),
          // Accelerating downwards, simulating "gravity"
          // speed: Vector2(0, 100),
          child: CircleParticle(
            radius: 9.0,
            paint: Paint()..color = Colors.red,
          ),
        ),
      ),
    );
  }

}