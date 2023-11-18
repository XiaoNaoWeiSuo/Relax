// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:relax/ReWidget.dart';
import 'ReWidget.dart';
import "package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart";
import 'ChatGptObject.dart';
import 'dart:async';
import 'package:camera/camera.dart';

class MainChatPage extends StatefulWidget {
  List messages;
  String title;
  double temperature;
  String model;

  MainChatPage(
      {required this.messages,
      required this.title,
      required this.temperature,
      required this.model,
      super.key});
  @override
  State<MainChatPage> createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage>
    with TickerProviderStateMixin {
  //ture表示是AI的消息
  List messages = [
    {"role": "system", "content": "你是一个助手，你的回答尽量简洁，压缩语句，减少修辞"},
    //{"role": "assistant", "content": "你好"},
    {"role": "user", "content": "你好，来玩角色扮演，你是我的一个温暖体贴的心理顾问，你的名字叫小薇"},
    {"role": "assistant", "content": "好的，我将扮演你的知心好友，请开始我们的对话"},
    {"role": "assistant", "content": "你好呀~我是小薇，你的专属心灵顾问。"},
  ];
  final TextEditingController _massageEditingController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController lightanimecontroller;
  late Animation lightanime;
  late AnimationController _animationController;
  late Animation<double> _animation;

  late final GPT _gpt;
  final FileDispose fileDispose = FileDispose(filename: "chathistory.json");
  late Map keepdata;
  bool ischat = false;
  String title = "";

  bool themestate = true;
  @override
  void initState() {
    super.initState();
    _gpt = GPT(model: widget.model, temperature: widget.temperature);
    if (widget.messages.isNotEmpty) {
      messages = widget.messages;
      title = widget.title;
    } else {
      title = generateSessionKey(10);
    }
    //读取历史文件
    fileDispose.readData().then((value) {
      if (value.isEmpty) {
        //此处原本是供设置文件进行数据初始化，但是设置页本身也有数据初始化，故保留其中一个
        //fileDispose.writeData(historylist);
      } else {
        keepdata = value;
      }
      //setState(() {});
    });
    //页面进入动画
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.decelerate);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animation);
    _animationController.forward();
    // 监听ListView滚动位置变化
    lightanimecontroller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    lightanime = ColorTween(
            begin: Colors.blue.withOpacity(0),
            end: const Color.fromARGB(255, 0, 38, 255))
        .animate(lightanimecontroller);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // 释放ScrollController
    _scrollController.dispose();
    lightanimecontroller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void rungpt(String talk) async {
    lightanimecontroller.repeat(reverse: true);
    //messages.add({"role": "user", "content": talk});
    dynamic object = await _gpt.sendRequest(messages);
    setState(() {
      messages.add(object["choices"][0]["message"]);
    });
    keepdata["chathistory"][title] = messages;
    fileDispose.writeData(keepdata);
    ischat = true;
    lightanimecontroller.stop();
    Tomaxposition();
  }

