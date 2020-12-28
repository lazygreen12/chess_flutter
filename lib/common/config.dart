import 'profile.dart';

// 基于本地文件持久化工具实现的配置管理类
class Config {
  //
  static bool bgmEnabled = true;
  static bool toneEnabled = true;
  static int stepTime = 5000;

  // 加载配置项
  static Future<void> loadProfile() async {
    //
    final profile = await Profile.shared();

    Config.bgmEnabled = profile['bgm-enabled'] ?? true;
    Config.toneEnabled = profile['tone-enabled'] ?? true;
    Config.stepTime = profile['step-time'] ?? 5000;

    return true;
  }

  // 保存配置项到本地文件
  static Future<bool> save() async {
    //
    final profile = await Profile.shared();

    profile['bgm-enabled'] = Config.bgmEnabled;
    profile['tone-enabled'] = Config.toneEnabled;
    profile['step-time'] = Config.stepTime;

    profile.commit();

    return true;
  }
}