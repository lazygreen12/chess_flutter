
import 'package:flutter/material.dart';
import '../common/color-consts.dart';

class WordsOnBoard extends StatelessWidget{
  static const DigitsFontSize = 18.0;
  @override
  Widget build(BuildContext context) {
    // 棋盘上的路数指示，红方用大写，黑方用全角的小写字母
    final blackColumns = '１２３４５６７８９',redColumns = '九八七六五四三二一';
    final bChildren = <Widget>[], rChildren = <Widget>[];
    final digitsStyle = TextStyle(fontSize: DigitsFontSize);
    final rivierTipsStyle = TextStyle(fontSize: 28.0);

    for(var i=0; i<9;i++){
      bChildren.add(Text(blackColumns[i], style: digitsStyle));
      rChildren.add(Text(redColumns[i], style: digitsStyle));
      // 每一个数字后边添加一个 Expanded，用于平分布局空间
      if(i<8){
        bChildren.add(Expanded(child: SizedBox(),));
        rChildren.add(Expanded(child: SizedBox(),));
      }
    }

    final riverTips = Row(
      children: <Widget>[
        Expanded(child: SizedBox()),
        Text("楚河",style: rivierTipsStyle,),
        Expanded(child: SizedBox(),flex: 2,),
        Text("汉界",style: rivierTipsStyle,),
        Expanded(child: SizedBox()),
      ],
    );

    // 放置上、中、下三部分到一个列布局模式中，上和中、中和下之间使用 Expanded 对象平分垂直方向多出来的布局空间
    return DefaultTextStyle(
        style: TextStyle(color: ColorConsts.BoardTips, fontFamily: 'QiTi'),
        child: Column(
          children: <Widget>[
            Row(children: bChildren),
            Expanded(child: SizedBox()),
            riverTips,
            Expanded(child: SizedBox()),
            Row(children: rChildren),
          ],
        )
    );
  }
}