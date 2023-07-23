import 'dart:async';

import 'package:av_app/pages/InfoPage.dart';
import 'package:av_app/pages/MapPage.dart';
import 'package:av_app/pages/UserPage.dart';
import 'package:av_app/pages/NewsPage.dart';
import 'package:av_app/services/DataService.dart';
import 'package:av_app/widgets/ProgramTabView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'models/EventModel.dart';
import 'pages/EventPage.dart';
import 'pages/LoginPage.dart';
import 'pages/ProgramPage.dart';
import 'styles/Styles.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:badges/badges.dart' as badges;

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://jyghacisbuntbrshhhey.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5Z2hhY2lzYnVudGJyc2hoaGV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODIxMjAyMjksImV4cCI6MTk5NzY5NjIyOX0.SLVxu1YRl2iBYRqk2LTm541E0lwBiP4FBebN8PS0Rqg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: MyHomePage.HOME_PAGE,
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          fontFamily: 'RussoOne',
          secondaryHeaderColor: const Color(0xFFBA5D3F),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: primarySwatch)
              .copyWith(background: backgroundColor)),
        home: const MyHomePage(title: MyHomePage.HOME_PAGE),
        initialRoute: "/",
        routes: {
          MapPage.ROUTE: (context) => const MapPage(),
          EventPage.ROUTE: (context) => const EventPage(),
          InfoPage.ROUTE: (context) => const InfoPage(),
          UserPage.ROUTE: (context) {
            if(!DataService.isLoggedIn())
              {
                return const LoginPage();
              }
            return const UserPage();
          },
          LoginPage.ROUTE: (context) => const LoginPage(),
        }
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const HOME_PAGE = 'Absolventský Velehrad';

  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

String userName = "";
  @override
  void initState() {
    super.initState();
    DataService.tryAuthUser().then((loggedIn) {
      setState(() {});
      if(loggedIn)
        {
          loadUserData();
        }

    });
    initializeDateFormatting();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    width: 80,
                    semanticsLabel: 'Absolventský Velehrad',
                    'assets/icons/avlogo.svg',
                  ),
                  const Spacer(),
                  Visibility(
                    visible: !DataService.isLoggedIn(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircularButton(
                              size: const Size(70, 70),
                              onPressed: _loginPressed,
                              backgroundColor: primaryBlue2,
                              child: const Icon(Icons.login),
                            ), // <-- Icon
                            const Text("Přihlášení"), // <-- Text
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: DataService.isLoggedIn(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircularButton(
                              size: const Size(70, 70),
                              onPressed: _profileButtonPressed,
                              backgroundColor: primaryBlue2,
                              child: const Icon(Icons.account_circle_rounded),
                            ), // <-- Icon
                            Text(userName), // <-- Text
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Expanded(child: ProgramTabView(events: _events, onEventPressed: eventPressed)),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MainPageButton(
                      onPressed: _programPressed,
                      backgroundColor: primaryBlue1,
                      child: const Icon(Icons.calendar_month),
                    ), // <-- Icon
                    const Text("Program"), // <-- Text
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    badges.Badge(
                      showBadge: showMessageCount(),
                      badgeContent: SizedBox(
                        width: 20, height: 20,
                        child: Center(
                          child: Text(messageCountString(), style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16
                          )
                      ),
                    )
                ),
                      child: MainPageButton(
                        onPressed: _newsPressed,
                        backgroundColor: primaryYellow,
                        child: const Icon(Icons.newspaper),
                      ),
                    ), // <-- Icon
                    const Text("Ohlášky"), // <-- Text
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MainPageButton(
                      onPressed: _mapPressed,
                      backgroundColor: primaryRed,
                      child: const Icon(Icons.map),
                    ), // <-- Icon
                    const Text("Mapa"), // <-- Text
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MainPageButton(
                      onPressed: _infoPressed,
                      backgroundColor: primaryBlue2,
                      child: const Icon(Icons.info),
                    ), // <-- Icon
                    const Text("Info"), // <-- Text
                  ],
                ),
              ],
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ));
  }

  void _programPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProgramPage())).then((value) => loadData());
  }

  void _newsPressed() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => NewsPage())).then((value) => loadData());
  }

  void _infoPressed() {
    Navigator.pushNamed(
        context, InfoPage.ROUTE).then((value) => loadData());
  }

  void _mapPressed() {
    Navigator.pushNamed(
        context, MapPage.ROUTE).then((value) => loadData());
  }

  void _loginPressed() {
    Navigator.pushNamed(
        context, LoginPage.ROUTE).then((value) => loadData());
  }

  void _profileButtonPressed() {
    Navigator.pushNamed(
        context, UserPage.ROUTE).then((value) => loadData());
  }

  final List<EventModel> _events = [];

  Future<void> loadEventParticipants() async {
    for (var e in _events)
    {
      if(e.canSignIn())
      {
        var participants = await DataService.getParticipantsPerEventCount(e.id);
        var isSignedCurrent = await DataService.isCurrentUserSignedToEvent(e.id);
        setState(() {
          e.currentParticipants = participants;
          e.isSignedIn = isSignedCurrent;
        });
      }
    }
  }

  eventPressed(int id) {
    Navigator.pushNamed(
        context, EventPage.ROUTE, arguments: id).then((value) => loadData());
  }

  int messageCount = 0;
  bool showMessageCount() => messageCount>0;
  String messageCountString() => messageCount<100?messageCount.toString():"99";
  void loadData() {
    DataService.updateEvents(_events)
        .whenComplete(() async {
          if(!DataService.isLoggedIn())
          {
            return;
          }
          var count = await DataService.countNewMessages();

          setState(() {
            messageCount = count;
          });
        })
        .whenComplete(() async => await loadEventParticipants());
  }

  Future<void> loadUserData() async {
      var currentUser = await DataService.getCurrentUserData();
      setState(()=>
      userName = currentUser.name
      );
    }
  }
