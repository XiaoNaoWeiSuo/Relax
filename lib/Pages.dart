import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:relax/ReWidget.dart';
//import 'package:percent_indicator/circular_percent_indicator.dart';
import 'Sonpage.dart';
import 'dart:async';
import 'package:camera/camera.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});
  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> with TickerProviderStateMixin {
  late AnimationController _ChatExpandAnimaController;
  late Animation<double> _ChatExpandAnima;
  late AnimationController _ChatLoadAnimaController;
  late Animation<double> _ChatLoadAnima;
  //final PageController _ChatpageController = PageController();

  //页面专场动画控制器
  late AnimationController scaleController;
  late Animation<double> scaleAnimation;
  final FileDispose fileDispose = FileDispose(filename: "chathistory.json");
  double _sliderValue = 0.7;
  String _model = "gpt-3.5-turbo-0301";

  //{"chathistory": {"title":[
  //{"role":"user","messages":"nihao"}
  //]}}
  bool isChatHistoryExpanded = false;
  bool isOtherExpanded = false;
  Map source = {};
  Map historylist = {"chathistory": {}, "temperature": "", "model": ""};

  Future<void> _initializeData() async {
    final value = await fileDispose.readData();
    if (value.isEmpty) {
      historylist["model"] = "gpt-3.5-turbo-0301";
      historylist["temperature"] = 0.7;
      await fileDispose.writeData(historylist);
    } else {
      historylist = value;
      source = value;
    }

    _model = historylist["model"];
    _sliderValue = historylist["temperature"];
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            Navigator.push(
              context,
              AnimatingRoute(
                page: const Chatpage(),
                route: MainChatPage(
                  messages: [],
                  title: "",
                  temperature: _sliderValue,
                  model: _model,
                ),
              ),
            );
            Timer(
              const Duration(milliseconds: 200),
              () {
                // print('worked');

                scaleController.reset();
              },
            );
          }
        },
      );

    scaleAnimation =
        Tween<double>(begin: 0.0, end: 300.0).animate(scaleController);

    _ChatExpandAnimaController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _ChatExpandAnima = CurvedAnimation(
        parent: _ChatExpandAnimaController, curve: Curves.easeOutBack);
    _ChatExpandAnima =
        Tween<double>(begin: 0.0, end: 1.0).animate(_ChatExpandAnima);
    //_ChatExpandAnimaController.forward();
    _ChatLoadAnimaController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _ChatLoadAnima = CurvedAnimation(
        parent: _ChatLoadAnimaController, curve: Curves.easeOutBack);
    _ChatLoadAnima =
        Tween<double>(begin: 0.0, end: 1.0).animate(_ChatLoadAnima);
    _ChatLoadAnimaController.forward();
  }

  @override
  void dispose() {
    _ChatExpandAnimaController.dispose();
    _ChatLoadAnimaController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  void toggleExpand() {
    setState(() {
      isChatHistoryExpanded = !isChatHistoryExpanded;
    });
    if (isChatHistoryExpanded) {
      _ChatExpandAnimaController.forward();
    } else {
      _ChatExpandAnimaController.reverse();
    }
  }

  void othertoggleExpand() {
    setState(() {
      isOtherExpanded = !isOtherExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    //final double statusBarHeight = mediaQueryData.padding.top;
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double ItemSize = screenWidth * 0.05;
    return Stack(
      children: [
        Container(
          decoration:
              const BoxDecoration(color: Color.fromARGB(255, 233, 242, 245)),
          child: Column(children: [
            SizedBox(
              height: ItemSize * 2,
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: ItemSize, left: ItemSize, right: ItemSize),
                child: GestureDetector(
                    onTap: () {
                      toggleExpand();
                    },
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isChatHistoryExpanded
                            ? ItemSize * 10
                            : ItemSize * 3.4,
                        padding: EdgeInsets.only(top: ItemSize * .7),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ItemSize)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: ItemSize,
                                ),
                                AnimatedBuilder(
                                    animation: _ChatLoadAnima,
                                    builder: (context, child) {
                                      return Icon(
                                        RelaxIcons.chat,
                                        color: Colors.blue,
                                        size: ItemSize * 1 +
                                            ItemSize *
                                                0.7 *
                                                _ChatLoadAnima.value,
                                        shadows: [
                                          BoxShadow(
                                              color: Colors.black87
                                                  .withOpacity(0.2),
                                              blurRadius: ItemSize)
                                        ],
                                      );
                                    }),
                                SizedBox(
                                  width: ItemSize / 2,
                                ),
                                Text(
                                  "历史会话",
                                  style: TextStyle(
                                      fontSize: ItemSize * 1.1,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black.withOpacity(0.7)),
                                ),
                                const Expanded(child: SizedBox()),
                                AnimatedBuilder(
                                    animation: _ChatExpandAnima,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                          angle: _ChatExpandAnima.value * -3.14,
                                          child: Icon(
                                            Icons.keyboard_arrow_up,
                                            size: ItemSize * 2.1,
                                            color:
                                                Colors.black.withOpacity(0.7),
                                          ));
                                    }),
                                SizedBox(
                                  width: ItemSize,
                                ),
                              ],
                            ),
                            AnimatedContainer(
                              padding: EdgeInsets.all(ItemSize / 2),
                              //clipBehavior: Clip.hardEdge,
                              duration: const Duration(milliseconds: 300),
                              height:
                                  isChatHistoryExpanded ? ItemSize * 7.2 : 0.0,
                              //width: isChatHistoryExpanded ? widget.options.length * 50.0 : 200,
                              child: historylist["chathistory"].isNotEmpty
                                  ? Scrollbar(
                                      child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                        itemCount:
                                            historylist["chathistory"].length,
                                        itemBuilder: (context, index) {
                                          String key =
                                              historylist["chathistory"]
                                                  .keys
                                                  .elementAt(index);
                                          List value =
                                              historylist["chathistory"][key];
                                          return GestureDetector(
                                            onTap: () async {
                                              final result =
                                                  await Navigator.push(context,
                                                      MaterialPageRoute(
                                                builder: (context) {
                                                  return MainChatPage(
                                                    messages: value,
                                                    title: key,
                                                    temperature: _sliderValue,
                                                    model: _model,
                                                  );
                                                },
                                              ));
                                              setState(() {
                                                historylist = result;
                                              });
                                            },
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    left: ItemSize,
                                                    bottom: ItemSize / 5,
                                                    right: ItemSize / 2),
                                                height: ItemSize * 2,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.all(
                                                          ItemSize / 4),
                                                      width: ItemSize / 6,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      ItemSize),
                                                          color: Colors.blue),
                                                    ),
                                                    SizedBox(
                                                      width: screenWidth * 0.6,
                                                      child: Text(
                                                        value[value.length - 1]
                                                                ["content"]
                                                            .toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: ItemSize),
                                                      ),
                                                    ),
                                                    //const Expanded(child: SizedBox()),
                                                    IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            historylist[
                                                                    "chathistory"]
                                                                .remove(key);
                                                          });
                                                          fileDispose.writeData(
                                                              historylist);
                                                        },
                                                        icon: Icon(
                                                          Icons.highlight_off,
                                                          color: Colors.red
                                                              .withOpacity(0.7),
                                                        ))
                                                  ],
                                                )),
                                          );
                                        },
                                      ),
                                    ))
                                  : const Center(
                                      child: Text("暂无历史记录"),
                                    ),
                            ),
                          ],
                        )))),
            Padding(
                padding: EdgeInsets.only(
                    top: ItemSize, left: ItemSize, right: ItemSize),
                child: GestureDetector(
                    onTap: () {
                      othertoggleExpand();
                    },
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height:
                            isOtherExpanded ? ItemSize * 10 : ItemSize * 3.4,
                        padding: EdgeInsets.only(top: ItemSize * .8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ItemSize)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: ItemSize,
                                ),
                                AnimatedBuilder(
                                    animation: _ChatLoadAnima,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                          angle: _ChatLoadAnima.value * 6.4,
                                          child: Icon(
                                            RelaxIcons.setting,
                                            color: Colors.blue,
                                            size: ItemSize * 1.7,
                                            shadows: [
                                              BoxShadow(
                                                  color: Colors.black87
                                                      .withOpacity(0.2),
                                                  blurRadius: ItemSize)
                                            ],
                                          ));
                                    }),
                                SizedBox(
                                  width: ItemSize / 2,
                                ),
                                Text(
                                  "模型设置",
                                  style: TextStyle(
                                      fontSize: ItemSize * 1.1,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black.withOpacity(0.7)),
                                ),
                                const Expanded(child: SizedBox()),
                                Icon(
                                  Icons.menu,
                                  size: ItemSize * 1.7,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                                SizedBox(
                                  width: ItemSize,
                                ),
                              ],
                            ),
                            AnimatedContainer(
                              padding: EdgeInsets.all(ItemSize / 2),
                              //clipBehavior: Clip.hardEdge,
                              duration: const Duration(milliseconds: 300),
                              height: isOtherExpanded ? ItemSize * 7.4 : 0.0,
                              //width: isChatHistoryExpanded ? widget.options.length * 50.0 : 200,
                              child: SingleChildScrollView(
                                  child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "temperature:  ",
                                        style: TextStyle(
                                            fontSize: ItemSize,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        _sliderValue.toString(),
                                        style: TextStyle(
                                            fontSize: ItemSize,
                                            color: Colors.blue),
                                      )
                                    ],
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      // 自定义分段滑块的外观
                                      activeTrackColor: Colors.blue,
                                      inactiveTrackColor: Colors.grey,
                                      thumbColor: Colors.blue,
                                      overlayColor:
                                          Colors.blue.withOpacity(0.3),
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 10.0),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 20.0),
                                      valueIndicatorColor: Colors.blue,
                                      valueIndicatorTextStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Slider(
                                      value: _sliderValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _sliderValue = newValue;
                                        });
                                        HapticFeedback.lightImpact();
                                        historylist["temperature"] =
                                            _sliderValue;
                                        fileDispose.writeData(historylist);
                                      },
                                      divisions: 10, // 将滑块分成10段
                                      label: '$_sliderValue', // 显示当前值
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "gpt-model:",
                                        style: TextStyle(
                                            fontSize: ItemSize,
                                            color: Colors.black54),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          _model,
                                          style: TextStyle(
                                              fontSize: ItemSize * .85,
                                              color:
                                                  Colors.blue.withOpacity(0.7)),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )),
                            )
                          ],
                        )))),
            const Expanded(child: SizedBox()),

            //Text(source.toString()),
            AnimatedBuilder(
              animation: _ChatLoadAnima,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () {
                    scaleController.forward();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: ItemSize * 5),
                    width: ItemSize * 8 * _ChatLoadAnima.value,
                    height: ItemSize * 2.5 * _ChatLoadAnima.value,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(ItemSize)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                            animation: _ChatLoadAnima,
                            builder: (context, child) {
                              return Icon(
                                RelaxIcons.chat,
                                color: Colors.blue,
                                size: ItemSize * 1 +
                                    ItemSize * 0.7 * _ChatLoadAnima.value,
                                shadows: [
                                  BoxShadow(
                                      color: Colors.black87.withOpacity(0.2),
                                      blurRadius: ItemSize)
                                ],
                              );
                            }),
                        SizedBox(
                          width: ItemSize / 4,
                        ),
                        Text(
                          "开始会话",
                          style: TextStyle(
                              color: Colors.blue.withOpacity(0.7),
                              fontSize: ItemSize * .9,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                );
              },
            )
          ]),
        ),
        Positioned(
          top: screenHeight * .84,
          left: screenWidth / 3.3,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: AnimatedBuilder(
              animation: scaleAnimation,
              builder: (content, child) => Transform.scale(
                scale: scaleAnimation.value,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class RelaxPage extends StatefulWidget {
  const RelaxPage({super.key});
  @override
  State<RelaxPage> createState() => _RelaxPageState();
}

class _RelaxPageState extends State<RelaxPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  int currentbar = 0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animation);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    //final double statusBarHeight = mediaQueryData.padding.top;
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double ItemSize = screenWidth * 0.05;
    return Container(
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 233, 242, 245)),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.only(bottom: ItemSize / 1.5),
                  width: screenWidth,
                  height: screenHeight / 8 * _animation.value,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 170, 235, 6),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(ItemSize * 2),
                          bottomRight: Radius.circular(ItemSize * 2))),
                  child: Column(
                    children: [
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        width: screenWidth * .8,
                        height: ItemSize * 1.7,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentbar = index;
                                });
                              },
                              child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(
                                      left: ItemSize / 2, right: ItemSize / 2),
                                  padding: currentbar == index
                                      ? const EdgeInsets.only(bottom: 5)
                                      : const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                      border: currentbar == index
                                          ? const Border(
                                              bottom: BorderSide(
                                                  width: 2,
                                                  color: Colors.black))
                                          : null),
                                  width: ItemSize * 4.5,
                                  height: ItemSize * 1.2,
                                  child: Center(
                                    child: Text(
                                      Bartext[index],
                                      style: currentbar == index
                                          ? TextStyle(
                                              color: Colors.black,
                                              fontSize: ItemSize * .9)
                                          : TextStyle(
                                              color: Colors.white,
                                              fontSize: ItemSize * .8),
                                    ),
                                  )),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            Expanded(
                child: PageView(
              children: [Meditation()],
            ))
          ],
        ));
  }

  final List<String> Bartext = ["冥想引导", "呼吸训练", "舒缓音乐"];
}

