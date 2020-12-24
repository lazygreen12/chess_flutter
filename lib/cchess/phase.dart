import 'steps-validate.dart';
import 'cc-base.dart';

class Phase{
  // 当前行棋方
  String _side;
  // 中国象棋的棋子放在纵线交叉点上，棋盘上总共有10行9列的交叉点位，一共90个位置
  List<String> _pieces; // 10 行，9 列
  //无吃子步数、总回合数
  int halfMove = 0, fullMove = 0;

  String lastCapturedPhase;
  final _history = <Move>[];

  //
  BattleResult result = BattleResult.Pending; //结果未定

  get side => _side;

  turnSide() => _side = Side.oppo(_side);

  // 查询10行9列的某个位置上的棋子
  String pieceAt(int index) => _pieces[index];

  Phase.defaultPhase() {
    initDefaultPhase();
  }

  void initDefaultPhase(){
    //
    _side = Side.Red;
    _pieces = List<String>(90);

    // 从上到下，棋盘第一行
    _pieces[0 * 9 + 0] = Piece.BlackRook;
    _pieces[0 * 9 + 1] = Piece.BlackKnight;
    _pieces[0 * 9 + 2] = Piece.BlackBishop;
    _pieces[0 * 9 + 3] = Piece.BlackAdvisor;
    _pieces[0 * 9 + 4] = Piece.BlackKing;
    _pieces[0 * 9 + 5] = Piece.BlackAdvisor;
    _pieces[0 * 9 + 6] = Piece.BlackBishop;
    _pieces[0 * 9 + 7] = Piece.BlackKnight;
    _pieces[0 * 9 + 8] = Piece.BlackRook;

    // 从上到下，棋盘第三行
    _pieces[2 * 9 + 1] = Piece.BlackCanon;
    _pieces[2 * 9 + 7] = Piece.BlackCanon;

    // 从上到下，棋盘第四行
    _pieces[3 * 9 + 0] = Piece.BlackPawn;
    _pieces[3 * 9 + 2] = Piece.BlackPawn;
    _pieces[3 * 9 + 4] = Piece.BlackPawn;
    _pieces[3 * 9 + 6] = Piece.BlackPawn;
    _pieces[3 * 9 + 8] = Piece.BlackPawn;

    // 从上到下，棋盘第十行
    _pieces[9 * 9 + 0] = Piece.RedRook;
    _pieces[9 * 9 + 1] = Piece.RedKnight;
    _pieces[9 * 9 + 2] = Piece.RedBishop;
    _pieces[9 * 9 + 3] = Piece.RedAdvisor;
    _pieces[9 * 9 + 4] = Piece.RedKing;
    _pieces[9 * 9 + 5] = Piece.RedAdvisor;
    _pieces[9 * 9 + 6] = Piece.RedBishop;
    _pieces[9 * 9 + 7] = Piece.RedKnight;
    _pieces[9 * 9 + 8] = Piece.RedRook;

    // 从上到下，棋盘第八行
    _pieces[7 * 9 + 1] = Piece.RedCanon;
    _pieces[7 * 9 + 7] = Piece.RedCanon;

    // 从上到下，棋盘第七行
    _pieces[6 * 9 + 0] = Piece.RedPawn;
    _pieces[6 * 9 + 2] = Piece.RedPawn;
    _pieces[6 * 9 + 4] = Piece.RedPawn;
    _pieces[6 * 9 + 6] = Piece.RedPawn;
    _pieces[6 * 9 + 8] = Piece.RedPawn;

    // 其它位置全部填空
    for (var i = 0; i < 90; i++) {
      _pieces[i] ??= Piece.Empty;
    }

    lastCapturedPhase = toFen();
  }

  String move(int from,int to){
    if(!validateMove(from, to)) return null;

    final captured = _pieces[to];

    //记录无吃子步数
    if(captured != Piece.Empty){
      halfMove = 0;
    }else{
      halfMove++;
    }
    //总回合数
    if(fullMove == 0){
      fullMove += 1;
    }else if(side == Side.Black){
      fullMove += 1;
    }

    //修改棋盘
    _pieces[to] = _pieces[from];
    _pieces[from] = Piece.Empty;

    //交换走棋方
    _side = Side.oppo(_side);

    _history.add(Move(from, to,captured: captured));
    if(captured != Piece.Empty) lastCapturedPhase =toFen();

    return captured;
  }

  bool validateMove(int from, int to){
    if(Side.of(_pieces[from]) != side) return false;
    return (StepValidate.validate(this, Move(from, to)));
  }

  //根据局面数据生成局面表示字符串（FEN）
  String toFen(){
    var fen = '';
    for(var row = 0; row < 10; row++){
      var emptyCounter = 0;
      for(var column = 0; column < 9; column++){
        final piece = pieceAt(row * 9 + column);

        if(piece == Piece.Empty){
          emptyCounter += 1;
        }else{
          if(emptyCounter > 0){
            fen += emptyCounter.toString();
            emptyCounter = 0;
          }
          fen += piece;
        }
      }
      if(emptyCounter > 0)
        fen += emptyCounter.toString();

      if(row < 9)
        fen += '/';
    }
    fen += ' $side';
    //王车易位和吃过路兵标志
    fen += ' - - ';

    // step counter
    fen += '$halfMove $fullMove';

    return fen;
  }

  //复制一个临时棋盘来进行合法性检测
  Phase.clone(Phase other){
    _pieces = List<String>();
    other._pieces.forEach((piece) => _pieces.add(piece));
    _side = other._side;
    halfMove = other.halfMove;
    fullMove = other.fullMove;
  }
  
  // 在判断行棋合法性等环节，要在克隆的棋盘上进行行棋假设，然后检查效果
  // 这种情况下不验证、不记录、不翻译
  void moveTest(Move move, {turnSide = false}){
    //修改棋盘
    _pieces[move.to] = _pieces[move.from];
    _pieces[move.from] = Piece.Empty;
    //交换走棋方
    if(turnSide) _side = Side.oppo(_side);
  }

  //根据引擎要求，我们将上次咋子以后的所有无咋子着法列出来
  String movesSinceLastCaptured(){
    //
    var steps = '',posAfterLastCaptured = 0;

    for(var i = _history.length - 1; i >= 0; i--){
      if(_history[i].captured != Piece.Empty) break;
      posAfterLastCaptured = i;
    }

    for(var i = posAfterLastCaptured; i< _history.length; i++ ){
      steps += ' ${_history[i].step}';
    }

    return steps.length > 0 ? steps.substring(1) : '';
  }
}