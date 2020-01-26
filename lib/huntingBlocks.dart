import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'models.dart';

import 'package:flutter/services.dart' show rootBundle;

class HuntingBlocksPage extends StatefulWidget {
  @override
  HuntingBlocksPageState createState() => HuntingBlocksPageState();
}

class HuntingBlocksPageState extends State<HuntingBlocksPage> {
  String styleData;
  bool loadingStyle = false;

  List<HuntingBlock> huntingBlocks;
  bool loadingBlocks = false;

  HuntingBlock selectedBlock;
  String blockName = "No block selected";
  String blockGroup = "";

  String error;

  MapboxMapController controller;

  Map<String, HuntingBlock> blockFillMap = new Map();

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;

    if (huntingBlocks != null) {
      huntingBlocks.forEach((block) {
          List<LatLng> points = new List();
          block.points.forEach((f) {
            points.add(new LatLng(f.lat, f.lng));
          });

          points.add(new LatLng(block.points[0].lat, block.points[0].lng));

          controller
              .addFill(new FillOptions(
              fillOpacity: 0.5,
              fillColor: "#0000FF",
              fillOutlineColor: "#0000FF",
              geometry: points))
              .then((fill) {
            print("TESTTTT");
            blockFillMap.putIfAbsent(fill.id, () => block);
            print("TESTTTT2");
          }, onError: (error) => print(error + " ERROR"));
      });


    }

    this.controller.onFillTapped?.add(_onFillTapped);
  }

  Fill _selectedFill;

  void _onFillTapped(Fill fill) {
    if (fill != _selectedFill)
      _updateSelectedFill(
        const FillOptions(fillColor: "#0000FF"),
      );

    setState(() {
      _selectedFill = fill;
    });

    if (_selectedFill != null) {
      selectedBlock = blockFillMap[fill.id];

      setState(() {
        blockName = selectedBlock.name;
        blockGroup = selectedBlock.parentName;
      });

      _updateSelectedFill(
        const FillOptions(fillColor: "#FFFFFF"),
      );
    }
  }

  void _updateSelectedFill(FillOptions changes) {
    controller.updateFill(_selectedFill, changes);
  }

  @override
  Widget build(BuildContext context) {
    if (styleData == null && !loadingStyle) {
      loadingStyle = true;
      rootBundle.loadString('assets/map.json').then((value) => setState(() {
            styleData = value;
          }));
    }

    if (huntingBlocks == null && !loadingBlocks) {
      loadingBlocks = true;
      MyApp.api.getHuntingBlocks().then(
          (value) => setState(() {
                huntingBlocks = value;
              }),
          onError: (error) => setState(() {
                this.error = error;
              }));
    }

    save() {
      Navigator.pop(context, selectedBlock);
    }

    return PlatformScaffold(
      appBar: PlatformAppBar(
        ios: (context) => CupertinoNavigationBarData(
            heroTag: "selectBlock", transitionBetweenRoutes: false),
        title: Text("Select Hunting Block"),
        trailingActions: <Widget>[
          new PlatformIconButton(
            androidIcon: Icon(Icons.check),
            iosIcon: Icon(CupertinoIcons.check_mark_circled_solid),
            onPressed: save,
          )
        ],
      ),
      body: generateWidgets(),
    );
  }

  Widget generateWidgets() {
    if (error != null)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.warning, color: Colors.grey, size: 100),
            Text(
              error,
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    if (styleData == null || huntingBlocks == null)
      return Center(child: PlatformCircularProgressIndicator());
    else {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                blockName,
                style: TextStyle(color: Colors.white, fontSize: 25),
                textAlign: TextAlign.left,
              )),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                blockGroup,
                style: TextStyle(color: Colors.grey, fontSize: 25),
                textAlign: TextAlign.left,
              )),
          new Expanded(
              child: new MapboxMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.Tracking,
            initialCameraPosition: CameraPosition(
                target: LatLng(-45.790099, 167.460020), zoom: 11.0),
            styleString: styleData,
          ))
        ],
      );
    }
  }
}
