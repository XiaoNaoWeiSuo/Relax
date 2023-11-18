// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:relax/ReWidget.dart';
//import 'package:roundcheckbox/roundcheckbox.dart';
//import 'ReWidget.dart';
import 'Pages.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _MainloadAnimaController;
  late Animation<double> _MainloadAnima;

  final PageController _MainPageController = PageController();

  //int checkstate = 0;
  var currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _MainloadAnimaController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _MainloadAnima = CurvedAnimation(
        parent: _MainloadAnimaController, curve: Curves.easeOutBack);
    _MainloadAnima = Tween<double>(begin: 0, end: 1).animate(_MainloadAnima);
    _MainloadAnimaController.forward();
  }

  @override
  void dispose() {
    _MainloadAnimaController.dispose();
    super.dispose();
  }

  void ChangePage() {
    _MainPageController.jumpToPage(
      currentIndex,
      // duration: const Duration(milliseconds: 400),
      // curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final double screenWidth = mediaQueryData.size.width;
    final double screenHeight = mediaQueryData.size.height;
    final double ItemSize = screenWidth * 0.05;
    return Scaffold(
        body: WillPopScope(
            onWillPop: () async {
              // 屏蔽返回上一页
              return false;
            },
            child: Stack(
              children: [
                PageView(
                  controller: _MainPageController,
                  onPageChanged: (value) {
                    setState(() {
                      currentIndex = value;
                    });
                  },
                  children: const [
                    Chatpage(),
                    RelaxPage(),
                    BottlePage(),
                    HeartPage()
                  ],
                ),
                Positioned(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedBuilder(
                          animation: _MainloadAnima,
                          builder: (context, child) {
                            return Container(
                              margin: EdgeInsets.all(20),
                              height: screenWidth * .155,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.15),
                                    blurRadius: 30,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: ListView.builder(
                                itemCount: 4,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * .024),
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      currentIndex = index;
                                      ChangePage();
                                      HapticFeedback.lightImpact();
                                    });
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: screenWidth * .2125,
                                        child: Center(
                                          child: AnimatedContainer(
                                            duration: Duration(seconds: 1),
                                            curve:
                                                Curves.fastLinearToSlowEaseIn,
                                            height: index == currentIndex
                                                ? screenWidth * .12
                                                : 0,
                                            width: index == currentIndex
                                                ? screenWidth * .2125
                                                : 0,
                                            decoration: BoxDecoration(
                                              color: index == currentIndex
                                                  ? Colors.blueAccent
                                                      .withOpacity(.2)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth * .2125,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          listOfIcons[index],
                                          size: screenWidth * .076,
                                          color: index == currentIndex
                                              ? Colors.blueAccent
                                              : Colors.black26,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ))),
              ],
            )));
  }

  List<IconData> listOfIcons = [
    RelaxIcons.chat,
    RelaxIcons.rest2,
    RelaxIcons.floatbottle2,
    RelaxIcons.heart2,
  ];
}
