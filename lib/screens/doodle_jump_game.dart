import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:just_audio/just_audio.dart';

class DoodleJumpGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  final VoidCallback onGameOver;
  late double gravity;
  late double jumpForce;
  late double platformMinGap;
  late double platformMaxGap;
  late double platformWidth;
  late double platformHeight;
  late SpriteComponent background;
  late Player player;
  late TextComponent scoreDisplay;
  double score = 0;
  bool giftTriggered = false;
  bool secretGift1Triggered = false;
  bool secretGift2Triggered = false;
  bool isGameOver = false;
  bool isStarted = false;
  double currentY = 0;
  final Random rnd = Random();

  DoodleJumpGame({required this.onGameOver});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gravity = size.y * 1.2;
    jumpForce = size.y * 0.6;
    platformMinGap = size.y * 0.05;
    platformMaxGap = size.y * 0.15;
    platformWidth = size.x * 0.2;
    platformHeight = size.y * 0.012;
    final bgSprite = await loadSprite('background.png');
    background = SpriteComponent(
      sprite: bgSprite,
      size: Vector2(size.x, size.y * 2),
      anchor: Anchor.topLeft,
      position: Vector2(0, -size.y),
    );
    add(background);
    final playerSize = Vector2(size.x * 0.10, size.x * 0.10);
    player = Player(
      position: Vector2(size.x / 2, size.y - playerSize.y * 2),
      size: playerSize,
      gravity: gravity,
    );
    add(player);
    final initialPlatformY = size.y - platformHeight - size.y * 0.02;
    add(PlatformComponent(
      Vector2(size.x / 2, initialPlatformY),
      Vector2(platformWidth, platformHeight),
      jumpForce,
    ));
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
    isStarted = false;
  }

  void startGame() {
    isStarted = true;
  }

  void addPlatform() {
    final spacing = rnd.nextDouble() * (platformMaxGap - platformMinGap) + platformMinGap;
    currentY -= spacing;
    final px = rnd.nextDouble() * (size.x - platformWidth) + platformWidth / 2;
    add(PlatformComponent(
      Vector2(px, currentY),
      Vector2(platformWidth, platformHeight),
      jumpForce,
    ));
  }

  void removeOffScreenPlatforms() {
    children.whereType<PlatformComponent>().forEach((p) {
      if (p.position.y > size.y + p.size.y) {
        p.removeFromParent();
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
      final dy = (size.y * 0.5) - player.position.y;
      score += dy;
      scoreDisplay.text = "Score: ${score.toInt()}";
      for (final c in children) {
        if (c is PositionComponent && c != scoreDisplay) {
          c.position.y += dy;
        }
      }
      background.position.y += dy;
      if (background.position.y > 0) {
        background.position.y = -size.y;
      }
      currentY += dy;
    }
    while (currentY > player.position.y - size.y * 2) {
      addPlatform();
    }
    removeOffScreenPlatforms();
    if (score >= 1000 && !giftTriggered) {
      giftTriggered = true;
    }
    if (score >= 3000 && !secretGift1Triggered) {
      secretGift1Triggered = true;
    }
    if (score >= 6000 && !secretGift2Triggered) {
      secretGift2Triggered = true;
    }
    if (player.position.y > size.y + player.size.y && !isGameOver) {
      isGameOver = true;
      onGameOver();
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        player.horizontalSpeed = -Player.defaultSpeed;
        if (!player.isFacingLeft) player.flipHorizontally();
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        player.horizontalSpeed = Player.defaultSpeed;
        if (player.isFacingLeft) player.flipHorizontally();
      }
    } else if (event is KeyUpEvent) {
      if (!keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
          !keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        player.horizontalSpeed = 0;
      }
    }
    return KeyEventResult.handled;
  }

  Future<void> reset() async {
    score = 0;
    giftTriggered = false;
    secretGift1Triggered = false;
    secretGift2Triggered = false;
    isGameOver = false;
    isStarted = false;
    children.where((c) => c != scoreDisplay).toList().forEach((c) => c.removeFromParent());
    await onLoad();
  }
}

class PlatformComponent extends SpriteComponent with CollisionCallbacks {
  final double jumpForce;
  late AudioPlayer _jumpEffectPlayer;

  PlatformComponent(
    Vector2 position,
    Vector2 size,
    this.jumpForce,
  ) : super(position: position, size: size, anchor: Anchor.center);

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
    await _jumpEffectPlayer.stop();
    await _jumpEffectPlayer.seek(Duration.zero);
    await _jumpEffectPlayer.play();
  }

  @override
  void onRemove() {
    _jumpEffectPlayer.dispose();
    super.onRemove();
  }
}

class Player extends SpriteComponent with CollisionCallbacks, HasGameRef<DoodleJumpGame> {
  static const double defaultSpeed = 400;
  final double gravity;
  Vector2 velocity = Vector2.zero();
  double horizontalSpeed = 0;
  bool isFacingLeft = false;

  Player({
    required Vector2 position,
    required Vector2 size,
    required this.gravity,
  }) : super(position: position, size: size, anchor: Anchor.center);

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
    velocity.x += (horizontalSpeed - velocity.x) * 10 * dt;
    velocity.y += gravity * dt;
    position += velocity * dt;
    final halfPlayerWidth = size.x / 2;
    position.x = position.x.clamp(halfPlayerWidth, gameRef.size.x - halfPlayerWidth);
  }
}
