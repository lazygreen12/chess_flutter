

import '../cchess/phase.dart';


enum EngineType { Cloud, Native }

/// 引擎查询结果包裹
/// type 为 move 时表示正常结果反馈，value 用于携带结果值
/// type 其它可能值至少包含：timeout / nobestmove / network-error / data-error
class EngineResponse {
  final String type;
  final dynamic value;
  EngineResponse(this.type, {this.value});
}

abstract class AiEngine {
  // 启动引擎
  Future<void> startup() async {}
  // 关闭引擎
  Future<void> shutdown() async {}
  // 搜索最佳着法
  Future<EngineResponse> search(Phase phase, {bool byUser = true});
}