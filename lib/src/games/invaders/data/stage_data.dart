enum EnemyType { level1, level2, level3, boss }

enum Formation { leftToRight, rightToLeft, vShape }

class BatchDef {
  final List<EnemyType> enemies;
  final Formation formation;

  const BatchDef({required this.enemies, required this.formation});
}

class WaveDef {
  final List<BatchDef> batches;
  final bool isBossWave;

  const WaveDef({required this.batches, this.isBossWave = false});
}

class StageDef {
  final int stageNumber;
  final String title;
  final List<WaveDef> waves;

  const StageDef({
    required this.stageNumber,
    required this.title,
    required this.waves,
  });
}

// ── Enemy stats ───────────────────────────────────────────────────────────────

extension EnemyTypeStats on EnemyType {
  int get maxHp {
    switch (this) {
      case EnemyType.level1: return 1;
      case EnemyType.level2: return 2;
      case EnemyType.level3: return 3;
      case EnemyType.boss:   return 0; // overridden per stage
    }
  }

  int get points {
    switch (this) {
      case EnemyType.level1: return 10;
      case EnemyType.level2: return 25;
      case EnemyType.level3: return 50;
      case EnemyType.boss:   return 200;
    }
  }

  double get size {
    switch (this) {
      case EnemyType.level1: return 22;
      case EnemyType.level2: return 28;
      case EnemyType.level3: return 34;
      case EnemyType.boss:   return 64;
    }
  }

  /// Whether this enemy type can shoot back
  bool get canShoot {
    switch (this) {
      case EnemyType.level1: return false;
      case EnemyType.level2: return true;
      case EnemyType.level3: return true;
      case EnemyType.boss:   return true;
    }
  }

  /// Shoot interval in seconds (lower = more frequent)
  double get shootInterval {
    switch (this) {
      case EnemyType.level1: return double.infinity;
      case EnemyType.level2: return 4.0;
      case EnemyType.level3: return 2.5;
      case EnemyType.boss:   return 1.2;
    }
  }
}

// ── Stage definitions ─────────────────────────────────────────────────────────

const _lv1 = EnemyType.level1;
const _lv2 = EnemyType.level2;
const _lv3 = EnemyType.level3;

final stageDefinitions = [
  // ── Stage 1: First Contact ──────────────────────────────────────────────────
  StageDef(
    stageNumber: 1,
    title: 'FIRST CONTACT',
    waves: [
      WaveDef(batches: [
        BatchDef(
          enemies: List.filled(8, _lv1),
          formation: Formation.leftToRight,
        ),
      ]),
      WaveDef(batches: [
        BatchDef(
          enemies: List.filled(8, _lv1),
          formation: Formation.rightToLeft,
        ),
      ]),
      WaveDef(batches: [
        BatchDef(
          enemies: [...List.filled(6, _lv1), ...List.filled(4, _lv2)],
          formation: Formation.vShape,
        ),
      ]),
      WaveDef(isBossWave: true, batches: []),
    ],
  ),

  // ── Stage 2: Escalation ─────────────────────────────────────────────────────
  StageDef(
    stageNumber: 2,
    title: 'ESCALATION',
    waves: [
      WaveDef(batches: [
        BatchDef(
          enemies: [...List.filled(4, _lv1), ...List.filled(6, _lv2)],
          formation: Formation.rightToLeft,
        ),
      ]),
      WaveDef(batches: [
        BatchDef(
          enemies: List.filled(8, _lv2),
          formation: Formation.leftToRight,
        ),
      ]),
      WaveDef(batches: [
        BatchDef(
          enemies: [...List.filled(4, _lv2), ...List.filled(4, _lv3)],
          formation: Formation.vShape,
        ),
      ]),
      WaveDef(isBossWave: true, batches: []),
    ],
  ),

  // ── Stage 3: Final Wave ─────────────────────────────────────────────────────
  StageDef(
    stageNumber: 3,
    title: 'FINAL WAVE',
    waves: [
      WaveDef(batches: [
        BatchDef(
          enemies: [...List.filled(4, _lv2), ...List.filled(6, _lv3)],
          formation: Formation.leftToRight,
        ),
      ]),
      WaveDef(batches: [
        BatchDef(
          enemies: List.filled(8, _lv3),
          formation: Formation.rightToLeft,
        ),
      ]),
      WaveDef(batches: [
        BatchDef(
          enemies: [...List.filled(4, _lv2), ...List.filled(6, _lv3)],
          formation: Formation.vShape,
        ),
      ]),
      WaveDef(isBossWave: true, batches: []),
    ],
  ),
];

// Boss HP per stage
int bossHpForStage(int stage) {
  switch (stage) {
    case 1: return 10;
    case 2: return 20;
    case 3: return 35;
    default: return 10;
  }
}

// Enemy descent speed per stage (pixels/sec)
double enemySpeedForStage(int stage) {
  switch (stage) {
    case 1: return 40.0;
    case 2: return 60.0;
    case 3: return 80.0;
    default: return 40.0;
  }
}
