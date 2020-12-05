import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rock_paper_scissor_fever/rock_paper_scissor_icons.dart';
import 'package:rxdart/rxdart.dart';

enum Status {
  init,
  playing,
  judge,
  prise,
  win,
  draw,
  lose,
}
final hands = ["rock", "scissor", "paper"];
final handIcons = [
  RockPaperScissor.rock,
  RockPaperScissor.scissor,
  RockPaperScissor.paper,
];
final bonusCounts = [20, 1, 7, 4, 10, 2, 5, 1];

final alignments = [
  Alignment.topCenter,
  Alignment(0.7, -0.7),
  Alignment.centerRight,
  Alignment(0.7, 0.7),
  Alignment.bottomCenter,
  Alignment(-0.7, 0.7),
  Alignment.centerLeft,
  Alignment(-0.7, -0.7)
];

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

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainContent(),
    );
  }
}

class MainContent extends StatefulWidget {
  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  final random = Random();

  final _onCoinCountsChange = BehaviorSubject<int>.seeded(20);
  final _onBonusIndexChange = BehaviorSubject<int>.seeded(9);
  final _onPHandIndexChange = BehaviorSubject<int>.seeded(9);
  final _onEHandIndexChange = BehaviorSubject<int>.seeded(0);
  final _onStatusChange = BehaviorSubject<Status>.seeded(Status.init);

