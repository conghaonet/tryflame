import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:tryflame/stories/bridge_libraries/forge2d/utils/boundaries.dart';

void main() {
  runApp(GameWidget(game: AnimatedBodyExample()));
}

class AnimatedBodyExample extends Forge2DGame with TapDetector {
  static const String description = '''
    In this example we show how to add an animated chopper, which is created
    with a SpriteAnimationComponent, on top of a BodyComponent.
    
    Tap the screen to add more choppers.
  ''';

  AnimatedBodyExample() : super(gravity: Vector2.zero());

  late ui.Image chopper;
  late SpriteAnimation animation;

  @override
  Future<void> onLoad() async {
    chopper = await images.load('animations/ring.png');

    animation = SpriteAnimation.fromFrameData(
      chopper,
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(840),
        stepTime: 0.1,
      ),
    );

    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final position = info.eventPosition.game;
    final spriteSize = Vector2.all(10);
    final animationComponent = SpriteAnimationComponent(
      animation: animation,
      size: spriteSize,
      anchor: Anchor.center,
    );
    add(ChopperBody(position, animationComponent));
    // add(TappableText(position));
  }
}

class ChopperBody extends BodyComponent {
  final Vector2 position;
  final Vector2 size;
  late final TextComponent textComponent;
  late final TextPaint _textPaint;

  ChopperBody(
      this.position,
      PositionComponent component,
      ) : size = component.size {
    renderBody = false;
    add(component);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _textPaint = TextPaint(style: const TextStyle(color: Colors.red, fontSize: 2));
    textComponent = TextComponent(
      text: "123",
      textRenderer: _textPaint,
      anchor: Anchor.center,
    );
    add(textComponent);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = size.x / 4;
    final fixtureDef = FixtureDef(
      shape,
      userData: this, // To be able to determine object in collision
      restitution: 1.0,
      density: 1.0,
      friction: 0.0,
    );

    final velocity = (Vector2.random() - Vector2.random()) * 200;
    final bodyDef = BodyDef(
      position: position,
      angle: 0,
      linearVelocity: velocity,
      type: BodyType.dynamic,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

const TextStyle _textStyle = TextStyle(color: Colors.red, fontSize: 2);
class TappableText extends TextComponent {
  TappableText(Vector2 position)
      : super(
    text: 'Text',
    textRenderer: TextPaint(style: _textStyle),
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    final scaleEffect = ScaleEffect.by(
      Vector2.all(1.1),
      EffectController(
        duration: 0.7,
        alternate: true,
        infinite: true,
      ),
    );
    add(scaleEffect);
  }

  // @override
  // bool onTapDown(TapDownInfo info) {
  //   add(
  //     MoveEffect.by(
  //       Vector2.all(5),
  //       EffectController(
  //         speed: 5,
  //         alternate: true,
  //       ),
  //     ),
  //   );
  //   return true;
  // }
}