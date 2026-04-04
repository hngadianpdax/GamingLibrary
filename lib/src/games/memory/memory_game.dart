import 'dart:math';

enum MemoryPhase {
  countdown,
  reveal,
  hidden,
  playing,
  levelComplete,
  gameOver,
}

enum TileState {
  unrevealed,
  highlighted,
  correct,
  wrong,
  neutral,
}

enum GameOverReason { livesExhausted, timerExpired, sessionComplete }

class LevelConfig {
  final int gridSize;
  final int timerSeconds;
  final int tileCount;
  final int pointsPerTile;

  const LevelConfig({
    required this.gridSize,
    required this.timerSeconds,
    required this.tileCount,
    required this.pointsPerTile,
  });

  int get totalCells => gridSize * gridSize;

  static LevelConfig forLevel(int level) {
    // Timer bands: 1-10 = 30s, 11-20 = 20s, 21-25 = 15s
    if (level <= 3)  return const LevelConfig(gridSize: 4, timerSeconds: 30, tileCount: 4, pointsPerTile: 1);
    if (level <= 5)  return const LevelConfig(gridSize: 4, timerSeconds: 30, tileCount: 5, pointsPerTile: 1);
    if (level <= 8)  return const LevelConfig(gridSize: 5, timerSeconds: 30, tileCount: 5, pointsPerTile: 1);
    if (level <= 10) return const LevelConfig(gridSize: 5, timerSeconds: 30, tileCount: 6, pointsPerTile: 1);
    if (level <= 15) return const LevelConfig(gridSize: 6, timerSeconds: 20, tileCount: 6, pointsPerTile: 1);
    if (level <= 20) return const LevelConfig(gridSize: 7, timerSeconds: 20, tileCount: 7, pointsPerTile: 2);
    return           const LevelConfig(gridSize: 8, timerSeconds: 15, tileCount: 7, pointsPerTile: 2);
  }
}

class MemoryGame {
  static const int maxLevel = 25;
  static const int startingLives = 3;

  final int level;
  final int lives;
  final int totalScore;
  final int levelScore;
  final int timerSeconds;
  final int countdownValue;
  final MemoryPhase phase;
  final LevelConfig config;
  final List<TileState> tiles;
  final Set<int> targetIndices;
  final int correctFound;
  final GameOverReason? gameOverReason;

  const MemoryGame._({
    required this.level,
    required this.lives,
    required this.totalScore,
    required this.levelScore,
    required this.timerSeconds,
    required this.countdownValue,
    required this.phase,
    required this.config,
    required this.tiles,
    required this.targetIndices,
    required this.correctFound,
    this.gameOverReason,
  });

  factory MemoryGame.startSession() {
    const level = 1;
    final config = LevelConfig.forLevel(level);
    final targets = _pickTargets(config);
    return MemoryGame._(
      level: level,
      lives: startingLives,
      totalScore: 0,
      levelScore: 0,
      timerSeconds: config.timerSeconds,
      countdownValue: 3,
      phase: MemoryPhase.countdown,
      config: config,
      tiles: List.filled(config.totalCells, TileState.unrevealed),
      targetIndices: targets,
      correctFound: 0,
    );
  }

  static Set<int> _pickTargets(LevelConfig config) {
    final rng = Random();
    final indices = <int>{};
    while (indices.length < config.tileCount) {
      indices.add(rng.nextInt(config.totalCells));
    }
    return indices;
  }

  /// Called every second during countdown phase.
  MemoryGame tickCountdown() {
    if (phase != MemoryPhase.countdown) return this;
    if (countdownValue > 0) {
      return _copyWith(countdownValue: countdownValue - 1);
    }
    // countdownValue is 0 ("GO!") — transition to reveal
    final newTiles = List<TileState>.from(tiles);
    for (final i in targetIndices) {
      newTiles[i] = TileState.highlighted;
    }
    return _copyWith(phase: MemoryPhase.reveal, tiles: newTiles);
  }

  /// Called after the 2-second reveal window expires.
  MemoryGame hideGrid() {
    if (phase != MemoryPhase.reveal) return this;
    final newTiles = List.filled(config.totalCells, TileState.neutral);
    return _copyWith(phase: MemoryPhase.hidden, tiles: newTiles);
  }

