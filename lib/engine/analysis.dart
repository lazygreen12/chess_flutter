class AnalysisItem {
  // 着法，着法中文描述
  String move, stepName;
  // 此着法应用后的局面分值
  int score;
  // 使用此着法后的棋局胜率估算
  double winrate;

  AnalysisItem({this.move, this.score, this.winrate});

  @override
  String toString() {
    return '{move: ${stepName ?? move}, score: $score, winrate: $winrate}';
  }
}

// 解析云库的分析结果
class AnalysisFetcher {
  // 默认解析前5种着法
  static List<AnalysisItem> fetch(String response, {limit = 5}) {
    //
    final segments = response.split('|');

    List<AnalysisItem> result = [];

    final regx = RegExp(r'move:(.{4}).+score:(\-?\d+).+winrate:(\d+.?\d*)');

    for (var segment in segments) {
      //
      final match = regx.firstMatch(segment);

      if (match == null) break;

      final move = match.group(1);
      final score = int.parse(match.group(2));
      final winrate = double.parse(match.group(3));

      result.add(AnalysisItem(move: move, score: score, winrate: winrate));
      if (result.length == limit) break;
    }

    return result;
  }
}