import 'word_list.dart';

enum LetterState { empty, filled, correct, present, absent }

class LetterTile {
  final String letter;
  final LetterState state;

  const LetterTile({required this.letter, required this.state});

  LetterTile copyWith({String? letter, LetterState? state}) =>
      LetterTile(letter: letter ?? this.letter, state: state ?? this.state);
}

enum GameStatus { playing, won, lost }

class WordleGame {
  static const int maxAttempts = 6;
  static const int wordLength = 5;

  final String targetWord;
  final List<List<LetterTile>> board;
  final Map<String, LetterState> keyboardState;
  int currentRow;
  int currentCol;
  GameStatus status;
  String? message;
  final DateTime startTime;
  final int? elapsedSeconds;

  WordleGame._({
    required this.targetWord,
    required this.board,
    required this.keyboardState,
    required this.currentRow,
    required this.currentCol,
    required this.status,
    required this.startTime,
    this.elapsedSeconds,
    this.message,
  });

  factory WordleGame.start() {
    final target = WordList.randomAnswerWord();
    return WordleGame._(
      targetWord: target,
      board: List.generate(
        maxAttempts,
        (_) => List.generate(
          wordLength,
          (_) => const LetterTile(letter: '', state: LetterState.empty),
        ),
      ),
      keyboardState: {},
      currentRow: 0,
      currentCol: 0,
      status: GameStatus.playing,
      startTime: DateTime.now(),
    );
  }

  WordleGame addLetter(String letter) {
    if (status != GameStatus.playing) return this;
    if (currentCol >= wordLength) return this;

    final newBoard = _copyBoard();
    newBoard[currentRow][currentCol] =
        LetterTile(letter: letter.toUpperCase(), state: LetterState.filled);

    return _copyWith(board: newBoard, currentCol: currentCol + 1, message: null);
  }

  WordleGame deleteLetter() {
    if (status != GameStatus.playing) return this;
    if (currentCol == 0) return this;

    final newBoard = _copyBoard();
    newBoard[currentRow][currentCol - 1] =
        const LetterTile(letter: '', state: LetterState.empty);

    return _copyWith(board: newBoard, currentCol: currentCol - 1, message: null);
  }

  WordleGame submitGuess() {
    if (status != GameStatus.playing) return this;
    if (currentCol < wordLength) {
      return _copyWith(message: 'Not enough letters');
    }

    final guess = board[currentRow].map((t) => t.letter.toLowerCase()).join();

    if (!WordList.isValidGuess(guess)) {
      return _copyWith(message: 'Word not found');
    }

    final newBoard = _copyBoard();
    final newKeyboard = Map<String, LetterState>.from(keyboardState);
    final result = _evaluateGuess(guess);

    for (int i = 0; i < wordLength; i++) {
      newBoard[currentRow][i] = LetterTile(
        letter: board[currentRow][i].letter,
        state: result[i],
      );
      final current = newKeyboard[board[currentRow][i].letter.toLowerCase()];
      if (current == null || _stateRank(result[i]) > _stateRank(current)) {
        newKeyboard[board[currentRow][i].letter.toLowerCase()] = result[i];
      }
    }

    final bool won = result.every((s) => s == LetterState.correct);
    final int nextRow = currentRow + 1;
    GameStatus newStatus = GameStatus.playing;
    String? msg;
    int? elapsed;

    if (won) {
      newStatus = GameStatus.won;
      elapsed = DateTime.now().difference(startTime).inSeconds;
      final tb = _calcTimeBonus(elapsed);
      final ab = maxAttempts - currentRow;
      msg = _winMessage(currentRow + 1, ab, tb);
    } else if (nextRow >= maxAttempts) {
      newStatus = GameStatus.lost;
      msg = 'The word was ${targetWord.toUpperCase()}';
    }

    return _copyWith(
      board: newBoard,
      keyboardState: newKeyboard,
      currentRow: nextRow,
      currentCol: 0,
      status: newStatus,
      message: msg,
      elapsedSeconds: elapsed,
    );
  }

  /// Attempt-based score: 6 for 1 guess → 1 for 6 guesses.
  int get attemptScore {
    if (status != GameStatus.won) return 0;
    return maxAttempts - (currentRow - 1);
  }

  /// Time bonus: 6 pts for under 60s, loses 1 pt per minute, min 0.
  int get timeBonus {
    if (status != GameStatus.won || elapsedSeconds == null) return 0;
    return _calcTimeBonus(elapsedSeconds!);
  }

  int _calcTimeBonus(int seconds) {
    final bonus = 6 - (seconds ~/ 60);
    return bonus.clamp(0, 6);
  }

  /// Total score = attempt score + time bonus.
  int get score => attemptScore + timeBonus;

  List<LetterState> _evaluateGuess(String guess) {
    final result = List.filled(wordLength, LetterState.absent);
    final targetChars = targetWord.split('');
    final guessChars = guess.split('');
    final remaining = List<String>.from(targetChars);

    for (int i = 0; i < wordLength; i++) {
      if (guessChars[i] == targetChars[i]) {
        result[i] = LetterState.correct;
        remaining[i] = '';
      }
    }

    for (int i = 0; i < wordLength; i++) {
      if (result[i] == LetterState.correct) continue;
      final idx = remaining.indexOf(guessChars[i]);
      if (idx != -1) {
        result[i] = LetterState.present;
        remaining[idx] = '';
      }
    }

    return result;
  }

  int _stateRank(LetterState s) {
    switch (s) {
      case LetterState.correct:
        return 3;
      case LetterState.present:
        return 2;
      case LetterState.absent:
        return 1;
      default:
        return 0;
    }
  }

  String _winMessage(int attempts, int attemptPts, int timePts) {
    final label = switch (attempts) {
      1 => 'LEGENDARY!',
      2 => 'Brilliant!',
      3 => 'Great!',
      4 => 'Nice!',
      5 => 'Phew!',
      _ => 'Saved it!',
    };
    final total = attemptPts + timePts;
    return '$label $attemptPts + $timePts time = +$total pts';
  }

  List<List<LetterTile>> _copyBoard() =>
      board.map((row) => row.map((t) => t).toList()).toList();

  WordleGame _copyWith({
    List<List<LetterTile>>? board,
    Map<String, LetterState>? keyboardState,
    int? currentRow,
    int? currentCol,
    GameStatus? status,
    String? message,
    int? elapsedSeconds,
  }) =>
      WordleGame._(
        targetWord: targetWord,
        board: board ?? this.board,
        keyboardState: keyboardState ?? this.keyboardState,
        currentRow: currentRow ?? this.currentRow,
        currentCol: currentCol ?? this.currentCol,
        status: status ?? this.status,
        startTime: startTime,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        message: message ?? this.message,
      );
}
