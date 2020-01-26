import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';

import 'api.dart';
import 'main.dart';
import 'models.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onFillTapped.add(_onFillTapped);

    currentTrips.then((trips) {
      trips.forEach((trip) {
        List<LatLng> points = new List();
        trip.preset.points.forEach((f) {
          points.add(new LatLng(f.lat, f.lng));
        });

        controller.addFill(new FillOptions(
            fillOpacity: 0.5,
            fillColor: "#FF0000",
            fillOutlineColor: "#FF0000",
            geometry: points));
      });
    });
  }

  @override
  void dispose() {
    controller?.onFillTapped?.remove(_onFillTapped);
    super.dispose();
  }

  Fill _selectedFill;

  void _onFillTapped(Fill fill) {
    print(controller?.cameraPosition.zoom.toString() + " TEST");
    if (_selectedFill != null) {
      _updateSelectedFill(
        const FillOptions(fillColor: "#FFFFFF"),
      );
    }
    setState(() {
      _selectedFill = fill;
    });
  }

  void _updateSelectedFill(FillOptions changes) {
    controller.updateFill(_selectedFill, changes);
  }

  String styleData;
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

  Future<String> map() async {
    if (styleData != null)
      return styleData;
    else
      return await rootBundle.loadString('assets/map.json');
  }

  Future<List<Trip>> currentTrips = MyApp.api.getCurrentTrips();
  Future<ConnectivityResult> connectivity = Connectivity().checkConnectivity();
  Future<bool> permission = new Location().requestPermission();

  MapboxMapController controller;

  @override
  Widget build(BuildContext context) {
    if (styleData == null || !_tilesLoaded) {
      permission.then((_) {
        map().then((style) {
          setState(() {
            styleData = style;
          });
        });
      });

      return Center(child: PlatformCircularProgressIndicator());
    } else {
      return new MapboxMap(
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        myLocationTrackingMode: MyLocationTrackingMode.Tracking,
        initialCameraPosition:
            CameraPosition(target: LatLng(-45.790099, 167.460020), zoom: 11.0),
        styleString: styleData,
      );
    }
  }
}
