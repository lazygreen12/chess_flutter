import 'board-widget.dart';
import 'painter-base.dart';
import '../cchess/phase.dart';
import '../cchess/cc-base.dart';
import '../common/color-consts.dart';
import 'package:flutter/material.dart';

class PiecePaintStub {
  final String piece;
  final Offset pos; // 棋子呈现位置
  PiecePaintStub({this.piece, this.pos});
}

class PiecesPainter extends PainterBase{
  final Phase phase;

  final int focusIndex, blurIndex;

  double pieceSide;

  PiecesPainter({
    @required double width,
    @required this.phase,
    // 棋盘上的棋子移动、选择位置指示， Move.InvalidIndex表示无效，不用绘制
    this.focusIndex = Move.InvalidIndex,
    this.blurIndex = Move.InvalidIndex,
  }) : super(width: width){
    pieceSide = squareSide * 0.9;
  }

  @override
  void paint(Canvas canvas, Size size){
    doPaint(
      canvas,
      thePaint,
      phase: phase,
      gridWidth: gridWidth,
      squareSide: squareSide,
      pieceSide: pieceSide,
      offsetX: BoardWidget.Padding + squareSide / 2,
      offsetY: BoardWidget.Padding + BoardWidget.DigitsHeight + squareSide / 2,
      focusIndex: focusIndex,
      blurIndex: blurIndex,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    // 每次重建 Painter 时都要重画
    return true;
  }

  static doPaint(
      Canvas canvas,
      Paint paint, {
        Phase phase,
        double gridWidth,
        double squareSide,
        double pieceSide,
        double offsetX,
        double offsetY,
        int focusIndex = Move.InvalidIndex,
        int blurIndex = 1,
      }) {
    final left = offsetX, top = offsetY;
    // 在 Flutter 中绘制阴影，需要先将阴影对象添加到一个 Path 中
    // 绘制棋子时，将每个棋子的阴影路径一次性添加到 Path 中，然后一次绘制所有棋子的阴影
    final shadowPath = Path();
    final piecesToDraw = <PiecePaintStub>[];

    for(var row = 0; row < 10; row++){
      for(var column = 0; column < 9; column++){
        final piece = phase.pieceAt(row * 9 + column);
        if(piece == Piece.Empty) continue;
        //根据行列位置，计算棋子位置
        var pos = Offset(left + squareSide * column, top + squareSide * row);

        piecesToDraw.add(PiecePaintStub(piece: piece,pos: pos));

        // 为每一个棋盘上存在的棋子绘制一个圆形阴影
        shadowPath.addOval(Rect.fromCenter(center: pos, width: pieceSide, height: pieceSide));
      }
    }
    canvas.drawShadow(shadowPath, Colors.black, 2, true);

    paint.style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: ColorConsts.PieceTextColor,
      fontSize: pieceSide * 0.8,
      fontFamily: 'QiTi',
      height: 1.0,
    );

    //逐个绘制棋子
    piecesToDraw.forEach((pps) {
      paint.color = Piece.isRed(pps.piece) ?
          ColorConsts.RedPieceBorderColor : ColorConsts.BlackPieceBorderColor;
      //绘制棋子边界
      canvas.drawCircle(pps.pos, pieceSide / 2, paint);

      paint.color = Piece.isRed(pps.piece) ?
          ColorConsts.RedPieceBorderColor : ColorConsts.BlackPieceBorderColor;
      // 绘制棋子的内部圆
      canvas.drawCircle(pps.pos, pieceSide * 0.8 / 2, paint);

      final textSpan = TextSpan(text: Piece.Names[pps.piece],style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // 计算字体的 Metrics，包含相应字体的 Baseline
      final metric = textPainter.computeLineMetrics()[0];

      // 测量文字的尺寸
      final textSize = textPainter.size;

      // 从顶上算，文字的 Baseline 在 2/3 高度线上
      final textOffset = pps.pos - Offset(textSize.width / 2, metric.baseline - textSize.height / 3);

      // 将文字绘制到 Canvas 上
      textPainter.paint(canvas, textOffset);
    });

    if(focusIndex != Move.InvalidIndex){
      final int row  = focusIndex ~/ 9, column = focusIndex % 9;

      paint.color = ColorConsts.FocusPosition;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth =2;
      canvas.drawCircle(
          Offset(left + column * squareSide, top + row * squareSide),
          pieceSide / 2,
          paint,
      );
    }
    if(blurIndex != Move.InvalidIndex){
      final row = blurIndex ~/ 9, column = blurIndex % 9;

      paint.color = ColorConsts.BlurPosition;
      paint.style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(left + column * squareSide , top + row * squareSide),
        pieceSide / 2 * 0.8,
        paint,
      );
    }
  }

}