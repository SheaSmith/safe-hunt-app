import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

import 'createTrip.dart';
import 'main.dart';
import 'models.dart';

class PresetsPage extends StatefulWidget {
  @override
  PresetsPageState createState() => PresetsPageState();
}

class PresetsPageState extends State<PresetsPage> {
  createTrip(PlanPreset planPreset) {
    Navigator.push(
      context,
      platformPageRoute(
        builder: (context) => CreateTripPage(planPreset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateformat = new DateFormat("dd/MM/yy");

    return FutureBuilder<List<PlanPreset>>(
        future: MyApp.api.getPlanPresets(),
        builder:
            (BuildContext context, AsyncSnapshot<List<PlanPreset>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: new PlatformCircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.warning, color: Colors.grey, size: 100),
                      Text(
                        snapshot.error,
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                );
              }

              return new ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return new Padding(
                      padding: EdgeInsets.all(16),
                      child: GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(children: [
                              Text(
                                snapshot.data[index].name,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                                textAlign: TextAlign.left,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                                child: PlatformIconButton(
                                  iosIcon: Icon(CupertinoIcons.pencil),
                                  androidIcon: Icon(Icons.edit),
                                  onPressed: () => print("yeet"),
                                ),
                              )
                            ]),
                            if (snapshot.data[index].lastUsed != null)
                              Text(
                                "Last Used " +
                                    dateformat
                                        .format(snapshot.data[index].lastUsed),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 25),
                                textAlign: TextAlign.left,
                              ),
                            if (snapshot.data[index].lastUsed == null)
                              Text(
                                "Never Used",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 25),
                                textAlign: TextAlign.left,
                              ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) {
                                      return PlatformCircularProgressIndicator();
                                    },
                                    imageUrl:
                                        "https://api.mapbox.com/styles/v1/shea9872/ck1wxatvm05411cpc1vbp99rp/static/path-1+0000FF-1+0000FF-0.5(" +
                                            Uri.encodeComponent(encodePolyline(
                                                snapshot.data[index].points)) +
                                            ")/auto/1000x700?access_token=pk.eyJ1Ijoic2hlYTk4NzIiLCJhIjoiY2pzNnNsdHJrMDBveTN6bXZsZGkybzN1NiJ9.5lcwkKBVWS9p-NmVGfBbQQ&attribution=false&logo=false",
                                  ),
                                ))
                          ],
                        ),
                        onTap: () => createTrip(snapshot.data[index]),
                      ),
                    );
                  },
                  itemCount: snapshot.data.length);
          }
          // Unreachable
          return null;
        });
  }

  generateGeoJson(List<LatLngObj> points) {
    String json =
        '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"fill":"#0000FF","fill-opacity":0.5,"stroke":"#0000FF"},"geometry":{"type":"Polygon","coordinates":[[';

    points.forEach((points) => json += "[${points.lng}, ${points.lat}],");

    json += "[${points[0].lng}, ${points[0].lat}]]]}}]}";

    return json;
  }

  encodePolyline(List<LatLngObj> points) {
    if (points.length == 0) {
      return '';
    }

    var factor = 100000;
    var output =
        plEncode(points[0].lat, 0, factor) + plEncode(points[0].lng, 0, factor);

    for (var i = 1; i < points.length; i++) {
      var a = points[i], b = points[i - 1];
      output += plEncode(a.lat, b.lat, factor);
      output += plEncode(a.lng, b.lng, factor);
    }

    return output;
  }

  plEncode(double currentDecimal, double previousDecimal, int factor) {
    int current = pyRound(currentDecimal * factor);
    int previous = pyRound(previousDecimal * factor);
    var coordinate = current - previous;
    coordinate <<= 1;
    if (current - previous < 0) {
      coordinate = ~coordinate;
    }
    var output = '';
    while (coordinate >= 0x20) {
      output += String.fromCharCode((0x20 | (coordinate & 0x1f)) + 63);
      coordinate >>= 5;
    }
    output += String.fromCharCode(coordinate + 63);
    return output;
  }

  pyRound(double value) {
    return ((value.abs() + 0.5) * (value >= 0 ? 1 : -1)).floor();
  }
}
