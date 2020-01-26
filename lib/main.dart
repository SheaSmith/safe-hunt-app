import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:safe_hunt/presets.dart';
import 'package:safe_hunt/trips.dart';

import 'api.dart';
import 'cache.dart';
import 'createPlanPreset.dart';
import 'login.dart';
import 'map.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future<bool> isLoggedIn() async {
    Cache cache = Cache();
    await cache.initAsync();
    api = Api.withCache(cache);
    return cache.hasValue("token");
  }

  static Api api;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> swatch = {
      50: Color.fromRGBO(22, 168, 22, 1),
      100: Color.fromRGBO(22, 168, 22, 1),
      200: Color.fromRGBO(22, 168, 22, 1),
      300: Color.fromRGBO(22, 168, 22, 1),
      400: Color.fromRGBO(22, 168, 22, 1),
      500: Color.fromRGBO(22, 168, 22, 1),
      600: Color.fromRGBO(22, 168, 22, 1),
      700: Color.fromRGBO(22, 168, 22, 1),
      800: Color.fromRGBO(22, 168, 22, 1),
      900: Color.fromRGBO(22, 168, 22, 1),
    };

    final themeData = new ThemeData(
        primarySwatch: MaterialColor(0xFF16A816, swatch),
        brightness: Brightness.dark,
        accentColor: Color(0xFF16A816));

    final cupertinoTheme = new CupertinoThemeData(
        primaryColor: Color(0xFF16A816), brightness: Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return PlatformProvider(
      builder: (BuildContext context) => PlatformApp(
        title: "Safe Hunt",
        color: Color(0xFF16A816),
        android: (_) => new MaterialAppData(theme: themeData),
        ios: (_) => new CupertinoAppData(theme: cupertinoTheme),
        home: FutureBuilder(
            future: isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data)
                  return MainPage();
                else
                  return LoginPage();
              } else
                return Center(child: PlatformCircularProgressIndicator());
            }),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _children = [MapPage(), PresetsPage(), TripsPage()];

  _switchPlatform(BuildContext context) {
    if (isMaterial) {
      PlatformProvider.of(context).changeToCupertinoPlatform();
    } else {
      PlatformProvider.of(context).changeToMaterialPlatform();
    }
  }

  createNewPlanPreset() {
    Navigator.push(context, platformPageRoute(builder: (context) => CreatePlanPresetPage()));
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget build(BuildContext context) {
    String title = "Safe Hunt";
    if (_currentIndex == 1) title = "Plan";
    if (_currentIndex == 2) title = "My Trips";

    return PlatformScaffold(
      appBar: PlatformAppBar(
          ios: (context) => CupertinoNavigationBarData(
              heroTag: "main", transitionBetweenRoutes: false),
          title: Text(title),
          trailingActions: <Widget>[
//            PlatformIconButton(
//              iosIcon: Icon(CupertinoIcons.refresh_circled_solid),
//              androidIcon: Icon(Icons.refresh),
//              onPressed: () => _switchPlatform(context),
//            ),
            if (_currentIndex == 1)
              PlatformIconButton(
                iosIcon: Icon(CupertinoIcons.add_circled_solid),
                androidIcon: Icon(Icons.add),
                onPressed: () => createNewPlanPreset(),
              ),
            if (_currentIndex == 0)
              PlatformIconButton(
                iosIcon: Icon(CupertinoIcons.info),
                androidIcon: Icon(Icons.info),
                onPressed: () => createNewPlanPreset(),
              ),
          ]),
      body: _children[_currentIndex],
      bottomNavBar: PlatformNavBar(
        itemChanged: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.map), title: new Text("Map")),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_numbered), title: new Text("Plan")),
          BottomNavigationBarItem(
              icon: Icon(Icons.airplanemode_active), title: Text("My Trips"))
        ],
      ),
    );
  }
}
