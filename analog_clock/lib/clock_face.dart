import 'package:flutter/material.dart';

class ClockFace extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height / 1.1;
    return Center(
      child: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new AspectRatio(
          aspectRatio: 1.0,
          child: new Stack(
            children: <Widget>[
              //dial and numbers
              new Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(10.0),
                child: new CustomPaint(
                  painter: new ClockDialPainter(),
                ),
              ),



            ],
          ),
        ),
      ),
    );
  }
}

class ClockDialPainter extends CustomPainter {
  static const double pi = 3.1415926535897932;

  final hourTickMarkLength = 10.0;
  final minuteTickMarkLength = 5.0;

  final hourTickMarkWidth = 3.0;
  final minuteTickMarkWidth = 1.5;

  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;

  ClockDialPainter()
      : tickPaint = new Paint(),
        textPainter = new TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        textStyle = const TextStyle(
          color: Colors.black,
          fontFamily: 'Times New Roman',
          fontSize: 15.0,
        ) {
    tickPaint.color = Colors.blueGrey;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var tickMarkLength;
    final angle = 2 * pi / 60;
    final radius = size.width / 2;
    canvas.save();

    // drawing
    canvas.translate(radius, radius);
    for (var i = 0; i < 60; i++) {
      //make the length and stroke of the tick marker longer and thicker depending
      tickMarkLength = i % 5 == 0 ? hourTickMarkLength : minuteTickMarkLength;
      tickPaint.strokeWidth =
          i % 5 == 0 ? hourTickMarkWidth : minuteTickMarkWidth;
      canvas.drawLine(new Offset(0.0, -radius),
          new Offset(0.0, -radius + tickMarkLength), tickPaint);

      //draw the text
//      if (i % 5 == 0) {
//        canvas.save();
//        canvas.translate(0.0, -radius + 20.0);
//
//        textPainter.text = new TextSpan(
//          text: '${i == 0 ? 12 : i ~/ 5}',
//          style: textStyle,
//        );
//
//        //helps make the text painted vertically
//        canvas.rotate(-angle * i);
//
//        textPainter.layout();
//
//        textPainter.paint(canvas,
//            new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));
//
//        canvas.restore();
//      }

      canvas.rotate(angle);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