class BottlePage extends StatefulWidget {
  const BottlePage({super.key});
  @override
  State<BottlePage> createState() => _BottlePageState();
}

class _BottlePageState extends State<BottlePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  bool island = false;
  int currentbar = 0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 7000));
    // _animation = CurvedAnimation(
    //     parent: _animationController, curve: Curves.easeOutBack);
    _animation = ColorTween(
      begin: Colors.red,
      end: Colors.blue,
    ).animate(_animationController);
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final double statusBarHeight = mediaQueryData.padding.top;
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double ItemSize = screenWidth * 0.05;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          color: _animation.value,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    island = !island;
                  });
                },
                child: AnimatedContainer(
                  padding:
                      EdgeInsets.only(top: island ? ItemSize : ItemSize / 3.2),
                  curve: Curves.easeOutBack,
                  duration: const Duration(milliseconds: 450),
                  width: island ? screenWidth * 0.72 : screenWidth * 0.6,
                  height: island ? screenHeight * 0.2 : ItemSize * 2,
                  margin: EdgeInsets.only(top: ItemSize * 2),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(ItemSize)),
                  child: Column(
                    children: [
                      Text(
                        "今天感觉怎么样?",
                        style: TextStyle(fontSize: ItemSize * .8),
                      ),
                      island
                          ? Container(
                              margin: EdgeInsets.only(top: ItemSize * 1.5),
                              width: screenWidth * 0.72,
                              height: screenWidth * 0.12,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.all(screenWidth * 0.01),
                                    width: screenWidth * 0.1,
                                    height: screenWidth * 0.1,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(ItemSize),
                                        color: Colors.red),
                                  );
                                },
                              ),
                            )
                          //color: Colors.amber,
                          : Container()
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HeartPage extends StatefulWidget {
  const HeartPage({super.key});
  @override
  State<HeartPage> createState() => _HeartPageState();
}