  void _scrollListener() {
    // 当ListView滚动到底部时执行操作
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // 这里可以执行一些操作，如加载更多数据
    }
  }

  void Tomaxposition() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final double statusBarHeight = mediaQueryData.padding.top;
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double ItemSize = screenWidth * 0.05;
    var keyboardSize = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('返回主页'),
        // ),
        body: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Stack(
        children: [
          Positioned(
            child: Column(
              children: [
                AnimatedContainer(
                    width: screenWidth,
                    height: screenHeight * 0.3,
                    duration: const Duration(milliseconds: 500),
                    color: themestate
                        ? const Color.fromARGB(255, 181, 240, 43)
                        : Colors.black,
                    //margin: EdgeInsets.only(bottom: screenHeight / 3),
                    child: Container()),
                AnimatedContainer(
                    width: screenWidth,
                    height: isKeyboardVisible
                        ? screenHeight * 0.7 - keyboardSize
                        : screenHeight * 0.7,
                    duration: const Duration(milliseconds: 500),
                    color: themestate
                        ? Colors.white
                        : const Color.fromARGB(255, 18, 18, 18),
                    //margin: EdgeInsets.only(bottom: screenHeight / 3),
                    child: Container())
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(
                        top: screenHeight * .06, right: ItemSize * 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: ItemSize * 3,
                          child: Image.asset(
                            "assets/image/miniman2.png",
                          ),
                        ),
                        SizedBox(
                          width: ItemSize,
                        )
                      ],
                    )),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                        color: themestate
                            ? Colors.white
                            : const Color.fromARGB(255, 18, 18, 18),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(ItemSize * 2),
                            topRight: Radius.circular(ItemSize * 2))),
                    child: Column(
                      children: [
                        AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: isKeyboardVisible
                                ? screenHeight * .8 - keyboardSize
                                : screenHeight * .8,
                            child: Padding(
                              padding: EdgeInsets.all(ItemSize / 3),
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: messages.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < 3) {
                                      return Container();
                                    } else {
                                      return ChatBubble(
                                          themestate: themestate,
                                          message: messages[index]);
                                    }
                                  },
                                ),
                              ),
                            )),
                        AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: screenWidth,
                                decoration: BoxDecoration(
                                    color: themestate
                                        ? Colors.white
                                        : const Color.fromARGB(255, 59, 59, 59),
                                    borderRadius:
                                        BorderRadius.circular(ItemSize * 1.3),
                                    border: Border.all(
                                      width: 3,
                                      color: const Color.fromARGB(
                                          255, 179, 209, 56),
                                    )),
                                margin: EdgeInsets.only(
                                    left: ItemSize * 1.5,
                                    right: ItemSize * 1.5),
                                // padding: EdgeInsets.only(
                                //     left: ItemSize / 3, right: ItemSize / 3),
                                child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: screenWidth * .6,
                                      // height: ItemSize * 2.5,
                                      padding:
                                          EdgeInsets.only(right: ItemSize / 5),
                                      // decoration: BoxDecoration(
                                      //     color: Colors.white,
                                      //     borderRadius: BorderRadius.circular(
                                      //         ItemSize * 2 -
                                      //             ItemSize * _animation.value),
                                      //     boxShadow: [
                                      //       BoxShadow(
                                      //           color:
                                      //               Colors.black.withOpacity(0.2),
                                      //           blurRadius: ItemSize / 5)
                                      //     ]),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: isKeyboardVisible
                                              ? ItemSize * 10
                                              : ItemSize * 2.3,
                                        ),
                                        child: TextField(
                                          onTap: () {
                                            Tomaxposition();
                                          },
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          controller: _massageEditingController,
                                          maxLines: null,
                                          cursorHeight: ItemSize,
                                          style: TextStyle(
                                              fontSize: ItemSize * .8,
                                              color: themestate
                                                  ? Colors.black
                                                  : Colors.white),
                                          decoration: InputDecoration(
                                              hintText: "聊聊天吧...",
                                              hintStyle: TextStyle(
                                                  color: themestate
                                                      ? Colors.black
                                                      : Colors.white),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  bottom: ItemSize / 2,
                                                  left: ItemSize / 3,
                                                  top: ItemSize / 2)),
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    GestureDetector(
                                      onTap: () {
                                        if (_massageEditingController
                                            .text.isNotEmpty) {
                                          setState(() {
                                            messages.add({
                                              "role": "user",
                                              "content":
                                                  _massageEditingController
                                                      .text,
                                            });
                                            _massageEditingController.clear();
                                          });
                                          Tomaxposition();
                                          rungpt(
                                              _massageEditingController.text);
                                        }
                                      },
                                      child: Container(
                                          width: ItemSize * 4,
                                          height: ItemSize * 2.3,
                                          // margin: EdgeInsets.only(left: ItemSize / 2),
                                          decoration: BoxDecoration(
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //       color: Colors.black87.withOpacity(
                                            //           0.2 * _animation.value),
                                            //       blurRadius: ItemSize / 5)
                                            // ],
                                            borderRadius: BorderRadius.circular(
                                                ItemSize * 2),
                                            color: const Color.fromARGB(
                                                255, 179, 209, 56),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Icon(
                                              //   RelaxIcons.send,
                                              //   size: ItemSize * 1.6,
                                              //   color: themestate
                                              //       ? Colors.white
                                              //       : Colors.black12,
                                              // ),
                                              Text(
                                                "发送",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: ItemSize * .9),
                                              )
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              );
                            })
                      ],
                    ))
              ],
            ),
          ),
          Positioned(
            child: Column(
              children: [
                Container(
                  height: statusBarHeight,
                ),
                Container(
                  width: screenWidth,
                  height: ItemSize * 3,
                  padding: EdgeInsets.only(left: ItemSize),
                  margin: const EdgeInsets.all(0),
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: ItemSize / 2, right: ItemSize),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (ischat) {
                              // keepdata["title"].add(lastSentence);
                              // keepdata["messages"].add(messages);
                              fileDispose.writeData(keepdata);
                            }
                            Navigator.pop(context, keepdata);
                          },
                          child: Icon(
                            RelaxIcons.back,
                            color: themestate
                                ? Colors.white
                                : const Color.fromARGB(255, 255, 240, 102),
                          ),
                        ),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "       小薇",
                              style: TextStyle(
                                  fontSize: ItemSize,
                                  color:
                                      themestate ? Colors.black : Colors.white),
                            ),
                            AnimatedBuilder(
                              animation: lightanime,
                              builder: (context, child) {
                                return Container(
                                  margin: EdgeInsets.only(left: ItemSize / 2),
                                  width: ItemSize / 1.5,
                                  height: ItemSize / 1.5,
                                  decoration: BoxDecoration(
                                      color: lightanime.value,
                                      borderRadius:
                                          BorderRadius.circular(ItemSize)),
                                );
                              },
                            ),
                          ],
                        )),
                        SizedBox(
                          width: screenWidth / 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                themestate = !themestate;
                              });
                            },
                            child: Icon(
                              Icons.brightness_2,
                              color: themestate
                                  ? Colors.white
                                  : const Color.fromARGB(255, 255, 240, 102),
                              size: ItemSize * 1.5,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }));
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({super.key, required this.camera});
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  StreamSubscription<CameraImage>? _imageStreamSubscription;

  double _redRatio = 0.0;
  double _averageBrightness = 0.0;
  bool disposestate = false;
  bool animatestate = false;
  bool _isFlashOn = false; // 闪光灯状态，默认为关闭
  final ScrollController _scrollController = ScrollController();
  //倒计时动画
  late final AnimationController _lownumberanimationController;
  late final Animation<double> _lownumberanimation;

  late final AnimationController _TimeController;
  late final Animation<double> _Timeanimation;

  //late final AnimationController _uistateController;

  void _scrollListener() {
    // 当ListView滚动到底部时执行操作
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // 这里可以执行一些操作，如加载更多数据
    }
  }

  void Tomaxposition() {
    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  @override
  void initState() {
    super.initState();
    _lownumberanimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 8000));

    _lownumberanimation = Tween<double>(begin: 8.0, end: 0.0)
        .animate(_lownumberanimationController);
    _lownumberanimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 动画已经完成
        setState(() {
          animatestate = false;
          _TimeController.forward();
          // average = initialdata.reduce((value, element) => value + element) /
          //     initialdata.length;
          int partitionSize = initialdata.length ~/ 8;

          List<double> maxValues = [];
          List<double> minValues = [];

          for (int i = 0; i < initialdata.length; i += partitionSize) {
            int endIndex = i + partitionSize;
            if (endIndex >= initialdata.length) {
              endIndex = initialdata.length - 1;
            }
            List<double> partition = initialdata.sublist(i, endIndex);
            double maxValue = partition
                .reduce((value, element) => value > element ? value : element);
            double minValue = partition
                .reduce((value, element) => value < element ? value : element);
            maxValues.add(maxValue);
            minValues.add(minValue);
          }
          maxValues.removeRange(0, 3);
          minValues.removeRange(0, 3);
          maxAverage = maxValues.reduce((value, element) => value + element) /
              maxValues.length;
          minAverage = minValues.reduce((value, element) => value + element) /
              minValues.length;

          range = (maxAverage - minAverage);
          listitem = range / 1000;
        });
      }
    });

    _TimeController =
        AnimationController(vsync: this, duration: Duration(seconds: 60));
    _Timeanimation = Tween(begin: 60.0, end: 0.0).animate(_TimeController);
    _TimeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        FileDispose rwdata = FileDispose(filename: "heartdata");
        rwdata.writeData(HeartData);

        setState(() {
          tiptext = "采集完成";
        });
      }
    });
    //_scrollController.addListener(_scrollListener); //波形图监听
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize().then((_) {
      _controller.setExposureMode(ExposureMode.auto); // 禁用自动曝光
      _controller.setFlashMode(FlashMode.off);
      _startImageStream();
    });
  }

  @override
  void dispose() {
    _stopImageStream();
    _controller.stopImageStream();
    _controller.dispose();
    _TimeController.dispose();
    _lownumberanimationController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _startImageStream() {
    _imageStreamSubscription =
        _controller.startImageStream((CameraImage image) {
      detectimageParameter(image);
      //_calculateBrightness(image);
    }) as StreamSubscription<CameraImage>?;
  }

  void _stopImageStream() {
    _imageStreamSubscription?.cancel();
    _imageStreamSubscription = null;
  }

  Future<void> detectimageParameter(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;

    int redPixelCount = 0;
    double totalBrightness = 0;
    int totalPixelCount = width * height;

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int pixel = image.planes[0].bytes[y * width + x];
        final brightness = (pixel & 0xFF);
        totalBrightness += brightness;

        final int uvIndex =
            uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // Check if the pixel is "red"
        int insertnumber = 0; //红色干扰因子
        if (r > g + insertnumber && r > b + insertnumber) {
          redPixelCount++;
        }
      }
    }
    // Calculate the light
    final numPixels = width * height;
    final avgBrightness = totalBrightness / numPixels;
    final normalizedBrightness = avgBrightness / 255.0;
    final roundedBrightness =
        double.parse(normalizedBrightness.toStringAsFixed(8));

    // Calculate the red ratio
    double redRatio = redPixelCount / totalPixelCount;
    setState(() {
      _redRatio = redRatio;
      _averageBrightness = roundedBrightness;
      if (redRatio == 1.0 && !disposestate) {
        disposestate = true;
        // initialdata = [];
        // HeartData = [];
        if (!_lownumberanimationController.isCompleted) {
          animatestate = true;

          _lownumberanimationController.forward();
        }
      } else if (disposestate && redRatio != 1.0) {
        disposestate = false;
        animatestate = false;
        initialdata = [];
        HeartData = [];
        _lownumberanimationController.reset();
        _TimeController.reset();
      } else if (disposestate && redRatio == 1.0) {
        if (animatestate) {
          initialdata.add(roundedBrightness);
        } else {
          double effectdata = (roundedBrightness - minAverage) /
              listitem; //减去均值最小值，除以单位值，得到的数值是镜像的
          HeartData.add(effectdata); //有效波形
          Tomaxposition();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double statusBarHeight = mediaQueryData.padding.top;
    final double itemSize = screenWidth * 0.05;
    final double listitemSize = itemSize / 100;
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  Container(
                    //color: Color.fromARGB(255, 255, 255, 255),
                    height: statusBarHeight,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                        onTap: () {
                          //_controller.dispose();
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                            width: itemSize * 2.5,
                            height: itemSize * 3,
                            child: Center(
                              child: Icon(
                                RelaxIcons.back,
                                color: Colors.blue,
                                size: itemSize * 1.3,
                              ),
                            ))),
                  ),
                  SizedBox(
                    height: itemSize,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: const Color.fromARGB(62, 0, 0, 0),
                              blurRadius: itemSize),
                        ],
                        borderRadius: BorderRadius.circular(screenWidth * 0.55),
                        border: Border.all(width: 2, color: Colors.white)),
                    width: screenWidth * 0.55,
                    height: screenWidth * 0.55,
                    child: ClipOval(
                        child: Stack(
                      children: [
                        Positioned(
                            child: SizedBox(
                          width: screenWidth * 0.55,
                          height: screenWidth * 0.55,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: CameraPreview(_controller),
                          ),
                        )),
                        Positioned(
                            child: disposestate
                                ? AcrylicContainer(
                                    width: screenWidth * 0.55,
                                    height: screenWidth * 0.55,
                                    interlayercolor: Colors.white,
                                    radius: 10,
                                    borderradius: screenWidth * 0.55,
                                    opacity: 0.1,
                                    padding: const EdgeInsets.all(1),
                                    margin: EdgeInsets.all(itemSize),
                                    child: Center(
                                        child: !animatestate
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    tiptext,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            itemSize * 0.7),
                                                  ),
                                                  AnimatedBuilder(
                                                      animation: _Timeanimation,
                                                      builder: (context,
                                                              child) =>
                                                          Text(
                                                            _Timeanimation.value
                                                                .toStringAsFixed(
                                                                    1),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    itemSize *
                                                                        2),
                                                          )),
                                                ],
                                              )
                                            : AnimatedBuilder(
                                                animation: _lownumberanimation,
                                                builder: (context, child) =>
                                                    Text(
                                                  _lownumberanimation.value
                                                      .toStringAsFixed(0),
                                                  style: TextStyle(
                                                      fontSize: itemSize * 3,
                                                      color: Colors.white),
                                                ),
                                              )))
                                : Container())
                      ],
                    )),
                  ),
                  SizedBox(
                    height: itemSize,
                  ),
                  Container(
                      width: screenWidth,
                      height: itemSize * 12,
                      padding: EdgeInsets.only(
                        top: itemSize,
                      ),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 5, 26, 50)),
                      child: Stack(
                        children: [
                          Positioned(
                            child: ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: min(HeartData.length,
                                  screenWidth.toInt()), // 限制最多展示屏幕宽度
                              itemBuilder: (context, index) {
                                int dataIndex =
                                    HeartData.length - 1 - index; // 倒序获取数据
                                double heartValue = HeartData[dataIndex];

                                return SizedBox(
                                  width: 1,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: heartValue * listitemSize / 3.5,
                                        child: Container(
                                          width: 1,
                                          height: 3,
                                          color: const Color.fromARGB(
                                              255, 239, 137, 130),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                              child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white.withOpacity(0.4)),
                                    child: Text(
                                      disposestate
                                          ? animatestate
                                              ? "正在计算..."
                                              : "${minAverage.toStringAsFixed(6)}~${maxAverage.toStringAsFixed(6)}"
                                          : "波动范围",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )))
                        ],
                      )),
                  SizedBox(
                    height: itemSize,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isFlashOn = !_isFlashOn; // 切换闪光灯状态
                        if (_isFlashOn) {
                          _controller.setFlashMode(FlashMode.torch); // 开启闪光灯
                        } else {
                          _controller.setFlashMode(FlashMode.off); // 关闭闪光灯
                        }
                      });
                    },
                    child: Text(_isFlashOn ? '关闭闪光灯' : '开启闪光灯'),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  String tiptext = "保持身体静止";
  double maxAverage = 0; //最大值均值
  double minAverage = 0; //最小值均值
  late double range; //有效范围
  late double listitem; //当前数据的单位尺寸
  List<double> initialdata = []; //
  List<double> HeartData = [];
}

