import 'analysis.dart';
import 'engine.dart';
import '../cchess/cc-base.dart';
import '../cchess/phase.dart';
import 'chess-db.dart';

/// 引擎查询结果包裹
/// type 为 move 时表示正常结果反馈，value 用于携带结果值
/// type 其它可能值至少包含：timeout / nobestmove / network-error / data-error

class CloudEngine extends AiEngine{
  /// 向云库查询某一个局面的最结着法
  /// 如果一个局面云库没有遇到过，则请求云库后台计算，并等待云库的计算结
  Future<EngineResponse> search(Phase phase, {bool byUser = true}) async{
    final fen = phase.toFen();
    var response = await ChessDB.query(fen);

    //发生网络错误，直接返回
    if(response == null) {
      return EngineResponse('network-error');
    }

    if(!response.startsWith('move:')){
      print('ChessDB.query: $response\n');
    }else{
      //有着法列表返回
      //move:b2a2,score:-236,rank:0,note:? (00-00),winrate:32.85
      final firstStep = response.split('|')[0];
      print('ChessDB.query: $firstStep');

      final segments = firstStep.split(',');
      if(segments.length < 2) return EngineResponse('data-error');

      final move = segments[0], score = segments[1];

      final scoreSegments = score.split(':');
      if(scoreSegments.length < 2 ) return EngineResponse('data-error');

      final moveWithScore = int.tryParse(scoreSegments[1]) != null;

      //存在有效着法
      if(moveWithScore){
        final step = move.substring(5);

        if(Move.validateEngineStep(step)){
          return EngineResponse(
            'move',
            value: Move.fromEngineStep(step),
          );
        }
      }else{
        //云库没有遇到过这个局面，请求它执行后台计算
        if(byUser){
          response = await ChessDB.requestComputeBackground(fen);
          print('ChessDB.requestComputeBackground: $response\n');
        }
        //这里每过5秒就查看它的计算结果
        return Future<EngineResponse>.delayed(
          Duration(seconds: 1),
              () => search(phase, byUser: false),
        );
      }
    }
    return EngineResponse('unknown-error');
  }

  // 给云库引擎添加分析方法，之后会调用前述的分析结果解析工具
  static Future<EngineResponse> analysis(Phase phase) async {
    //
    final fen = phase.toFen();
    var response = await ChessDB.query(fen);

    if (response == null) return EngineResponse('network-error');

    if (response.startsWith('move:')) {
      final items = AnalysisFetcher.fetch(response);
      if (items.isEmpty) return EngineResponse('no-result');
      return EngineResponse('analysis', value: items);
    }

    print('ChessDB.query: $response\n');
    return EngineResponse('unknown-error');
  }

}