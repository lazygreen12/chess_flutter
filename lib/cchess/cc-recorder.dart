import 'package:chess_override/cchess/phase.dart';

import 'cc-base.dart';

class CCRecorder {
  //无吃子步数、总回合数
  int halfMove, fullMove;
  String lastCapturedPhase;
  final _history = <Move>[];

  stepAt(int index) => _history[index];

  get stepsCount => _history.length;

  CCRecorder({this.halfMove = 0, this.fullMove = 0, this.lastCapturedPhase});

  void stepIn(Move move, Phase phase) {
    //
    if (move.captured != Piece.Empty) {
      halfMove = 0;
    } else {
      halfMove++;
    }

    if (fullMove == 0) {
      fullMove++;
    } else if (phase.side != Side.Black) {
      fullMove++;
    }

    var beforeLength = _history.length;

    _history.add(move);

    var afterLength = _history.length;

    if (move.captured != Piece.Empty) {
      lastCapturedPhase = phase.toFen();
    }
  }

  Move removeLast() {
    if (_history.isEmpty) return null;
    return _history.removeLast();
  }

  get last => _history.isEmpty ? null : _history.last;

  // 自上一个咋子局面后的着法列表，反向存放在返回列表中
  List<Move> reverseMovesToPrevCapture() {
    //
    List<Move> moves = [];

    for (var i = _history.length - 1; i >= 0; i--) {
      if (_history[i].captured != Piece.Empty) break;
      moves.add(_history[i]);
    }

    return moves;
  }

  CCRecorder.fromCounterMarks(String marks) {
    var segments = marks.split(' ');
    if (segments.length != 2) {
      throw 'Error: Invalid Counter Marks: $marks';
    }

    halfMove = int.parse(segments[0]);
    fullMove = int.parse(segments[1]);

    if (halfMove == null || fullMove == null) {
      throw 'Error: Invalid Counter Marks: $marks';
    }
  }

  @override
  String toString() {
    return '$halfMove $fullMove';
  }

  String buildManualText({cols = 2}) {
    var manualText = '';

    for (var i = 0; i < _history.length; i++) {
      manualText += '${i < 9 ? ' ' : ''}${i + 1}. ${_history[i].stepName}　';
      if ((i + 1) % cols == 0) manualText += '\n';
    }

    if (manualText.isEmpty) {
      manualText = '<暂无招法>';
    }

    return manualText;
  }
}
