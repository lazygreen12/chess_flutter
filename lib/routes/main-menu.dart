import 'package:chess_override/engine/engine.dart';
import 'package:chess_override/routes/setting-page.dart';

import '../common/color-consts.dart';
import '../main.dart';
import 'battle-page.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  AnimationController inController, shadowController;
  Animation inAnimation, shadowAnimation;

  @override
  void initState() {
    super.initState();

    //标题缩放动画
    inController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    inAnimation = CurvedAnimation(parent: inController, curve: Curves.bounceIn);
    inAnimation = new Tween(begin: 1.6, end: 1.0).animate(inController);

    //阴影厚度变化
    shadowController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    shadowAnimation = new Tween(begin: 0.0, end: 12.0).animate(shadowController);

    //缩放动画完成后，开始阴影厚度变换动画
    inController.addStatusListener((status) {
      if (status == AnimationStatus.completed) shadowController.forward();
    });

    //阴影厚度变换动画完成后，自动复位（为下一次呈现做准备）
    shadowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) shadowController.reverse();
    });

    inAnimation.addListener(() {
      try {
        setState(() {});
      } catch (e) {}
    });

    shadowAnimation.addListener(() {
      try {
        setState(() {});
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final nameShadow = Shadow(
      color: Color.fromARGB(0x99, 66, 0, 0),
      offset: Offset(0, shadowAnimation.value / 2),
      blurRadius: shadowAnimation.value,
    );
    final menuItemShadow = Shadow(
      color: Color.fromARGB(0x7F, 0, 0, 0),
      offset: Offset(0, shadowAnimation.value / 6),
      blurRadius: shadowAnimation.value / 3,
    );

    final nameStyle = TextStyle(
      fontSize: 64,
      color: Colors.black,
      shadows: [nameShadow],
    );

    final menuItemStyle = TextStyle(
      fontSize: 28,
      color: ColorConsts.Primary,
      shadows: [menuItemShadow],
    );

    //标题和菜单项的布局
    final menuItems = Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: SizedBox(),
            flex: 4,
          ),
          //Hero(tag: 'logo', child: Image.asset('images/logo.png')),
          Expanded(child: SizedBox()),
          Transform.scale(
            scale: inAnimation.value,
            child: Text('中国象棋', style: nameStyle, textAlign: TextAlign.center),
          ),
          Expanded(child: SizedBox(),flex: 2,),
          FlatButton(
            child: Text(
              '对战',
              style: menuItemStyle,
            ),
            onPressed: () => navigateTo(BattlePage(EngineType.Native)),
          ),
          Expanded(child: SizedBox()),
          FlatButton(
            child: Text(
              '服务器',
              style: menuItemStyle,
            ),
            onPressed: () => navigateTo(BattlePage(EngineType.Cloud)),
          ),
          Expanded(
            child: SizedBox(),
            flex: 6,
          )
        ],
      ),
    );

    return Scaffold(
      backgroundColor: ColorConsts.LightBackground,
      body: Stack(
        children: <Widget>[
          //右上角显示梅花
          Positioned(
              child: Image(image: AssetImage('images/mei.png')),
              right: 0,
              top: 0),
          //左下角显示竹子
          Positioned(
              child: Image(image: AssetImage('images/zhu.png')),
              left: 0,
              bottom: 0),
          menuItems,
          Positioned(
            child: IconButton(
                icon: Icon(Icons.settings, color: ColorConsts.Primary),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage())),
            ),
            top: ChessRoadApp.StatusBarHeight,
            left: 10,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    inController.dispose();
    shadowController.dispose();

    super.dispose();
  }

  navigateTo(Widget page) async {
    //
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => page));

    //从其它页面返回后，再呈现动效效果
    inController.reset();
    shadowController.reset();
    inController.forward();
  }
}
