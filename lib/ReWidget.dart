// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, must_be_immutable, camel_case_types
import 'package:flutter/material.dart';
//import 'dart:math';

import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

//随机ID生成器
String generateSessionKey(int length) {
  final random = Random();
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String sessionKey = '';
  for (int i = 0; i < length; i++) {
    final randomIndex = random.nextInt(chars.length);
    sessionKey += chars[randomIndex];
  }

  return sessionKey;
}

//数据文件读写类
class FileDispose {
  String filename;
  FileDispose({required this.filename});
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<Map<String, dynamic>> readData() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return {};
    }
  }

  Future<File> writeData(var counter) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(jsonEncode(counter));
  }
}

//消息气泡
class ChatBubble extends StatelessWidget {
  final Map message;
  bool themestate;
  ChatBubble({required this.message, required this.themestate, super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileWidth = MediaQuery.of(context).size.width * 0.1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        message["role"] == "assistant"
            ? Container(
                // width: ProfileWidth,
                // height: ProfileWidth,
                // decoration: BoxDecoration(
                //     color: Colors.blue,
                //     borderRadius: BorderRadius.circular(ProfileWidth)),
                )
            : const Expanded(child: SizedBox()),
        AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            alignment: Alignment.centerRight,
            decoration: message["role"] == "assistant"
                ? BoxDecoration(
                    color: themestate
                        ? const Color.fromARGB(255, 233, 232, 232)
                        : const Color.fromARGB(255, 59, 59, 59),
                    //border: Border.all(color: Colors.black12, width: 0.5),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(ProfileWidth / 2),
                        bottomRight: Radius.circular(ProfileWidth / 2),
                        bottomLeft: Radius.circular(ProfileWidth / 2)))
                : BoxDecoration(
                    color: themestate
                        ? const Color.fromARGB(255, 119, 201, 87)
                            .withOpacity(0.7)
                        : const Color.fromARGB(255, 179, 209, 56),
                    //border: Border.all(color: Colors.black12, width: 0.5),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ProfileWidth / 2),
                        bottomRight: Radius.circular(ProfileWidth / 2),
                        bottomLeft: Radius.circular(ProfileWidth / 2))),
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ProfileWidth * 6.5,
              ),
              child: Text(
                message["content"],
                style: TextStyle(
                    fontSize: ProfileWidth / 2.5,
                    color: message["role"] == "user"
                        ? Colors.black
                        : themestate
                            ? Colors.black
                            : Colors.white),
                softWrap: true,
              ),
            )),
        message["role"] == "user"
            ? Container(
                // width: ProfileWidth,
                // height: ProfileWidth,
                // decoration: BoxDecoration(
                //     color: Colors.amber,
                //     borderRadius: BorderRadius.circular(ProfileWidth)),
                )
            : const Expanded(child: SizedBox())
      ],
    );
  }
}

