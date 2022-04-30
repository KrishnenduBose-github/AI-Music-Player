// ignore_for_file: prefer_const_constructors
// @dart=2.9
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:alan_voice/alan_callback.dart';
import 'package:radio/models/radio.dart';
import 'package:radio/utils/radio_colors.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio> radios;
  MyRadio _selectedRadio;
  Color _selectedColor;
  bool _isPlaying = false;
  final sugg = [
    "Play",
    "Stop",
    "Next",
    "Previous",
    "Play pop music",
    "Play (music name) song",
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupAlan();
    fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      if (event == PlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "94f58f0f14f4fc5486416689586a0c7e2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedRadio.url);
        break;
      case "play_channel":
        final id = response["id"];
        //_audioPlayer.pause();
        MyRadio newRadio = radios.firstWhere((element) => element.id == id);
        radios.remove(newRadio);
        radios.insert(0, newRadio);
        _playMusic(newRadio.url);
        break;
      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;
      case "prev":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;
      default:
    }
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios[0];
    _selectedColor = Color(int.tryParse(_selectedRadio.color));
    print(_selectedColor);
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.url);
    setState(() {});
  }

  _stopMusic() {
    _audioPlayer.stop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: Container(
            color: _selectedColor,
            child: radios != null
                ? VStack([
                    100.heightBox,
                    "All Channels".text.xl2.white.semiBold.make().px16(),
                    20.heightBox,
                    ListView(
                      padding: Vx.m0,
                      shrinkWrap: true,
                      children: radios
                          .map((e) => ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(e.image),
                                ),
                                title: e.name.text.white.make(),
                                subtitle:
                                    "~ ${e.tagline}".text.white.fade.make(),
                              ))
                          .toList(),
                    ).expand()
                  ])
                : const Offstage(),
          ),
        ),
        body: Stack(
          children: [
            VxAnimatedBox(
                child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                AIColors.primarycolor2,
                _selectedColor ?? AIColors.primarycolor1,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            )).size(context.screenWidth, context.screenHeight).make(),
            VStack([
              AppBar(
                title: "AI Music App".text.xl4.bold.white.make().shimmer(
                    primaryColor: Vx.purple300, secondaryColor: Vx.white),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                centerTitle: true,
              ).h(80.0).p16(),
              // 5.heightBox,
              "Start with - Hey Alan".text.italic.white.make().centered(),
              10.heightBox,
              VxSwiper.builder(
                  itemCount: sugg.length,
                  height: 50.0,
                  viewportFraction: 0.35,
                  autoPlay: true,
                  autoPlayAnimationDuration: 3.seconds,
                  autoPlayCurve: Curves.linear,
                  enableInfiniteScroll: true,
                  itemBuilder: (context, index) {
                    final s = sugg[index];
                    return Chip(
                      label: s.text.make(),
                      backgroundColor: Vx.randomColor,
                    );
                  })
            ]),
            40.heightBox,
            radios != null
                ? VxSwiper.builder(
                    itemCount: radios.length,
                    aspectRatio: context.mdWindowSize == VxWindowSize.xsmall
                        ? 1.0
                        : context.mdWindowSize == VxWindowSize.medium
                            ? 2.0
                            : 3.0,
                    //aspectRatio: 1.0,
                    onPageChanged: (index) {
                      _selectedRadio = radios[index];
                      final colorHex = radios[index].color;
                      _selectedColor = Color(int.parse(colorHex));
                      //print(_selectedColor);
                      setState(() {});
                    },
                    enlargeCenterPage: true,
                    itemBuilder: (context, index) {
                      final rad = radios[index];

                      return VxBox(
                              child: ZStack(
                        [
                          Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: VxBox(
                                child: rad.category.text.white.uppercase
                                    .make()
                                    .px16(),
                              )
                                  .height(40)
                                  .black
                                  .alignCenter
                                  .withRounded(value: 10.0)
                                  .make()),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VStack(
                              [
                                rad.name.text.xl3.white.bold.make(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold.make(),
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            ),
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: [
                                Icon(
                                  CupertinoIcons.play_circle,
                                  color: Colors.white,
                                  size: 80.0,
                                ),
                                10.heightBox,
                                "Double tap to play".text.gray300.make(),
                              ].vStack())
                        ],
                        clip: Clip.antiAlias,
                      ))
                          .clip(Clip.antiAlias)
                          .bgImage(
                            DecorationImage(
                                image: NetworkImage(rad.image),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.3),
                                    BlendMode.darken)),
                          )
                          .withRounded(value: 60.0)
                          .border(color: Colors.black, width: 5.0)
                          .make()
                          .onInkDoubleTap(() {
                        _playMusic(rad.url);
                      }).p16();
                    },
                  ).centered().px16()
                : Center(
                    child: CircularProgressIndicator(
                    color: Colors.white,
                  )),
            Align(
                    alignment: Alignment.bottomCenter,
                    child: [
                      if (_isPlaying)
                        "Playing Now - ${_selectedRadio.name} song"
                            .text
                            .white
                            .makeCentered(),
                      Icon(
                        _isPlaying
                            ? CupertinoIcons.stop_circle
                            : CupertinoIcons.play_circle,
                        color: Colors.white,
                        size: 50.0,
                      ).onInkTap(() {
                        if (_isPlaying == true) {
                          _audioPlayer.stop();
                          // print(_isPlaying);
                        } else {
                          _playMusic(_selectedRadio.url);
                        }
                      }),
                    ].vStack())
                .pOnly(bottom: context.percentHeight * 12)
          ],
          fit: StackFit.expand,
          clipBehavior: Clip.antiAlias,
        ));
  }
}
