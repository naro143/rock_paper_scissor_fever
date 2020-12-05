import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rock_paper_scissor_fever/rock_paper_scissor_icons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Rock Paper Scissor Fever',
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
          defaultTextColor: Color(0xFF303E57),
          accentColor: Color(0xFF7B79FC),
          variantColor: Colors.black38,
          baseColor: Color(0xFFF8F9FC),
          depth: 8,
          intensity: 0.5,
          lightSource: LightSource.topLeft),
      home: Material(
        child: NeumorphicBackground(
          child: MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final hands = ["rock", "scissor", "paper"];
  final handIcons = [
    RockPaperScissor.rock,
    RockPaperScissor.scissor,
    RockPaperScissor.paper,
  ];
  final bonusCounts = [20, 1, 7, 4, 10, 2, 5, 1];
  final random = Random();
  int _coinCounts;
  int _bonusIndex;
  int _pHandIndex;
  int _eHandIndex;
  bool _isPlaying;
  int _result;

  @override
  void initState() {
    super.initState();
    _coinCounts = 20;
    _isPlaying = false;
    _result = 0;
    _pHandIndex = 9;
    _eHandIndex = 0;
    _bonusIndex = 9;
  }

  void play({bool isFree = false}) {
    setState(() {
      _pHandIndex = 9;
      _bonusIndex = 9;
      _result = 0;
      _isPlaying = true;
      _coinCounts -= isFree ? 0 : 1;
      _eHandIndex = random.nextInt(hands.length);
    });
  }

  int judge() {
    if (_pHandIndex == _eHandIndex) {
      return 0;
    }
    if ((_pHandIndex == 2 && _eHandIndex == 0) || _pHandIndex < _eHandIndex) {
      return 1;
    }
    return -1;
  }

  void result(int pHandIndex) {
    setState(() {
      _isPlaying = false;
      _pHandIndex = pHandIndex;
    });
    int result = judge();
    if (result == 0) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        play(isFree: true);
      });
      return;
    }
    setState(() {
      _result = result;
    });
    if (result == 1) {
      prise();
      return;
    }
  }

  void prise() {
    int bIndex = random.nextInt(bonusCounts.length);
    setState(() {
      _bonusIndex = bIndex;
      _coinCounts += bonusCounts[bIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: NeumorphicText(
              "Rock Paper Scissor Fever",
              style: NeumorphicStyle(
                depth: 1, //customize depth here
                color: NeumorphicTheme.defaultTextColor(
                    context), //customize color here
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(child: _buildDisplay(context)),
          SizedBox(height: 30),
          _buildHandButtons(context),
          SizedBox(height: 30),
          NeumorphicButton(
            style: NeumorphicStyle(
              intensity: 0.8,
            ),
            margin: EdgeInsets.symmetric(horizontal: 14.0),
            onPressed: _isPlaying ? null : () => play(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$_coinCounts",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    shadows: [
                      Shadow(
                          color: Colors.black38,
                          offset: Offset(1.0, 1.0),
                          blurRadius: 2)
                    ],
                    color: NeumorphicTheme.defaultTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay(BuildContext context) {
    final alignments = [
      Alignment.topCenter,
      Alignment(0.7, -0.7),
      Alignment.centerLeft,
      Alignment(0.7, 0.7),
      Alignment.bottomCenter,
      Alignment(-0.7, 0.7),
      Alignment.centerRight,
      Alignment(-0.7, -0.7)
    ];
    final List<Widget> children = List<Widget>.generate(9, (index) {
      if (index == 8) {
        return Neumorphic(
          style: NeumorphicStyle(
            depth: 14,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          margin: EdgeInsets.all(50),
          child: Neumorphic(
            style: NeumorphicStyle(
              depth: -8,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            margin: EdgeInsets.all(10),
            child: Center(
              child: NeumorphicIcon(
                _isPlaying ? Icons.help_outline : handIcons[_eHandIndex],
                size: 180,
                style: NeumorphicStyle(
                  color: _result < 1
                      ? NeumorphicTheme.accentColor(context)
                      : NeumorphicTheme.baseColor(context),
                ),
              ),
            ),
          ),
        );
      }
      return Align(
        alignment: alignments[index],
        child: _createNumber(context, index),
      );
    });

    return AspectRatio(
      aspectRatio: 1,
      child: Neumorphic(
        margin: EdgeInsets.all(14),
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.circle(),
        ),
        child: Stack(
          children: children,
        ),
      ),
    );
  }

  Widget _createNumber(BuildContext context, int index) {
    return Neumorphic(
      margin: EdgeInsets.all(8.0),
      style: NeumorphicStyle(
        depth: 0,
      ),
      child: Text(
        "${bonusCounts[index]}",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 32,
          shadows: [
            Shadow(
                color: Colors.black38, offset: Offset(1.0, 1.0), blurRadius: 2)
          ],
          color: index == _bonusIndex
              ? NeumorphicTheme.accentColor(context)
              : NeumorphicTheme.baseColor(context),
        ),
      ),
    );
  }

  Widget _buildHandButtons(BuildContext context) {
    final List<Widget> children = List.generate(
        3,
        (index) => NeumorphicButton(
              onPressed: () => _isPlaying ? result(index) : null,
              style: NeumorphicStyle(
                intensity: 0.8,
                shape: NeumorphicShape.convex,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              child: NeumorphicIcon(
                handIcons[index],
                size: 60,
                style: NeumorphicStyle(
                  intensity: 0.8,
                  color: _isPlaying || (0 <= _result && _pHandIndex == index)
                      ? NeumorphicTheme.accentColor(context)
                      : NeumorphicTheme.baseColor(context),
                ),
              ),
            ));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }
}