class _HeartPageState extends State<HeartPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  late bool animationstate;
  int currentlabel = 0;
  @override
  void initState() {
    super.initState();
    animationstate = false;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              animationstate = true;
            });
          }
        },
      );
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animation);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    //final double statusBarHeight = mediaQueryData.padding.top;
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double ItemSize = screenWidth * 0.05;
    return Container(
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 233, 242, 245)),
        child: Stack(
          children: [
            Positioned(
                child: Column(
              children: [
                SizedBox(
                  height: screenHeight / 2.5,
                  width: screenWidth,
                  child: Stack(
                    children: [
                      Positioned(
                          child: Center(
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CircularProgressBar(
                              progress: 0.75 * _animation.value,
                              strokeWidth: ItemSize,
                              color: const Color.fromARGB(255, 122, 216, 8),
                              startAngle: -90.0,
                              endAngle: 270.0,
                              radius: screenWidth * 0.25 * _animation.value,
                              beginCapRadius: ItemSize / 2,
                              endCapRadius: ItemSize / 2,
                            );
                          },
                        ),
                      )),
                      Positioned(
                          child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("75",
                                style: TextStyle(
                                    fontSize: ItemSize * 3,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              "压力",
                              style: TextStyle(
                                  fontSize: ItemSize,
                                  color: Colors.black.withOpacity(0.7)),
                            )
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
              ],
            )),
            //const Expanded(child: SizedBox()),

            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return SizedBox(
                      width: screenWidth,
                      height: screenHeight / 1.5 * _animation.value,
                      child: Column(children: [
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                                onTap: () {
                                  availableCameras().then((cameras) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CameraScreen(
                                                camera: cameras[0],
                                              )),
                                    );
                                  });
                                },
                                child: Container(
                                  height: ItemSize * 1.8,
                                  width: ItemSize * 7,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 199, 199, 199),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(ItemSize),
                                        topRight: Radius.circular(ItemSize),
                                        bottomLeft: Radius.circular(ItemSize),
                                      )),
                                  child: Center(
                                    child: Text(
                                      "点击开始测量",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ItemSize * 0.8),
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          height: screenHeight / 1.7 * _animation.value,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(ItemSize * 3),
                                  topRight: Radius.circular(ItemSize * 3)),
                              gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 181, 240, 43),
                                    Colors.white
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter)),
                          child: Column(
                            children: [
                              Container(
                                clipBehavior: Clip.hardEdge,
                                margin: EdgeInsets.only(top: ItemSize),
                                width: screenWidth * .8,
                                height: ItemSize * 1.8,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(ItemSize)),
                                child: Stack(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      width: screenWidth * .2,
                                      height: ItemSize * 1.8,
                                      margin: EdgeInsets.only(
                                          left:
                                              screenWidth * .2 * currentlabel),
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(ItemSize)),
                                    ),
                                    ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              currentlabel = index;
                                            });
                                          },
                                          child: Container(
                                            color:
                                                Colors.white.withOpacity(0.001),
                                            width: screenWidth * .2,
                                            child: Center(
                                              child: Text(
                                                Heartdata["data"][index]
                                                    ["label"],
                                                style: currentlabel == index
                                                    ? TextStyle(
                                                        //fontFamily: "LayHome",
                                                        color: Colors.white,
                                                        fontSize: ItemSize * .8)
                                                    : TextStyle(
                                                        //fontFamily: "LayHome",
                                                        color: Colors.black,
                                                        fontSize:
                                                            ItemSize * .75),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      //width: screenWidth * .2,
                                      margin: EdgeInsets.all(ItemSize / 2),
                                      child: Text(
                                        "今日${Heartdata["data"][currentlabel]["label"]}",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: ItemSize * .75),
                                      ),
                                    ),
                                    Container(
                                      width: screenWidth / 2 * _animation.value,
                                      height: ItemSize * 5,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(ItemSize)),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            //color: Colors.red,
                                            width: screenWidth / 4,
                                            height: ItemSize * 5,
                                            child: Column(children: [
                                              SizedBox(
                                                width: screenWidth / 4,
                                                height: ItemSize * 2.5,
                                                child: Center(
                                                  child: Text(
                                                    "最低${Heartdata["data"][currentlabel]["label"]}：",
                                                    style: TextStyle(
                                                        fontSize:
                                                            ItemSize * .7),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: screenWidth / 4,
                                                height: ItemSize * 2.5,
                                                child: Center(
                                                  child: Text(
                                                    "最高${Heartdata["data"][currentlabel]["label"]}：",
                                                    style: TextStyle(
                                                        fontSize:
                                                            ItemSize * .7),
                                                  ),
                                                ),
                                              )
                                            ]),
                                          ),
                                          SizedBox(
                                            //color: Colors.red,
                                            width: screenWidth / 4,
                                            height: ItemSize * 5,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: screenWidth / 4,
                                                  height: ItemSize * 2.5,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "${Heartdata["data"][currentlabel]["range"][0]}",
                                                        style: TextStyle(
                                                            fontSize:
                                                                ItemSize * 1.2),
                                                      ),
                                                      SizedBox(
                                                        width: ItemSize / 4,
                                                      ),
                                                      Text(
                                                        "${Heartdata["data"][currentlabel]["item"]}",
                                                        style: TextStyle(
                                                            fontSize:
                                                                ItemSize * 0.8),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: screenWidth / 4,
                                                  height: ItemSize * 2.5,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "${Heartdata["data"][currentlabel]["range"][1]}",
                                                        style: TextStyle(
                                                            fontSize:
                                                                ItemSize * 1.2),
                                                      ),
                                                      SizedBox(
                                                        width: ItemSize / 4,
                                                      ),
                                                      Text(
                                                        "${Heartdata["data"][currentlabel]["item"]}",
                                                        style: TextStyle(
                                                            fontSize:
                                                                ItemSize * 0.8),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: ItemSize / 2,
                                          bottom: ItemSize / 4),
                                      width: screenWidth * .8,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.tips_and_updates,
                                            color: Colors.white,
                                            size: ItemSize,
                                          ),
                                          Text(
                                              "${Heartdata["data"][currentlabel]["tips"]}",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  fontSize: ItemSize * .55))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: screenWidth * .8,
                                      height: ItemSize * 8.6,
                                      padding: EdgeInsets.all(ItemSize / 4),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(ItemSize)),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                  height: ItemSize * 7.5,
                                                  width: ItemSize,
                                                  child:
                                                      MediaQuery.removePadding(
                                                    context: context,
                                                    removeTop: true,
                                                    child: ListView.builder(
                                                      itemCount: Heartdata[
                                                                  "data"]
                                                              [currentlabel]
                                                          ["begin&leave"][2],
                                                      itemBuilder:
                                                          (context, index) {
                                                        return SizedBox(
                                                          height: ItemSize *
                                                              7.5 /
                                                              Heartdata["data"][
                                                                      currentlabel]
                                                                  [
                                                                  "begin&leave"][2],
                                                          width: ItemSize,
                                                          child: Center(
                                                            child: Text(
                                                              currentlabel != 3
                                                                  ? "${Heartdata["data"][currentlabel]["begin&leave"][0] - index * Heartdata["data"][currentlabel]["begin&leave"][1]}"
                                                                  : (Heartdata["data"][currentlabel]["begin&leave"]
                                                                              [
                                                                              0] -
                                                                          index *
                                                                              Heartdata["data"][currentlabel]["begin&leave"][
                                                                                  1])
                                                                      .toStringAsFixed(
                                                                          1),
                                                              style: TextStyle(
                                                                  fontSize: currentlabel != 3
                                                                      ? ItemSize /
                                                                          2
                                                                      : ItemSize /
                                                                          2.5,
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.7)),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )),
                                              Container(
                                                width: screenWidth * .8 -
                                                    ItemSize * 1.5,
                                                height: ItemSize * 7.5,
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        left: BorderSide(
                                                            width: 1,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5)),
                                                        bottom: BorderSide(
                                                            width: 1,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5)))),
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: 7,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 1000),
                                                      width: screenWidth * 0.06,
                                                      margin: EdgeInsets.only(
                                                          top: ItemSize *
                                                              7.5 /
                                                              Heartdata["data"][currentlabel]
                                                                      ["begin&leave"]
                                                                  [2] *
                                                              (Heartdata["data"][currentlabel]["begin&leave"][0] -
                                                                  Heartdata["data"][currentlabel]["table"][index]
                                                                      [0]) /
                                                              Heartdata["data"][currentlabel]
                                                                      ["begin&leave"]
                                                                  [1],
                                                          bottom: (ItemSize *
                                                                  7.5 /
                                                                  Heartdata["data"]
                                                                          [currentlabel]
                                                                      ["begin&leave"][2]) *
                                                              (Heartdata["data"][currentlabel]["table"][index][1] - (Heartdata["data"][currentlabel]["begin&leave"][0] - Heartdata["data"][currentlabel]["begin&leave"][1] * (Heartdata["data"][currentlabel]["begin&leave"][2] - 1))) /
                                                              Heartdata["data"][currentlabel]["begin&leave"][1],
                                                          left: screenWidth * 0.02,
                                                          right: screenWidth * 0.02),
                                                      decoration: BoxDecoration(
                                                          gradient: const LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Color.fromARGB(
                                                                    255,
                                                                    13,
                                                                    141,
                                                                    255),
                                                                Color.fromARGB(
                                                                    255,
                                                                    21,
                                                                    251,
                                                                    197)
                                                              ]),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      ItemSize)),
                                                    );
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            width: screenWidth * .8 -
                                                ItemSize * 1.5,
                                            height: ItemSize * 0.5,
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    left: BorderSide(
                                                        width: 1,
                                                        color: Colors.white))),
                                            margin:
                                                EdgeInsets.only(left: ItemSize),
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: 7,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    width: screenWidth * 0.06,
                                                    margin: EdgeInsets.only(
                                                        left:
                                                            screenWidth * 0.02,
                                                        right:
                                                            screenWidth * 0.02),
                                                    child: Center(
                                                      child: Text(
                                                        "9/${Heartdata["initday"] + index}",
                                                        style: TextStyle(
                                                            fontSize:
                                                                ItemSize / 2),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ]));
                },
              ),
            ),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  top: screenHeight - screenHeight * 0.64 * _animation.value,
                  left: screenWidth * 0.68,
                  child: SizedBox(
                    width: screenWidth / 4,
                    child: Image.asset("assets/image/miniman1.png"),
                  ),
                );
              },
            )
          ],
        ));
  }

  List<String> labeltext = ["心率", "呼吸", "血氧", "报告"];

  List<int> bloodO2 = [98, 95, 96, 97, 93, 95, 92];
  int startday = 3;

  final Map Heartdata = {
    "initday": 3,
    "stress": 0.75,
    "data": [
      {
        "label": "心率", //名
        "range": [66, 105], //最低，最高
        "item": "bpm", //单位
        "tips": "成人在安静，清醒的情况下正常心率范围在60~100bpm哦~", //提示语
        "begin&leave": [120, 10, 7], //最大值，间隔，单位数量
        "table": [
          [110, 70],
          [100, 90],
          [90, 70],
          [100, 60],
          [80, 60],
          [70, 60],
          [110, 60]
        ], //表格数据，默认只存7天
      },
      {
        "label": "呼吸", //名
        "range": [11, 15], //最低，最高
        "item": "bpm", //单位
        "tips": "呼吸频率的正常范围是12~20bpm哦~", //提示语
        "begin&leave": [24, 2, 7], //最大值，间隔，单位数量
        "table": [
          [20, 16],
          [14, 12],
          [24, 16],
          [18, 12],
          [22, 16],
          [20, 14],
          [24, 14]
        ], //表格数据，默认只存7天
      },
      {
        "label": "血氧", //名
        "range": [96, 99], //最低，最高
        "item": "bpm", //单位
        "tips": "动脉血氧饱和度的正常值范围为95%~99%哦~", //提示语
        "begin&leave": [100, 1, 10], //最大值，间隔，单位数量
        "table": [
          [98, 95],
          [99, 94],
          [98, 93],
          [97, 91],
          [97, 91],
          [99, 95],
          [96, 91]
        ], //表格数据，默认只存7天
      },
      {
        "label": "体温", //名
        "range": [36.5, 36.9], //最低，最高
        "item": "℃", //单位
        "tips": "如发现体温异常请尽早就医。", //提示语
        "begin&leave": [37.3, 0.2, 7], //最大值，间隔，单位数量
        "table": [
          [36.5, 36.1],
          [36.9, 36.5],
          [37.1, 36.5],
          [37.3, 36.3],
          [37.3, 36.5],
          [36.7, 36.1],
          [37.1, 36.3]
        ], //表格数据，默认只存7天
      }
    ]
  };
}
