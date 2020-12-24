import 'package:flutter/material.dart';
import 'board-painter.dart';
import 'pieces-painter.dart';
import 'words-on-board.dart';
import '../game/battle.dart';
import '../common/color-consts.dart';

class BoardWidget extends StatelessWidget{
  // 棋盘内边界 + 棋盘上的路数指定文字高度
  static const Padding = 5.0, DigitsHeight = 36.0;
  //棋盘的宽、高
  final double width,height;
  // 棋盘的点击事件回调，由 board widget 的创建者传入
  final Function(BuildContext, int) onBoardTap;

  // 由于横盘上的小格子都是正方形，因素宽度确定后，棋盘的高度也就确定了
  BoardWidget({@required this.width, @required this.onBoardTap}) :
      height = (width - Padding*2)/9 * 10 + (Padding + DigitsHeight) * 2;

  @override
  Widget build(BuildContext context){
    final boardContainer = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorConsts.BoardBackground,
      ),
      child: CustomPaint(
        // 背景一层绘制横盘上的线格
        painter:BoardPainter(width:width),
        // 前景一层绘制棋子
        foregroundPainter: PiecesPainter(
          width: width,
          phase: Battle.shared.phase,
          focusIndex: Battle.shared.focusIndex,
          blurIndex: Battle.shared.blurIndex,
        ),
        // CustomPaint 的 child 用于布置其上的子组件，这里放置是我们的「河界」、「路数」等文字信息
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: Padding,
            // 因为棋子是放在交叉线上的，不是放置在格子内，所以棋子左右各有一半在格线之外
            // 这里先依据横盘的宽度计算出一个格子的边长，再依此决定垂直方向的边距
            horizontal: (width - Padding * 2) / 9 / 2 + Padding - WordsOnBoard.DigitsFontSize / 2,
          ),
          child: WordsOnBoard(),
        ),
      ),
    );

    //用 GestureDetector 组件包裹 board 组件，用于检测 board 上的点击事件
    return GestureDetector(
        child: boardContainer,
        onTapUp: (d){
          //网格的总宽度
          final gridWidth = (width - Padding * 2) * 8 / 9;
          //每个格子的边长
          final squareSide = gridWidth / 8;

          final dx = d.localPosition.dx, dy = d.localPosition.dy;
          //棋盘上的行、列转换
          final row = (dy - Padding -DigitsHeight) ~/ squareSide;
          final column = (dx - Padding) ~/ squareSide;

          if(row < 0 || row > 9) return;
          if(column < 0 || column > 8) return;

          //回调
          //从上到下、从左到右，第 row 行 column 列的棋子
          onBoardTap(context, row * 9 + column);
    });
  }
}