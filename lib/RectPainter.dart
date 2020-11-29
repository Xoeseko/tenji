import 'package:flutter/material.dart';

class RectPainter extends CustomPainter {
  Map rect;
  RectPainter(this.rect);
  @override
  void paint(Canvas canvas, Size size) {
    if (rect != null) {
      final paint = Paint();
      paint.color = Colors.yellow;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      double x, y, w, h;
      x = rect["left"] * size.width;
      y = rect["top"] * size.height;
      w = rect["width"] * size.width;
      h = rect["height"] * size.height;
      Rect rect1 = Offset(x, y) & Size(w, h);
      canvas.drawRect(rect1, paint);
    }
  }

  @override
  bool shouldRepaint(RectPainter oldDelegate) => oldDelegate.rect != rect;
}
