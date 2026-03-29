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

  WordleGame._({
    required this.targetWord,
    required this.board,
    required this.keyboardState,
    required this.currentRow,
    required this.currentCol,
    required this.status,
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
      // Only upgrade keyboard state (absent < present < correct)
      final current = newKeyboard[board[currentRow][i].letter.toLowerCase()];
      if (current == null || _stateRank(result[i]) > _stateRank(current)) {
        newKeyboard[board[currentRow][i].letter.toLowerCase()] = result[i];
      }
    }

    final bool won = result.every((s) => s == LetterState.correct);
    final int nextRow = currentRow + 1;
    GameStatus newStatus = GameStatus.playing;
    String? msg;

    if (won) {
      newStatus = GameStatus.won;
      msg = _winMessage(currentRow + 1);
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
    );
  }

  /// Skill-based scoring: 6 pts for 1 guess, 5 for 2, ..., 1 for 6.
  int get score {
    if (status != GameStatus.won) return 0;
    return maxAttempts - (currentRow - 1);
  }

  List<LetterState> _evaluateGuess(String guess) {
    final result = List.filled(wordLength, LetterState.absent);
    final targetChars = targetWord.split('');
    final guessChars = guess.split('');
    final remaining = List<String>.from(targetChars);

    // First pass: correct positions
    for (int i = 0; i < wordLength; i++) {
      if (guessChars[i] == targetChars[i]) {
        result[i] = LetterState.correct;
        remaining[i] = '';
      }
    }

    // Second pass: present but wrong position
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

  String _winMessage(int attempts) {
    switch (attempts) {
      case 1:
        return 'LEGENDARY! +6 pts';
      case 2:
        return 'Brilliant! +5 pts';
      case 3:
        return 'Great! +4 pts';
      case 4:
        return 'Nice! +3 pts';
      case 5:
        return 'Phew! +2 pts';
      default:
        return 'Saved it! +1 pt';
    }
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
  }) =>
      WordleGame._(
        targetWord: targetWord,
        board: board ?? this.board,
        keyboardState: keyboardState ?? this.keyboardState,
        currentRow: currentRow ?? this.currentRow,
        currentCol: currentCol ?? this.currentCol,
        status: status ?? this.status,
        message: message ?? this.message,
      );
}