  /// Called one frame after hideGrid() to enable tapping.
  MemoryGame beginPlaying() {
    if (phase != MemoryPhase.hidden) return this;
    return _copyWith(phase: MemoryPhase.playing);
  }

  /// Called every second during playing phase.
  MemoryGame tickTimer() {
    if (phase != MemoryPhase.playing) return this;
    if (timerSeconds > 1) {
      return _copyWith(timerSeconds: timerSeconds - 1);
    }
    return _copyWith(
      timerSeconds: 0,
      phase: MemoryPhase.gameOver,
      gameOverReason: GameOverReason.timerExpired,
    );
  }

  /// Called when the player taps a tile.
  MemoryGame tapTile(int index) {
    if (phase != MemoryPhase.playing) return this;
    if (tiles[index] == TileState.correct || tiles[index] == TileState.wrong) {
      return this;
    }

    final newTiles = List<TileState>.from(tiles);

    if (targetIndices.contains(index)) {
      newTiles[index] = TileState.correct;
      final newCorrect = correctFound + 1;
      final newLevelScore = levelScore + config.pointsPerTile;
      if (newCorrect == targetIndices.length) {
        return _copyWith(
          tiles: newTiles,
          correctFound: newCorrect,
          levelScore: newLevelScore,
          phase: MemoryPhase.levelComplete,
        );
      }
      return _copyWith(
        tiles: newTiles,
        correctFound: newCorrect,
        levelScore: newLevelScore,
      );
    } else {
      newTiles[index] = TileState.wrong;
      final newLives = lives - 1;
      if (newLives <= 0) {
        return _copyWith(
          tiles: newTiles,
          lives: 0,
          phase: MemoryPhase.gameOver,
          gameOverReason: GameOverReason.livesExhausted,
        );
      }
      return _copyWith(tiles: newTiles, lives: newLives);
    }
  }

  /// Resets a wrong tile back to neutral after the animation plays.
  MemoryGame clearWrongTile(int index) {
    if (phase != MemoryPhase.playing) return this;
    final newTiles = List<TileState>.from(tiles);
    newTiles[index] = TileState.neutral;
    return _copyWith(tiles: newTiles);
  }

  /// Advances to the next level or ends the session if level 25 is done.
  MemoryGame advanceLevel() {
    if (phase != MemoryPhase.levelComplete) return this;
    final newTotal = totalScore + levelScore;
    if (level >= maxLevel) {
      return _copyWith(
        totalScore: newTotal,
        phase: MemoryPhase.gameOver,
        gameOverReason: GameOverReason.sessionComplete,
      );
    }
    final nextLevel = level + 1;
    final nextConfig = LevelConfig.forLevel(nextLevel);
    final nextTargets = _pickTargets(nextConfig);
    return MemoryGame._(
      level: nextLevel,
      lives: lives,
      totalScore: newTotal,
      levelScore: 0,
      timerSeconds: nextConfig.timerSeconds,
      countdownValue: 3,
      phase: MemoryPhase.countdown,
      config: nextConfig,
      tiles: List.filled(nextConfig.totalCells, TileState.unrevealed),
      targetIndices: nextTargets,
      correctFound: 0,
    );
  }

  MemoryGame _copyWith({
    int? level,
    int? lives,
    int? totalScore,
    int? levelScore,
    int? timerSeconds,
    int? countdownValue,
    MemoryPhase? phase,
    LevelConfig? config,
    List<TileState>? tiles,
    Set<int>? targetIndices,
    int? correctFound,
    GameOverReason? gameOverReason,
  }) {
    return MemoryGame._(
      level: level ?? this.level,
      lives: lives ?? this.lives,
      totalScore: totalScore ?? this.totalScore,
      levelScore: levelScore ?? this.levelScore,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      countdownValue: countdownValue ?? this.countdownValue,
      phase: phase ?? this.phase,
      config: config ?? this.config,
      tiles: tiles ?? this.tiles,
      targetIndices: targetIndices ?? this.targetIndices,
      correctFound: correctFound ?? this.correctFound,
      gameOverReason: gameOverReason ?? this.gameOverReason,
    );
  }
}
