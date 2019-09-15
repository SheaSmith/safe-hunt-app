import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var _tilesLoaded = false;

  @override
  void initState() {
    super.initState();
    _copyTilesIntoPlace();
  }

  _copyTilesIntoPlace() async {
    try {
      await installOfflineMapTiles(join("assets", "map.db"));
    } catch (err) {
      print(err);
    }
    setState(() {
      this._tilesLoaded = true;
    });
  }

  Future<String> map = rootBundle.loadString('assets/map.json');
  Future<ConnectivityResult> connectivity = Connectivity().checkConnectivity();

  Widget build(BuildContext context) {
    return new FutureBuilder<String>(
      future: Future.wait([map, connectivity]).then((response) {
        if (response[1] == ConnectivityResult.none)
          return "NoSignal";
        else
          return response[0];
      }), // async work
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading....');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else {
              if (_tilesLoaded) {
                String styleStr;
                if (snapshot.data != "NoSignal")
                  styleStr = snapshot.data;
                else
                  styleStr =
                  "mapbox://styles/andrewdc/cj3xo7uut1ris2rnqo9iygik4";
                return new MapboxMap(
                  myLocationEnabled: true,
                  myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(-45.790099, 167.460020), zoom: 11.0),
                  styleString: styleStr,

                );
              }
              else
                return new CircularProgressIndicator();
            }
        }
      },
    );
  }
}