//定制图标
class RelaxIcons {
  //休息室图标
  static const IconData relaxroom =
      IconData(0xe601, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //咖啡图标
  static const IconData coffee =
      IconData(0xe602, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //漂流瓶图标
  static const IconData bottle =
      IconData(0xe603, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //心1图标
  static const IconData heart1 =
      IconData(0xe604, fontFamily: 'RelaxIcon', matchTextDirection: true);
//设置图标
  static const IconData setting =
      IconData(0xe60b, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //发送图标
  static const IconData send =
      IconData(0xe652, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //对话图标
  static const IconData chat =
      IconData(0xe75e, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //添加图标
  static const IconData add =
      IconData(0xe600, fontFamily: 'RelaxIcon', matchTextDirection: true);
//返回图标
  static const IconData back =
      IconData(0xe61c, fontFamily: 'RelaxIcon', matchTextDirection: true);

  //漂流瓶1
  static const IconData floatbottle1 =
      IconData(0xe642, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //漂流瓶1
  static const IconData floatbottle2 =
      IconData(0xe63c, fontFamily: 'RelaxIcon', matchTextDirection: true);
//休息1
  static const IconData rest1 =
      IconData(0xe6ef, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //休息2
  static const IconData rest2 =
      IconData(0xe62c, fontFamily: 'RelaxIcon', matchTextDirection: true);
  //心2
  static const IconData heart2 =
      IconData(0xe89a, fontFamily: 'RelaxIcon', matchTextDirection: true);
//冥想
  static const IconData mind =
      IconData(0xe60a, fontFamily: 'RelaxIcon', matchTextDirection: true);
}

//定制文本输入框
class EditingLine extends StatefulWidget {
  final TextEditingController editingController;
  final String labeltext;
  final double textsize;
  const EditingLine(
      {required this.editingController,
      required this.labeltext,
      required this.textsize,
      super.key});
  @override
  State<EditingLine> createState() => _stateEditingLine();
}

class _stateEditingLine extends State<EditingLine> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorHeight: widget.textsize * 1.3,
      cursorColor: const Color.fromARGB(255, 40, 244, 255),
      textAlign: TextAlign.center,
      controller: widget.editingController,
      style: TextStyle(fontSize: widget.textsize),
      decoration: InputDecoration(
        hintText: "请输入${widget.labeltext}",
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        border: InputBorder.none,
      ),
    );
  }
}

//亚克力材质的container
class AcrylicContainer extends StatelessWidget {
  double width;
  double height;
  Color interlayercolor;
  double radius;
  double borderradius;
  double opacity;
  Widget child;

  EdgeInsetsGeometry padding;
  EdgeInsetsGeometry? margin;
  AcrylicContainer(
      {super.key,
      required this.width,
      required this.height,
      required this.interlayercolor,
      required this.radius,
      required this.borderradius,
      required this.child,
      required this.opacity,
      required this.padding,
      required this.margin});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRect(
          child: Container(
        //
        clipBehavior: Clip.hardEdge,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(borderradius)),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: radius, sigmaY: radius), //设置图片模糊度
            child: Stack(
              children: [
                Positioned(
                    child: Opacity(
                  opacity: opacity,
                  child: Container(
                    color: interlayercolor,
                  ),
                )),
                Padding(
                  padding: padding,
                  child: child,
                )
              ],
            )),
      )),
    );
  }
}

//定制页面切换动画
class AnimatingRoute extends PageRouteBuilder {
  final Widget page;
  final Widget route;

  AnimatingRoute({required this.page, required this.route})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: route,
          ),
        );
}
//import 'package:flutter/material.dart';

//定制环形圆角进度条
class CircularProgressBar extends StatelessWidget {
  final double progress;
  final double strokeWidth;
  final Color color;
  final double startAngle;
  final double endAngle;
  final double radius;
  final double beginCapRadius;
  final double endCapRadius;

  CircularProgressBar({
    required this.progress,
    this.strokeWidth = 10.0,
    this.color = Colors.blue,
    this.startAngle = 0.0,
    this.endAngle = 360.0,
    this.radius = 100.0,
    this.beginCapRadius = 0.0,
    this.endCapRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularProgressBarPainter(
        progress: progress,
        strokeWidth: strokeWidth,
        color: color,
        startAngle: startAngle,
        endAngle: endAngle,
        radius: radius,
        beginCapRadius: beginCapRadius,
        endCapRadius: endCapRadius,
      ),
    );
  }
}

class _CircularProgressBarPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final double startAngle;
  final double endAngle;
  final double radius;
  final double beginCapRadius;
  final double endCapRadius;

  _CircularProgressBarPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.startAngle,
    required this.endAngle,
    required this.radius,
    required this.beginCapRadius,
    required this.endCapRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final startAngleRadians = startAngle * (3.1415927 / 180.0);
    final endAngleRadians = endAngle * (3.1415927 / 180.0);
    final sweepAngleRadians = (endAngle - startAngle) * (3.1415927 / 180.0);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      startAngleRadians,
      sweepAngleRadians,
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      rect,
      startAngleRadians,
      sweepAngleRadians * progress,
      false,
      progressPaint,
    );

    if (beginCapRadius > 0) {
      final beginCapPaint = Paint()..color = color;
      final beginCapCenter = Offset(
        center.dx + radius * cos(startAngleRadians),
        center.dy + radius * sin(startAngleRadians),
      );
      canvas.drawCircle(beginCapCenter, beginCapRadius, beginCapPaint);
    }

    if (endCapRadius > 0) {
      final endCapPaint = Paint()..color = color;
      final endCapCenter = Offset(
        center.dx + radius * cos(endAngleRadians),
        center.dy + radius * sin(endAngleRadians),
      );
      canvas.drawCircle(endCapCenter, endCapRadius, endCapPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularProgressBarPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth ||
        color != oldDelegate.color ||
        startAngle != oldDelegate.startAngle ||
        endAngle != oldDelegate.endAngle ||
        radius != oldDelegate.radius ||
        beginCapRadius != oldDelegate.beginCapRadius ||
        endCapRadius != oldDelegate.endCapRadius;
  }
}
