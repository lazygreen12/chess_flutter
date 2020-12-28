import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/toast.dart';
import '../common/color-consts.dart';
import '../common/config.dart';
import '../services/audios.dart';
import 'edit-page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //
  String _version = 'Ver 1.00';

  @override
  void initState() {
    super.initState();
    loadVersionInfo();
  }

  // 使用三方插件读取应用的版本信息
  loadVersionInfo() async {
    //
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version ${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  // 切换引擎的难度等级
  changeDifficult() {
    //
    callback(int stepTime) async {
      //
      Navigator.of(context).pop();

      setState(() {
        Config.stepTime = stepTime;
      });

      Config.save();
    }

    // 难度等级目前是由给引擎的思考时间决定的
    // 其它一些可调整的因素还包括：
    // = 是否启用开局库
    // = 是否在选择着法时放弃最优着法
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 10),
          RadioListTile(
            activeColor: ColorConsts.Primary,
            title: Text('初级'),
            groupValue: Config.stepTime,
            value: 5000,
            onChanged: callback,
          ),
          Divider(),
          RadioListTile(
            activeColor: ColorConsts.Primary,
            title: Text('中级'),
            groupValue: Config.stepTime,
            value: 15000,
            onChanged: callback,
          ),
          Divider(),
          RadioListTile(
            activeColor: ColorConsts.Primary,
            title: Text('高级'),
            groupValue: Config.stepTime,
            value: 30000,
            onChanged: callback,
          ),
          Divider(),
          SizedBox(height: 56),
        ],
      ),
    );
  }

  // 开头背景音乐
  switchMusic(bool value) async {
    //
    setState(() {
      Config.bgmEnabled = value;
    });

    if (Config.bgmEnabled) {
      Audios.loopBgm('bg_music.mp3');
    } else {
      Audios.stopBgm();
    }

    Config.save();
  }

  // 开关动作音效
  switchTone(bool value) async {
    //
    setState(() {
      Config.toneEnabled = value;
    });

    Config.save();
  }

  @override
  Widget build(BuildContext context) {
    //
    final TextStyle headerStyle = TextStyle(color: ColorConsts.Secondary, fontSize: 20.0);
    final TextStyle itemStyle = TextStyle(color: ColorConsts.Primary);

    return Scaffold(
      backgroundColor: ColorConsts.LightBackground,
      appBar: AppBar(title: Text('设置')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10.0),
            Text("人机难度", style: headerStyle),
            const SizedBox(height: 10.0),
            Card(
              color: ColorConsts.BoardBackground,
              elevation: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("游戏难度", style: itemStyle),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Text(Config.stepTime <= 5000 ? '初级' :
                      Config.stepTime <= 15000 ? '中级' : '高级'),
                      Icon(Icons.keyboard_arrow_right, color: ColorConsts.Secondary),
                    ]),
                    onTap: changeDifficult,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text("声音", style: headerStyle),
            Card(
              color: ColorConsts.BoardBackground,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    activeColor: ColorConsts.Primary,
                    value: Config.bgmEnabled,
                    title: Text("背景音乐", style: itemStyle),
                    onChanged: switchMusic,
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    activeColor: ColorConsts.Primary,
                    value: Config.toneEnabled,
                    title: Text("提示音效", style: itemStyle),
                    onChanged: switchTone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60.0),
          ],
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 1.0,
      color: ColorConsts.LightLine,
    );
  }
}