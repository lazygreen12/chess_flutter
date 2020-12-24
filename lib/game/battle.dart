
import '../services/audio.dart';

import '../cchess/cc-rules.dart';
import '../cchess/cc-base.dart';
import '../cchess/phase.dart';

// Battle 类将集中管理横盘上的棋子、对战结果、引擎调用等事务
class Battle {
  static Battle _instance;

  static get shared {
    _instance ??= Battle();
    return _instance;
  }

  Phase _phase;
  int _focusIndex, _blurIndex;

  init() {
    _phase = Phase.defaultPhase();
    _focusIndex = _blurIndex = Move.InvalidIndex;
  }

  // 点击选中一个棋子，使用 _focusIndex 来标记此位置
  // 棋子绘制时，将在这个位置绘制棋子的选中效果
  select(int pos) {
    _focusIndex = pos;
    _blurIndex = Move.InvalidIndex;
    Audios.playTone('click.mp3');
  }

  // 从 from 到 to 位置移动棋子，使用 _focusIndex 和 _blurIndex 来标记 from 和 to 位置
  // 棋子绘制时，将在这两个位置分别绘制棋子的移动前的位置和当前位置
  bool move(int from, int to) {
    final captured = _phase.move(from, to);

    if (captured == null) {
      Audios.playTone('invalid.mp3');
      return false;
    }
    // 移动棋子时，更新这两个标志位置，然后的绘制会把它们展示在界面上
    _blurIndex = from;
    _focusIndex = to;

    //将军
    if(ChessRules.checked(_phase)){
      Audios.playTone('check.mp3');
    }else{
      // 吃子或仅仅是移动棋子
      Audios.playTone(captured != Piece.Empty ? 'capture.mp3' : 'move.mp3');
    }
    return true;
  }

  clear() {
    _blurIndex = _focusIndex = Move.InvalidIndex;
  }

  get phase => _phase;

  get focusIndex => _focusIndex;

  get blurIndex => _blurIndex;

  BattleResult scanBattleResult() {
    final forPerson = (_phase.side == Side.Red);

    if(scanLongCatch()){
      return forPerson ? BattleResult.Win : BattleResult.Lose;
    }

    if(ChessRules.beKilled(_phase)){
      return forPerson ? BattleResult.Lose : BattleResult.Win;
    }

    //游戏不超过60回合
    return (_phase.halfMove > 120) ? BattleResult.Draw : BattleResult.Pending;
  }

  //是否存在长将长捉
  scanLongCatch(){
    //todo
    return false;
  }

  newGame() {
    Battle.shared.phase.initDefaultPhase();
    _focusIndex = _blurIndex = Move.InvalidIndex;
  }

}