import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'huntingBlocks.dart';
import 'main.dart';
import 'models.dart';

class CreatePlanPresetPage extends StatefulWidget {
  CreatePlanPresetPageState createState() => CreatePlanPresetPageState();
}

class CreatePlanPresetPageState extends State<CreatePlanPresetPage> {
  bool loading = false;
  String name;
  String error;
  List<LatLng> points = new List();

  String styleData;

  MapboxMapController controller;
  Circle selectedPoint;
  Fill polygon;
  bool circleTapped = false;

  createPlanPreset() {
    if (points.length < 3) {
      setState(() {
        error = "Please select at least 3 points.";
      });
    }

    if (name == null || name == "") {
      setState(() {
        error = "Please enter a name";
      });
    }

    setState(() {
      loading = true;
    });

    String polygon = "POLYGON((";

    points.forEach((point) => polygon +=
        point.longitude.toString() + " " + point.latitude.toString() + ", ");

    polygon += points[0].longitude.toString() +
        " " +
        points[0].latitude.toString() +
        "))";

    MyApp.api.createPlanPreset(new PlanPresetCreateUpdate(name, polygon)).then(
        (value) {
      Navigator.pop(context, value);
      setState(() {
        loading = false;
      });
    }, onError: (errorMsg) {
      setState(() {
        error = errorMsg;
        loading = false;
      });
    });
  }

  selectFromDoc() {
    Navigator.push(context,
            platformPageRoute(builder: (context) => HuntingBlocksPage()))
        .then((block) {
      if (block != null) {
        HuntingBlock blk = block;

        points.clear();
        controller.circles.forEach((circle) => controller.removeCircle(circle));

        List<LatLngObj> tempList = new List();
        tempList.addAll(blk.points);
        tempList.removeLast();

        tempList
            .forEach((point) => points.add(new LatLng(point.lat, point.lng)));

        points.forEach((point) => controller.addCircle(new CircleOptions(
            circleRadius: 20,
            circleColor: "#0000FF",
            circleStrokeColor: "#0000FF",
            circleOpacity: 0.5,
            geometry: point,
            draggable: false)));

        updatePolygon();
      }
    });
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;

    this.controller.onCircleTapped?.add(onCircleTapped);
  }

  void onMapTapped(Point<double> point, LatLng coords) {
    if (!circleTapped) {
      points.add(coords);
      controller
          .addCircle(new CircleOptions(
              circleRadius: 20,
              circleColor: "#0000FF",
              circleStrokeColor: "#0000FF",
              circleOpacity: 0.5,
              geometry: coords,
              draggable: false))
          .then((_) => updatePolygon());
    }
    circleTapped = false;
  }

  @override
  void dispose() {
    controller?.onCircleTapped?.remove(onCircleTapped);
    super.dispose();
  }

  void onCircleTapped(Circle circle) {
    circleTapped = true;
    setState(() {
      selectedPoint = circle;
    });

    points.remove(circle.options.geometry);
    controller.removeCircle(circle);
    updatePolygon();
  }

  void updatePolygon() {
    if (polygon == null && points.length >= 3) {
      controller
          .addFill(new FillOptions(
              fillOpacity: 0.5,
              fillColor: "#FF0000",
              fillOutlineColor: "#FF0000",
              geometry: points))
          .then((value) => polygon = value);
    } else if (points.length >= 3) {
      controller.updateFill(polygon, new FillOptions(geometry: points));
    } else if (polygon != null) {
      controller.removeFill(polygon);
      polygon = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (styleData == null)
      rootBundle.loadString('assets/map.json').then((value) => setState(() {
            styleData = value;
          }));

    return PlatformScaffold(
      appBar: PlatformAppBar(
        ios: (context) => CupertinoNavigationBarData(
            heroTag: "createPlanPreset", transitionBetweenRoutes: false),
        title: Text("Create New Plan Preset"),
        trailingActions: <Widget>[
          new PlatformIconButton(
            androidIcon: Icon(Icons.check),
            iosIcon: Icon(CupertinoIcons.check_mark_circled_solid),
            onPressed: createPlanPreset,
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        progressIndicator: PlatformCircularProgressIndicator(),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.text_fields),
                      labelText: "Name",
                      errorText: error,
                      border: OutlineInputBorder()),
                  onChanged: (content) => name = content),
            ),
            Center(
                child: PlatformButton(
              child: Text("Select from DOC Hunting Block"),
              onPressed: selectFromDoc,
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Select Area - Tap to add a point. Tap a point to delete it."),
            ),
            if (styleData == null)
              new Expanded(
                  child: Center(child: PlatformCircularProgressIndicator())),
            if (styleData != null)
              new Expanded(
                  child: new MapboxMap(
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.Tracking,
                initialCameraPosition: CameraPosition(
                    target: LatLng(-45.790099, 167.460020), zoom: 11.0),
                styleString: styleData,
                onMapClick: onMapTapped,
              ))
          ],
        ),
      ),
    );
  }
}