  @override
  void initState() {
    _onStatusChange.stream.listen((event) async {
      switch (event) {
        case Status.playing:
          play();
          break;
        case Status.judge:
          judge();
          break;
        case Status.draw:
          Future.delayed(const Duration(milliseconds: 1500), () {
            _onCoinCountsChange.sink.add(_onCoinCountsChange.stream.value + 1);
            _onStatusChange.sink.add(Status.playing);
          });
          break;
        case Status.prise:
          prise();
          break;
        case Status.win:
          break;
        case Status.lose:
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _onCoinCountsChange.close();
    _onBonusIndexChange.close();
    _onPHandIndexChange.close();
    _onEHandIndexChange.close();
    _onStatusChange.close();
    super.dispose();
  }

  void play({bool isFree = false}) {
    _onPHandIndexChange.sink.add(9);
    _onBonusIndexChange.sink.add(9);
    _onEHandIndexChange.sink.add(random.nextInt(hands.length));
    if (!isFree) {
      _onCoinCountsChange.sink.add(_onCoinCountsChange.stream.value - 1);
    }
  }

  void judge() {
    if (_onPHandIndexChange.stream.value == _onEHandIndexChange.stream.value) {
      _onStatusChange.sink.add(Status.draw);
    } else if ((_onPHandIndexChange.stream.value == 2 &&
            _onEHandIndexChange.stream.value == 0) ||
        _onEHandIndexChange.stream.value - _onPHandIndexChange.stream.value ==
            1) {
      _onStatusChange.sink.add(Status.prise);
    } else {
      _onStatusChange.sink.add(Status.lose);
    }
  }

  void prise() async {
    int value = await roulette();
    _onCoinCountsChange.sink
        .add(_onCoinCountsChange.stream.value + bonusCounts[value]);
  }

  Future<int> roulette() async {
    int bIndex = random.nextInt(bonusCounts.length);
    int moveCount = 10 + random.nextInt(8);
    int interval = 300;
    int ticks = bIndex + moveCount;

    Timer.periodic(Duration(milliseconds: interval), (Timer timer) {
      if (ticks == bIndex) {
        timer.cancel();
      } else {
        ticks -= 1;
        _onBonusIndexChange.sink.add(ticks % bonusCounts.length);
      }
    });

    await Future.delayed(Duration(milliseconds: interval * moveCount));
    _onStatusChange.sink.add(Status.win);
    return bIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
          child: _buildTitle(context),
        ),
        Flexible(
          child: Display(
            bonusIndexStream: _onBonusIndexChange.stream,
            eHandIndexStream: _onEHandIndexChange.stream,
            statusStream: _onStatusChange.stream,
            eHandIndexSink: _onEHandIndexChange.sink,
            statusSink: _onStatusChange.sink,
          ),
        ),
        SizedBox(height: 30),
        _buildHandButtons(context),
        SizedBox(height: 30),
        PlayButton(
          coinCountsStream: _onCoinCountsChange.stream,
          statusStream: _onStatusChange.stream,
          statusSink: _onStatusChange.sink,
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return NeumorphicText(
      "Rock Paper Scissor Fever",
      style: NeumorphicStyle(
        depth: 1, //customize depth here
        color: NeumorphicTheme.defaultTextColor(context), //customize color here
      ),
      textStyle: NeumorphicTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHandButtons(BuildContext context) {
    final List<Widget> children = List.generate(
        3,
        (index) => HandButton(
              index: index,
              pHandIndexStream: _onPHandIndexChange.stream,
              statusStream: _onStatusChange.stream,
              pHandIndexSink: _onPHandIndexChange.sink,
              statusSink: _onStatusChange.sink,
            ));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }
}

class Display extends StatelessWidget {
  final Stream<int> bonusIndexStream;
  final Stream<int> eHandIndexStream;
  final Stream<Status> statusStream;
  final StreamSink<int> eHandIndexSink;
  final StreamSink<Status> statusSink;

  Display(
      {this.bonusIndexStream,
      this.eHandIndexStream,
      this.statusStream,
      this.eHandIndexSink,
      this.statusSink});

  @override
  Widget build(BuildContext context) {
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
            child: StreamBuilder(
              initialData: Status.init,
              stream: this.statusStream,
              builder: (BuildContext context, AsyncSnapshot<Status> sSnapShot) {
                return Center(
                  child: StreamBuilder(
                    initialData: 0,
                    stream: this.eHandIndexStream,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> eSnapShot) {
                      return NeumorphicIcon(
                        sSnapShot.data == Status.playing
                            ? Icons.help_outline
                            : handIcons[eSnapShot.data],
                        size: 180,
                        style: NeumorphicStyle(
                          color: sSnapShot.data == Status.lose ||
                                  sSnapShot.data == Status.draw
                              ? NeumorphicTheme.accentColor(context)
                              : NeumorphicTheme.baseColor(context),
                        ),
                      );
                    },
                  ),
                );
              },
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
      child: StreamBuilder(
        initialData: 9,
        stream: this.bonusIndexStream,
        builder: (BuildContext context, AsyncSnapshot<int> snapShot) {
          return Text(
            "${bonusCounts[index]}",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 32,
              shadows: [
                Shadow(
                    color: Colors.black38,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 2)
              ],
              color: snapShot.data == index
                  ? NeumorphicTheme.accentColor(context)
                  : NeumorphicTheme.baseColor(context),
            ),
          );
        },
      ),
    );
  }
}

class HandButton extends StatelessWidget {
  final int index;
  final Stream<int> pHandIndexStream;
  final Stream<Status> statusStream;
  final StreamSink<int> pHandIndexSink;
  final StreamSink<Status> statusSink;

  HandButton(
      {this.index,
      this.pHandIndexStream,
      this.statusStream,
      this.pHandIndexSink,
      this.statusSink});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: Status.init,
      stream: this.statusStream,
      builder: (BuildContext context, AsyncSnapshot<Status> sSnapShot) {
        return NeumorphicButton(
          onPressed: () {
            if (sSnapShot.data == Status.playing) {
              this.pHandIndexSink.add(index);
              this.statusSink.add(Status.judge);
            }
          },
          style: NeumorphicStyle(
            intensity: 0.8,
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          child: StreamBuilder(
            initialData: 9,
            stream: this.pHandIndexStream,
            builder: (BuildContext context, AsyncSnapshot<int> pSnapShot) {
              return NeumorphicIcon(
                handIcons[index],
                size: 60,
                style: NeumorphicStyle(
                  intensity: 0.8,
                  color: sSnapShot.data == Status.playing ||
                          ((sSnapShot.data == Status.win ||
                                  sSnapShot.data == Status.draw) &&
                              pSnapShot.data == index)
                      ? NeumorphicTheme.accentColor(context)
                      : NeumorphicTheme.baseColor(context),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  final Stream<int> coinCountsStream;
  final Stream<Status> statusStream;
  final StreamSink<Status> statusSink;

  PlayButton({this.coinCountsStream, this.statusStream, this.statusSink});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: Status.init,
      stream: this.statusStream,
      builder: (BuildContext context, AsyncSnapshot<Status> snapShot) {
        return NeumorphicButton(
          style: NeumorphicStyle(
            intensity: 0.8,
          ),
          margin: EdgeInsets.symmetric(horizontal: 14.0),
          onPressed: snapShot.data == Status.playing ||
                  snapShot.data == Status.draw ||
                  snapShot.data == Status.prise
              ? null
              : () => this.statusSink.add(Status.playing),
          child: _buildText(context),
        );
      },
    );
  }

  Widget _buildText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder(
          initialData: 20,
          stream: this.coinCountsStream,
          builder: (BuildContext context, AsyncSnapshot<int> snapShot) {
            return Text(
              "${snapShot.data}",
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
            );
          },
        ),
      ],
    );
  }
}