class _MeditationState extends State<Meditation> {
  List<List<dynamic>> whitenoise = [
    ["audio/birds.mp3", false, AudioPlayer(), "assets/bgimage/brids.jpg", 1.0],
    [
      "audio/crickets.mp3",
      false,
      AudioPlayer(),
      "assets/bgimage/crickets.jpg",
      1.0
    ],
    ["audio/fire.mp3", false, AudioPlayer(), "assets/bgimage/fire.jpg", 1.0],
    [
      "audio/people.mp3",
      false,
      AudioPlayer(),
      "assets/bgimage/people.jpg",
      1.0
    ],
    ["audio/rain.mp3", false, AudioPlayer(), "assets/bgimage/rain.jpg", 1.0],
    ["audio/sbowl.mp3", false, AudioPlayer(), "assets/bgimage/sbowl.jpg", 1.0],
    [
      "audio/thunder.mp3",
      false,
      AudioPlayer(),
      "assets/bgimage/thunder.jpg",
      1.0
    ],
    ["audio/waves.mp3", false, AudioPlayer(), "assets/bgimage/waves.jpg", 1.0],
    ["audio/wind.mp3", false, AudioPlayer(), "assets/bgimage/wind.jpg", 1.0]
  ];

  @override
  void initState() {
    super.initState();
    for (var noise in whitenoise) {
      noise[2].onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed) {
          setState(() {
            noise[1] = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (var noise in whitenoise) {
      noise[2].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double statusBarHeight = mediaQueryData.padding.top;
    final double itemSize = screenWidth * 0.05;

    return Scaffold(
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              width: screenWidth,
              height: screenHeight / 3,
              margin: EdgeInsets.all(itemSize),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: whitenoise.length,
                itemBuilder: (context, index) {
                  return Container(
                    clipBehavior: Clip.hardEdge,
                    width: screenWidth / 5,
                    height: screenHeight / 3,
                    margin: EdgeInsets.all(itemSize / 4),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: itemSize / 4),
                      ],
                      borderRadius: BorderRadius.circular(itemSize),
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: screenWidth / 5,
                          height: screenHeight / 3,
                          child: Image.asset(
                            whitenoise[index][3],
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(itemSize),
                          ),
                          width: screenWidth / 5,
                          height: screenHeight / 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RotatedBox(
                                  quarterTurns: 3, // 顺时针旋转 3/4 圈
                                  child: Slider(
                                    value: whitenoise[index][4],
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: (value) {
                                      setState(() {
                                        whitenoise[index][4] = value;
                                      });
                                      setVolume(index, value);
                                    },
                                  )),
                              IconButton(
                                icon: Icon(
                                  whitenoise[index][1]
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: itemSize * 1.5,
                                ),
                                onPressed: () {
                                  setState(() {
                                    whitenoise[index][1] =
                                        !whitenoise[index][1];
                                  });
                                  volumn(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: screenWidth / 1.5,
              height: itemSize * 4,
              margin: EdgeInsets.only(bottom: itemSize),
              padding: EdgeInsets.all(itemSize / 2),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 236, 236, 236),
                  borderRadius: BorderRadius.circular(itemSize),
                  border: Border.all(width: 2, color: Colors.white)),
              child: Center(
                child: Text(
                  "上面提供了9中采集自社会大自然的声音，你可以单独控制同时播放多个声音，以调配出最适合你的白噪音，祝你心情愉快。",
                  style: TextStyle(
                      fontSize: itemSize * .65,
                      color: Colors.black.withOpacity(0.6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void volumn(int index) async {
    if (whitenoise[index][1]) {
      await whitenoise[index][2].setSourceAsset(whitenoise[index][0]);
      await whitenoise[index][2].setVolume(whitenoise[index][4]);
      await whitenoise[index][2].setReleaseMode(ReleaseMode.loop);
      await whitenoise[index][2].resume();
    } else {
      await whitenoise[index][2].stop();
    }
  }

  void setVolume(int index, double volume) {
    whitenoise[index][4] = volume;
    whitenoise[index][2].setVolume(volume);
  }
}

class Meditation extends StatefulWidget {
  @override
  _MeditationState createState() => _MeditationState();
}
