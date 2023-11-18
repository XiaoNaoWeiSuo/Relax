import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'ReWidget.dart';
import 'MainPage.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Relax",
      //home: MyHomePage(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  //页面启动动画控制器
  late AnimationController _loginloadAnimaController;
  late Animation<double> _loginloadAnima;
  //页面专场动画控制器
  late AnimationController scaleController;
  late Animation<double> scaleAnimation;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool pagestate = false;
  @override
  void initState() {
    super.initState();
    scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            Navigator.push(
              context,
              AnimatingRoute(
                page: const MyHomePage(),
                route: const MainPage(),
              ),
            );
            Timer(
              const Duration(milliseconds: 200),
              () {
                // print('worked');
                pagestate = false;
                scaleController.reset();
              },
            );
          }
        },
      );

    scaleAnimation =
        Tween<double>(begin: 0.0, end: 300.0).animate(scaleController);

    _loginloadAnimaController = AnimationController(
        duration: const Duration(milliseconds: 1800), vsync: this);
    _loginloadAnima = CurvedAnimation(
        parent: _loginloadAnimaController, curve: Curves.easeOutCubic);
    _loginloadAnima = Tween<double>(begin: 0, end: 1).animate(_loginloadAnima);
    _loginloadAnimaController.forward();
  }

  @override
  void dispose() {
    _loginloadAnimaController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final double statusBarHeight = mediaQueryData.padding.top;
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double ItemSize = screenWidth * 0.05;
    List<double> barHeights = [
      34.5,
      42.9,
      44.2,
      27.6,
      38.8,
      51.2,
      46.7,
      41.3,
      26.1,
      49.6,
      33.7,
      44.4,
      37.0,
      52.3,
      29.9,
      47.9,
      35.7,
      43.8,
      28.5,
      39.4,
      47.5,
      44.6,
      33.1,
      50.8
    ];
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
              child: AnimatedBuilder(
                animation: _loginloadAnima,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                          child: Container(
                        color: const Color.fromARGB(255, 215, 255, 106),
                      )),
                      Positioned(
                          child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          children: List.generate(barHeights.length, (index) {
                            if (index % 2 != 0) {
                              // 圆角长条
                              return Expanded(
                                  child: Container(
                                height: barHeights[index] *
                                    11 *
                                    _loginloadAnima.value,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 255, 252, 216),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ));
                            } else {
                              return const Expanded(
                                child: SizedBox(),
                              );
                            }
                          }),
                        ),
                      )),
                      Positioned(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 2, // 宽度因子大于1，超出屏幕宽度
                          //heightFactor: 1,
                          child: Container(
                              width: screenWidth * 1.5,
                              height:
                                  screenHeight * 0.75 * _loginloadAnima.value,
                              padding: EdgeInsets.only(
                                  top: ItemSize,
                                  right: ItemSize,
                                  left: ItemSize,
                                  bottom: ItemSize * 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(screenWidth),
                                      topRight: Radius.circular(screenWidth)),
                                  color: Colors.white),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: ItemSize * 3),
                                    width: screenWidth *
                                        0.8 *
                                        _loginloadAnima.value,
                                    height: screenHeight /
                                        3 *
                                        _loginloadAnima.value,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                                width: ItemSize *
                                                    3 *
                                                    _loginloadAnima.value,
                                                height: ItemSize *
                                                    2.5 *
                                                    _loginloadAnima.value,
                                                child: Center(
                                                  child: Text(
                                                    "+86",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize:
                                                            ItemSize * .8),
                                                  ),
                                                )),
                                            Container(
                                              width: 1,
                                              height: ItemSize * 2,
                                              decoration: const BoxDecoration(
                                                  color: Colors.blue),
                                            ),
                                            SizedBox(
                                              width: screenWidth *
                                                  .6 *
                                                  _loginloadAnima.value,
                                              height: ItemSize *
                                                  2.5 *
                                                  _loginloadAnima.value,
                                              child: EditingLine(
                                                  textsize: ItemSize * .8,
                                                  labeltext: "手机号",
                                                  editingController:
                                                      _phoneController),
                                            )
                                          ],
                                        ),
                                        Container(
                                          height: 1,
                                          margin: EdgeInsets.only(
                                              bottom: ItemSize / 4),
                                          width: screenWidth *
                                              0.8 *
                                              _loginloadAnima.value,
                                          color: Colors.black87,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                                width: ItemSize *
                                                    3 *
                                                    _loginloadAnima.value,
                                                height: ItemSize *
                                                    2.5 *
                                                    _loginloadAnima.value,
                                                child: Center(
                                                  child: Text(
                                                    "验证码",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize:
                                                            ItemSize * .8),
                                                  ),
                                                )),
                                            Container(
                                              width: 1,
                                              height: ItemSize * 2,
                                              decoration: const BoxDecoration(
                                                  color: Colors.blue),
                                            ),
                                            SizedBox(
                                              width: screenWidth /
                                                  2.8 *
                                                  _loginloadAnima.value,
                                              height: ItemSize *
                                                  2.5 *
                                                  _loginloadAnima.value,
                                              child: EditingLine(
                                                  textsize: ItemSize * .8,
                                                  labeltext: "验证码",
                                                  editingController:
                                                      _codeController),
                                            ),
                                            const Expanded(child: SizedBox()),
                                            TextButton(
                                                onPressed: () {},
                                                child: Text(
                                                  "获取验证码",
                                                  style: TextStyle(
                                                      fontSize: ItemSize *
                                                          .8 *
                                                          _loginloadAnima
                                                              .value),
                                                ))
                                          ],
                                        ),
                                        Container(
                                          height: 1,
                                          width: screenWidth *
                                              0.8 *
                                              _loginloadAnima.value,
                                          color: Colors.black87,
                                        ),
                                        const Expanded(
                                          child: SizedBox(),
                                        ),
                                        Container(
                                          width: screenWidth *
                                              0.5 *
                                              _loginloadAnima.value,
                                          height: ItemSize * 2,
                                          //color: Colors.amber,
                                          child: FractionallySizedBox(
                                              heightFactor: 1.3 *
                                                  _loginloadAnima
                                                      .value, // 宽度因子大于1，超出屏幕宽度
                                              //heightFactor: 1,
                                              child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: SizedBox(
                                                    width: screenWidth *
                                                        0.2 *
                                                        _loginloadAnima.value,
                                                    height: ItemSize * 2,
                                                    child: const Image(
                                                        image: AssetImage(
                                                            "assets/image/miniman1.png")),
                                                  ))),
                                        ),
                                        GestureDetector(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                pagestate = true;
                                              });
                                              scaleController.forward();
                                            },
                                            child: Container(
                                                width: screenWidth *
                                                    0.6 *
                                                    _loginloadAnima.value,
                                                height: ItemSize *
                                                    2.2 *
                                                    _loginloadAnima.value,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            ItemSize * 2),
                                                    color: Colors.blue),
                                                child: Center(
                                                  child: Text(
                                                    "登陆注册",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: ItemSize),
                                                  ),
                                                )),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            child: const Text("游客登陆"),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                  SizedBox(
                                    //width: screenWidth * 0.8,
                                    height: statusBarHeight,
                                    //color: Colors.red,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RoundCheckBox(
                                            size: ItemSize,
                                            checkedColor: const Color.fromARGB(
                                                255, 194, 241, 64),
                                            checkedWidget: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: ItemSize * .9,
                                            ),
                                            isChecked: true,
                                            onTap: (value) => {}),
                                        SizedBox(
                                          width: ItemSize / 2,
                                        ),
                                        Text.rich(TextSpan(children: [
                                          TextSpan(
                                              text: "我已阅读并同意",
                                              style: TextStyle(
                                                  fontSize: ItemSize / 1.7)),
                                          TextSpan(
                                              text: "《用户协议》",
                                              style: TextStyle(
                                                  fontSize: ItemSize / 1.7,
                                                  color: const Color.fromARGB(
                                                      255, 215, 255, 106))),
                                          TextSpan(
                                              text: "和",
                                              style: TextStyle(
                                                  fontSize: ItemSize / 1.7)),
                                          TextSpan(
                                              text: "《用户协议》",
                                              style: TextStyle(
                                                  fontSize: ItemSize / 1.7,
                                                  color: const Color.fromARGB(
                                                      255, 215, 255, 106)))
                                        ]))
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ),
                      )),
                      Positioned(
                          child: Row(
                        children: List.generate(barHeights.length, (index) {
                          if (index % 2 == 0) {
                            // 圆角长条
                            return Expanded(
                                child: Container(
                              height: barHeights[index] *
                                  ItemSize /
                                  3.3 *
                                  _loginloadAnima.value,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 215, 255, 106),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ));
                          } else {
                            return const Expanded(
                              child: SizedBox(),
                            );
                          }
                        }),
                      )),
                      Positioned(
                          child: FractionallySizedBox(
                              heightFactor: 1.15 *
                                  _loginloadAnima.value, // 宽度因子大于1，超出屏幕宽度
                              //heightFactor: 1,
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    width: screenWidth,
                                    height: screenHeight /
                                        2.5 *
                                        _loginloadAnima.value,
                                    child: const Image(
                                        image: AssetImage(
                                            "assets/image/loginimage.png")),
                                  )))),
                      Positioned(
                        top: screenHeight * 0.59,
                        left: screenWidth / 3.5,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: pagestate
                                ? Colors.blue
                                : Colors.amber.withOpacity(0),
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedBuilder(
                            animation: scaleAnimation,
                            builder: (content, child) => Transform.scale(
                              scale: scaleAnimation.value,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ));
  }
}
