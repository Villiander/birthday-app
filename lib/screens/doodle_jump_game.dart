import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:just_audio/just_audio.dart';

class DoodleJumpGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  final VoidCallback onGameOver;
  late SpriteComponent background;
  late Player player;
  late TextComponent scoreDisplay;
  double score = 0;
  bool giftTriggered = false;
  bool secretGift1Triggered = false;
  bool secretGift2Triggered = false;
  bool isGameOver = false;
  final Random rnd = Random();
  final double levelWidth = 150;
  final double minY = 20;
  final double maxY = 100;
  double currentY = 0;
  bool isStarted = false;

  DoodleJumpGame({required this.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeGame();
  }

  Future<void> _initializeGame() async {
    final bgSprite = await loadSprite('background.png');
    background = SpriteComponent(
      sprite: bgSprite,
      size: Vector2(size.x, size.y * 2),
      anchor: Anchor.topLeft,
      position: Vector2(0, -size.y),
    );
    add(background);

    player = Player(
      position: Vector2(size.x / 2, size.y - 100),
      size: Vector2(48, 48),
    );
    add(player);

    final initialPlatformY = size.y - 20;
    add(PlatformComponent(Vector2(size.x / 2, initialPlatformY), Vector2(60, 12)));
    currentY = initialPlatformY;
    for (int i = 0; i < 10; i++) {
      addPlatform();
    }

    scoreDisplay = TextComponent(
      text: "Score: 0",
      anchor: Anchor.topRight,
      position: Vector2(size.x - 10, 10),
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 24, color: Colors.red),
      ),
    );
    add(scoreDisplay);
    isStarted = true;
  }

  Future<void> reset() async {
    score = 0;
    giftTriggered = false;
    secretGift1Triggered = false;
    secretGift2Triggered = false;
    isGameOver = false;
    isStarted = false;
    currentY = size.y - 20;

    children.where((component) => component != scoreDisplay).toList().forEach((component) {
      component.removeFromParent();
    });
    await _initializeGame();
  }

  void addPlatform() {
    double randomYSpacing = rnd.nextDouble() * (maxY - minY) + minY;
    double newY = currentY - randomYSpacing;
    currentY = newY;
    final platformWidth = 60.0;
    final px = rnd.nextDouble() * (size.x - levelWidth - platformWidth) + platformWidth / 2;
    final py = newY;
    add(PlatformComponent(Vector2(px, py), Vector2(platformWidth, 12)));
  }

  void removeOffScreenPlatforms() {
    children.whereType<PlatformComponent>().forEach((platform) {
      if (platform.position.y > size.y + platform.size.y) {
        platform.removeFromParent();
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isStarted || isGameOver) {
      return;
    }
    if (player.position.y < size.y * 0.5) {
      final diff = (size.y * 0.5) - player.position.y;
      score += diff;
      scoreDisplay.text = "Score: ${score.toInt()}";
      for (final c in children) {
        if (c is PositionComponent && c != scoreDisplay) {
          c.position.y += diff;
        }
      }
      background.position.y += diff;
      if (background.position.y > 0) {
        background.position.y = -size.y;
      }
      currentY += diff;
    }
    while (currentY > player.position.y - size.y * 2) {
      addPlatform();
    }
    removeOffScreenPlatforms();
    scoreDisplay.position = Vector2(size.x - 10, 10);
    if (score >= 1000 && !giftTriggered) {
      giftTriggered = true;
    }
    if (score >= 3000 && !secretGift1Triggered) {
      secretGift1Triggered = true;
    }
    if (score >= 6000 && !secretGift2Triggered) {
      secretGift2Triggered = true;
    }
    if (player.position.y > size.y + 100 && !isGameOver) {
      isGameOver = true;
      onGameOver();
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        player.horizontalSpeed = -Player.defaultSpeed;
        if (!player.isFacingLeft) {
          player.flipHorizontally();
        }
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        player.horizontalSpeed = Player.defaultSpeed;
        if (player.isFacingLeft) {
          player.flipHorizontally();
        }
      }
    } else if (event is KeyUpEvent) {
      if (!keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
          !keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        player.horizontalSpeed = 0;
      }
    }
    return KeyEventResult.handled;
  }

  void startGame() {
    isStarted = true;
  }
}

class PlatformComponent extends SpriteComponent with CollisionCallbacks {
  static const jumpForce = 450.0;
  late AudioPlayer _jumpEffectPlayer;

  PlatformComponent(Vector2 position, Vector2 size)
      : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('platform.png');
    add(RectangleHitbox());
    _jumpEffectPlayer = AudioPlayer();
    await _jumpEffectPlayer.setAsset('assets/sounds/Jump_Effect.mp3');
    await _jumpEffectPlayer.setVolume(0.2);
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player && other.velocity.y > 0) {
      other.velocity.y = -jumpForce;
      _playJumpSound();
    }
  }

  Future<void> _playJumpSound() async {
    try {
      await _jumpEffectPlayer.stop();
      await _jumpEffectPlayer.seek(Duration.zero);
      await _jumpEffectPlayer.play();
    } catch (e) {
      print("Error playing jump sound: $e");
    }
  }

  @override
  void onRemove() {
    _jumpEffectPlayer.dispose();
    super.onRemove();
  }
}

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<DoodleJumpGame> {
  static const double defaultSpeed = 400;
  Vector2 velocity = Vector2.zero();
  double horizontalSpeed = 0;
  double gravity = 600;
  bool isFacingLeft = false;

  Player({required Vector2 position, required Vector2 size})
      : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('Doodle.png');
    add(CircleHitbox());
    return super.onLoad();
  }

  void flipHorizontally() {
    scale.x *= -1;
    isFacingLeft = !isFacingLeft;
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity.x = horizontalSpeed;
    velocity.y += gravity * dt;
    position += velocity * dt;
    final screenWidth = gameRef.size.x;
    final halfPlayerWidth = size.x / 2;
    position.x = position.x.clamp(halfPlayerWidth, screenWidth - halfPlayerWidth);
  }
}
