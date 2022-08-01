import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:tryflame/blob_example.dart';
import 'package:tryflame/custom_painter_example.dart';
import 'package:tryflame/mine/my_flame.dart';
import 'package:tryflame/mine/try_particle.dart';
import 'package:tryflame/multiple_shapes_example.dart';
import 'package:tryflame/space_shooter_game.dart';

import 'animated_body_example.dart';
import 'particles_example.dart';

void main() {
  // runApp(GameWidget(game: SpaceShooterGame()));
  // runApp(customPainterBuilder());
  // runApp(GameWidget(game:AnimatedBodyExample()));
  // runApp(GameWidget(game:BlobExample()));
  // runApp(GameWidget(game:ParticlesExample()));
  // runApp(GameWidget(game:MultipleShapesExample()));
  // runApp(GameWidget(game:TryParticle()));
  runApp(GameWidget(game: MyFlame()));
}

