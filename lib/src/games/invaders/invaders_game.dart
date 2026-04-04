import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/boss_component.dart';
import 'components/enemy_component.dart';
import 'components/player_component.dart';
import 'data/stage_data.dart';

enum InvadersPhase {
  playing,
  waveClear,
  stageClear,
  gameOver,
  victory,
}

class InvadersGame extends FlameGame with HasCollisionDetection {
  // ── Public state ────────────────────────────────────────────────────────────
  int lives = 3;
  int score = 0;
  int stageIndex = 0;
  int waveIndex = 0;
  int enemiesRemaining = 0;
  InvadersPhase phase = InvadersPhase.playing;

  // ── Callbacks to Flutter ────────────────────────────────────────────────────
  final void Function(InvadersPhase phase) onPhaseChange;
  Color bgColor;

  // ── Internal ────────────────────────────────────────────────────────────────
  late PlayerComponent _player;
  double _phaseTimer = 0;
  bool _invincible = false;
  double _invincibleTimer = 0;
  static const double _invincibleDuration = 1.8;

  InvadersGame({required this.onPhaseChange, this.bgColor = const Color(0xFF112756)});

  // ── Accessors ────────────────────────────────────────────────────────────────
  StageDef get currentStage => stageDefinitions[stageIndex];
  WaveDef get currentWave => currentStage.waves[waveIndex];
  int get totalStages => stageDefinitions.length;
  int get totalWaves => currentStage.waves.length;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  Color backgroundColor() => bgColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _spawnPlayer();
    _spawnStars();
    _spawnWave();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_invincible) {
      _invincibleTimer += dt;
      if (_invincibleTimer >= _invincibleDuration) {
        _invincible = false;
        _invincibleTimer = 0;
      }
    }

    if (phase == InvadersPhase.waveClear) {
      _phaseTimer += dt;
      if (_phaseTimer >= 1.0) {
        _phaseTimer = 0;
        _nextWaveOrStage();
      }
    }
  }

  // ── Input (called from Flutter GestureDetector) ───────────────────────────
  void movePlayerTo(double x) {
    if (phase != InvadersPhase.playing) return;
    _player.moveTo(x);
  }

  // ── Spawning ─────────────────────────────────────────────────────────────────
  void _spawnPlayer() {
    _player = PlayerComponent(
      position: Vector2(size.x / 2, size.y - 20),
      onHit: _onPlayerHit,
    );
    add(_player);
  }

  void _spawnStars() {
    final rng = Vector2.zero();
    for (int i = 0; i < 60; i++) {
      final x = (i * 137.5) % size.x;
      final y = (i * 73.1) % size.y;
      rng.setValues(x, y);
      add(_StarParticle(position: rng.clone(), speed: 20 + (i % 3) * 15));
    }
  }

  void _spawnWave() {
    if (currentWave.isBossWave) {
      _spawnBoss();
      return;
    }

    for (final batch in currentWave.batches) {
      _spawnBatch(batch);
    }
  }

  void _spawnBatch(BatchDef batch) {
    final enemies = batch.enemies;
    final count = enemies.length;
    final speed = enemySpeedForStage(stageIndex + 1);
    final positions = _formationPositions(batch.formation, count);

    for (int i = 0; i < count; i++) {
      final type = enemies[i];
      final target = positions[i];
      // Start above screen
      final start = Vector2(target.x, -type.size - 20 - i * 8.0);

      final enemy = EnemyComponent(
        type: type,
        position: start,
        descentSpeed: speed,
        targetPosition: target,
        onKilled: (e, pts) {
          score += pts;
          enemiesRemaining--;
          if (enemiesRemaining <= 0) _onWaveCleared();
        },
        onReachedBottom: _onPlayerHit,
      );
      add(enemy);
      enemiesRemaining++;
    }
  }

  void _spawnBoss() {
    final hp = bossHpForStage(stageIndex + 1);
    final boss = BossComponent(
      position: Vector2(size.x / 2, 80),
      maxHp: hp,
      stage: stageIndex + 1,
      onKilled: (pts) {
        score += pts;
        _onWaveCleared();
      },
      onReachedBottom: _onPlayerHit,
    );
    add(boss);
    enemiesRemaining = 1;
  }

  List<Vector2> _formationPositions(Formation formation, int count) {
    final List<Vector2> positions = [];
    final cols = (count / 2).ceil();
    final spacing = (size.x - 80) / (cols + 1);

    switch (formation) {
      case Formation.leftToRight:
        for (int i = 0; i < count; i++) {
          final col = i % cols;
          final row = i ~/ cols;
          positions.add(Vector2(
            40 + spacing * (col + 1),
            80 + row * 60.0,
          ));
        }
      case Formation.rightToLeft:
        for (int i = 0; i < count; i++) {
          final col = i % cols;
          final row = i ~/ cols;
          positions.add(Vector2(
            size.x - 40 - spacing * (col + 1),
            80 + row * 60.0,
          ));
        }
      case Formation.vShape:
        final half = count ~/ 2;
        for (int i = 0; i < count; i++) {
          final side = i < half ? -1 : 1;
          final idx = i < half ? i : i - half;
          positions.add(Vector2(
            size.x / 2 + side * (idx + 1) * (size.x / (count + 2)),
            60 + idx * 55.0,
          ));
        }
    }
    return positions;
  }

  // ── Event handlers ────────────────────────────────────────────────────────────
  void _onPlayerHit() {
    if (_invincible) return;
    lives--;
    _invincible = true;
    _invincibleTimer = 0;

    if (lives <= 0) {
      lives = 0;
      _changePhase(InvadersPhase.gameOver);
    }
  }

  void _onWaveCleared() {
    score += 50; // wave clear bonus
    _changePhase(InvadersPhase.waveClear);
  }

  void _nextWaveOrStage() {
    waveIndex++;
    if (waveIndex >= currentStage.waves.length) {
      // Stage complete
      score += 200; // stage clear bonus
      score += lives * 100; // life bonus
      if (stageIndex >= stageDefinitions.length - 1) {
        _changePhase(InvadersPhase.victory);
      } else {
        _changePhase(InvadersPhase.stageClear);
      }
    } else {
      _changePhase(InvadersPhase.playing);
      _spawnWave();
    }
  }

  void advanceToNextStage() {
    stageIndex++;
    waveIndex = 0;
    enemiesRemaining = 0;
    _changePhase(InvadersPhase.playing);
    _spawnWave();
  }

  void _changePhase(InvadersPhase newPhase) {
    phase = newPhase;
    onPhaseChange(newPhase);
  }
}

// ── Star background ───────────────────────────────────────────────────────────
class _StarParticle extends PositionComponent {
  final double speed;
  final double _size;

  _StarParticle({required Vector2 position, required this.speed})
      : _size = 1 + (speed % 3),
        super(position: position, size: Vector2.all(2));

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    final gameH = findGame()?.size.y ?? 700;
    if (position.y > gameH) {
      position.y = 0;
      position.x = (position.x * 1.618) % (findGame()?.size.x ?? 400);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset.zero,
      _size,
      Paint()..color = const Color(0x88FFFFFF),
    );
  }
}
