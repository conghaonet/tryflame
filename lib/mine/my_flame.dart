import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: MyFlame()));
}

class MyFlame extends FlameGame with HasTappableComponents {
  @override
  bool debugMode = true;
  bool _hasLoaded = false;
  late SpriteComponent _mySprite;
  final _fpsComponent = FpsTextComponent();

  @override
  Future<void>? onLoad() async {
    final zapSprite = await loadSprite("zap.png");
    var spriteSize = Vector2(80, 80);
    _mySprite = SpriteComponent(sprite: zapSprite, size: spriteSize);
    add(_mySprite);
    add(_fpsComponent);
    add(MyCircleComponent(Vector2(50, 60)));
    _hasLoaded = true;
    setComponents();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    debugPrint('$canvasSize');
    if(_hasLoaded) {
      setComponents();
    }
  }

  void setComponents() {
    _mySprite.center = size / 2;
    _fpsComponent.position = Vector2(40, size.y - 48);

  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if(!event.handled) {
      add(ShapeComponent(event.canvasPosition));
    }
    debugPrint('--------MyFlame---------');
  }
}

class ShapeComponent extends PositionComponent with TapCallbacks {
  final paint = Paint()..color = const Color(0xFFFFFF88)..strokeWidth = 2;
  ShapeComponent(Vector2 position): super(position: position, size: Vector2.all(Random().nextDouble()) * 100);

  @override
  void render(Canvas canvas) {
    canvas.drawCircle((size / 2).toOffset(), size.x/2, paint);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final radius = size.x / 2;
    final dx = point.x - radius;
    final dy = point.y - radius;
    return dx * dx + dy * dy <= radius * radius;
  }

  @override
  void onTapDown(TapDownEvent event) {
    debugPrint('****ShapeComponent****');
    add(RemoveEffect(delay: 0.2));
    event.handled = true;
  }
}

class MyCircleComponent extends CircleComponent with TapCallbacks {
  MyCircleComponent(Vector2 position): super(radius: 30, position: position, paint: Paint()..color = const Color(0xFFFFFF88));

  @override
  void onTapDown(TapDownEvent event) {
    debugPrint('====MyCircleComponent====');
    removeFromParent();
    event.handled = true;
  }

}