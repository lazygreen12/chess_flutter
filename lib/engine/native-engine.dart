
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../cchess/cc-base.dart';
import '../cchess/phase.dart';
import '../engine/engine.dart';

class NativeEngine extends AiEngine {
  //
  static const platform = const MethodChannel(
      'cn.apppk.chessroad/engine'
  );

  // 启动引擎
  Future<void> startup() async {
    //
    try {
      await platform.invokeMethod('startup');
    } catch (e) {
      print('Native startup Error: $e');
    }

    await setBookFile();
    await waitResponse(['ucciok'], sleep: 1, times: 30);
  }

  // 向引擎发送指令
  Future<void> send(String command) async {
    //
    try {
      await platform.invokeMethod('send', command);
    } catch (e) {
      print('Native sendCommand Error: $e');
    }
  }

  // 读取引擎响应信息
  Future<String> read() async {
    //
    try {
      return await platform.invokeMethod('read');
    } catch (e) {
      print('Native readResponse Error: $e');
    }

    return null;
  }

  // 关闭引擎
  Future<void> shutdown() async {
    //
    try {
      await platform.invokeMethod('shutdown');
    } catch (e) {
      print('Native shutdown Error: $e');
    }
  }

  // 查询引擎状态是否就绪
  Future<bool> isReady() async {
    //
    try {
      return await platform.invokeMethod('isReady');
    } catch (e) {
      print('Native readResponse Error: $e');
    }

    return null;
  }

  // 查询引擎状态是否在思考中
  Future<bool> isThinking() async {
    //
    try {
      return await platform.invokeMethod('isThinking');
    } catch (e) {
      print('Native readResponse Error: $e');
    }

    return null;
  }

  // 给引擎设置开局库
  // 从 Assets 中读取资源，将它写到 app document 目录下的指定位置，然后将绝对路径设置给引擎
  Future setBookFile() async {
    //
    final docDir = await getApplicationDocumentsDirectory();
    final bookFile = File('${docDir.path}/book.dat');

    try {
      if (!await bookFile.exists()) {
        await bookFile.create(recursive: true);
        final bytes = await rootBundle.load("assets/book.dat");
        await bookFile.writeAsBytes(bytes.buffer.asUint8List());
      }
    } catch (e) {
      print(e);
    }

    await send("setoption bookfiles ${bookFile.path}");
  }

  // 要引擎搜索局面的最佳着法
  @override
  Future<EngineResponse> search(Phase phase, {bool byUser = true}) async {
    //
    if (await isThinking()) await stopSearching();

    // 发送局面信息给引擎
    send(buildPositionCommand(phase));
    // 指示在5秒钟内给出最佳着法
    send('go time 5000');

    // 等待引擎的回复，走到读取到 bestmove 或是 nobestmove 打头的字样
    final response = await waitResponse(['bestmove', 'nobestmove']);

    // 如果引擎返回了最佳着法
    if (response.startsWith('bestmove')) {
      //
      var step = response.substring('bestmove'.length + 1);

      final pos = step.indexOf(' ');
      if (pos > -1) step = step.substring(0, pos);

      // 解析着法，并返回给应用
      return EngineResponse('move', value: Move.fromEngineStep(step));
    }

    // 如果引擎返回自己「没着了」，告诉应用引擎没有就对方案
    if (response.startsWith('nobestmove')) {
      return EngineResponse('nobestmove');
    }

    // 如果在指定时间段段内没有收到引擎的正确响应，则返回游戏「引擎超时」
    return EngineResponse('timeout');
  }

  // 停止正在进行的搜索
  Future<void> stopSearching() async {
    await send('stop');
  }

  //根据引擎要求的格式，我们组织布局信息字符串
  String buildPositionCommand(Phase phase){
    final startPhase = phase.lastCapturedPhase;
    final moves = phase.movesSinceLastCaptured();

    if(moves.isEmpty) return 'position fen $startPhase';

    return 'position fen $startPhase moves $moves';
  }

  // 这个方法反复读取引擎的响应，每两次读取之间间隔一定的时间，默认读取读取指定的次数，还是没有
  // 搜索到希望的响应时，就返回''
  Future<String> waitResponse(List<String> prefixes, {sleep = 100, times = 100}) async {
    //
    if (times <= 0) return '';

    final response = await read();

    if (response != null) {
      for (var prefix in prefixes) {
        if (response.startsWith(prefix)) return response;
      }
    }

    return Future<String>.delayed(
      Duration(milliseconds: sleep),
          () => waitResponse(prefixes, times: times - 1),
    );
  }

}
