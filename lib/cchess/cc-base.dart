
class Side {
  //
  static const Unknown = '-';
  static const Red = 'w'; // 中国象棋的一些理论基础来自于国际象棋
  /// 'w'是国际象棋中的 white 侧，在中国象棋中没有白方，指代红方
  static const Black = 'b'; // 表示黑方


  static String of(String piece) {
    // 中国象棋用大写字母代表红方的棋子，用小定字母代码黑方的框
    // RNBAKCP 依次代码的棋子为：车马象仕将炮兵
    if ('RNBAKCP'.contains(piece)) return Red;
    if ('rnbakcp'.contains(piece)) return Black;
    return Unknown;
  }

  static bool sameSide(String p1, String p2) {
    return of(p1) == of(p2);
  }

  // 红黑双方交换
  static String oppo(String side) {
    if (side == Red) return Black;
    if (side == Black) return Red;
    return side;
  }
}

class Piece {
  //
  static const Empty = ' ';

  //
  static const RedRook = 'R';
  static const RedKnight = 'N';
  static const RedBishop = 'B';
  static const RedAdvisor = 'A';
  static const RedKing = 'K';
  static const RedCanon = 'C';
  static const RedPawn = 'P';

  //
  static const BlackRook = 'r';
  static const BlackKnight = 'n';
  static const BlackBishop = 'b';
  static const BlackAdvisor = 'a';
  static const BlackKing = 'k';
  static const BlackCanon = 'c';
  static const BlackPawn = 'p';

  static const Names = {
    Empty: '',
    //
    RedRook: '车',
    RedKnight: '马',
    RedBishop: '相',
    RedAdvisor: '仕',
    RedKing: '帅',
    RedCanon: '炮',
    RedPawn: '兵',
    //
    BlackRook: '车',
    BlackKnight: '马',
    BlackBishop: '象',
    BlackAdvisor: '士',
    BlackKing: '将',
    BlackCanon: '炮',
    BlackPawn: '卒',
  };

  static bool isRed(String c) => 'RNBAKCP'.contains(c);

  static bool isBlack(String c) => 'rnbakcp'.contains(c);
}

class Move {
  static const InvalidIndex = -1;

  //List<String>(90) 中的索引
  int from, to;

  // 左上角为坐标原点
  int fx, fy, tx, ty;

  //吃子目标棋子
  String captured;

  //'step' 是UCCI引擎的移动字符串
  String step;

  // 这一步走完后的 FEN 记数，用于悔棋时恢复 FEN 步数 Counter
  String counterMarks;

  String stepName;

  Move(this.from, this.to, {this.captured = Piece.Empty, this.counterMarks = '0 0'}){
    fx = from % 9;
    fy = from ~/ 9;

    tx = to % 9;
    ty = to ~/ 9;

    if(fx <0 || fx >8 || fy < 0 || fy > 9){
      throw "Error: Invlid Step (from:$from, to:$to)";
    }

    step = String.fromCharCode('a'.codeUnitAt(0) + fx) + (9 - fy).toString();
    step += String.fromCharCode('a'.codeUnitAt(0) + tx) + (9 - ty).toString();
  }

  /// 引擎返回的招法用是 4 个字符表示的，例如 b0c2
  /// 它的着法基于左下角坐标系
  /// 用 a ~ i 表示从左到右的 9 列
  /// 用 0 ~ 9 表示从下到上 10 行
  /// 因此 b0c2 表示从第 2 列第 1 行移动到第 3 列第 3 行

  Move.fromEngineStep(String step){
    this.step = step;
    if(!validateEngineStep(step)){
      throw "Error: Invlid Step: $step";
    }

    fx = step[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
    fy = 9 - (step[1].codeUnitAt(0) - '0'.codeUnitAt(0));
    tx = step[2].codeUnitAt(0) - 'a'.codeUnitAt(0);
    ty = 9 - (step[3].codeUnitAt(0) - '0'.codeUnitAt(0));

    from = fx + fy * 9;
    to = tx + ty * 9;

    captured = Piece.Empty;
  }

  //验证引擎返回着法是否是合法的
  static bool validateEngineStep(String step){
    if(step == null || step.length < 4) return false;

    final fx = step[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
    final fy = 9 - (step[1].codeUnitAt(0) - '0'.codeUnitAt(0));
    if (fx < 0 || fx > 8 || fy < 0 || fy > 9) return false;

    final tx = step[2].codeUnitAt(0) - 'a'.codeUnitAt(0);
    final ty = 9 - (step[3].codeUnitAt(0) - '0'.codeUnitAt(0));
    if (tx < 0 || tx > 8 || ty < 0 || ty > 9) return false;

    return true;
  }
}

///对战结果：未决、赢、输、和
enum BattleResult { Pending, Win, Lose, Draw }
