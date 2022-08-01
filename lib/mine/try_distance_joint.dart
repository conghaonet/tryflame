import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/widgets.dart';
import 'package:tryflame/stories/bridge_libraries/forge2d/utils/balls.dart';
import 'package:tryflame/stories/bridge_libraries/forge2d/utils/boundaries.dart';

void main() {
  runApp(GameWidget(game: TryDistanceJoint()));
}

class TryDistanceJoint extends Forge2DGame with TapDetector {
  Ball? _ballA;
  static const radius = 3.0;
  final jointDef = DistanceJointDef();
  @override
  bool debugMode = true;
  // MyAnimatedBodyExample(): super(zoom: 1);
  @override
  Future<void>? onLoad() async {
    addAll(createBoundaries(this));
    jointDef..length = 400
      ..frequencyHz = 0.0
      ..dampingRatio = 0.0;
  }

  @override void onTapDown(TapDownInfo info) {
    if(_ballA == null) {
      _ballA = Ball(info.eventPosition.game, radius: radius);
      add(_ballA!);
      add(JointBall(_ballA!, jointDef));
    } else {
      return;
    }
  }
}

class JointBall extends BodyComponent {
  final Ball ball;
  final DistanceJointDef jointDef;
  JointBall(this.ball, this.jointDef);
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: ball.center + Vector2(24.0, 0.0),
      fixedRotation: true,
      linearVelocity: (Vector2.random() - Vector2.random()) * 200,
    );
    final body = world.createBody(bodyDef);
    final shape = CircleShape()..radius = 3;
    final fixtureDef = FixtureDef(
      shape,
      density: 100.0,
      friction: 0.0,
      restitution: 1.0,
    );
    body.createFixture(fixtureDef);
    jointDef.initialize(ball.body, body, ball.center, body.position);
    world.createJoint(DistanceJoint(jointDef));
    return body;
  }
}