import 'package:cached_network_image/cached_network_image.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'main.dart';
import 'models.dart';

class CreateTripPage extends StatefulWidget {
  PlanPreset planPreset;

  CreateTripPage(PlanPreset planPreset) {
    this.planPreset = planPreset;
  }

  CreateTripPageState createState() => CreateTripPageState(planPreset);
}

class CreateTripPageState extends State<CreateTripPage> {
  PlanPreset planPreset;

  CreateTripPageState(PlanPreset planPreset) {
    this.planPreset = planPreset;
  }

  String error;

  saveTrip() {
    if (end.millisecondsSinceEpoch <= start.millisecondsSinceEpoch) {
      setState(() {
        error = "Start time must be before the end time";
      });
      return;
    }
    setState(() {
      loading = true;
    });

    MyApp.api
        .createTrip(
            new TripCreate(start, end, planPreset.id, incognitoMode, ghostMode))
        .then((value) {
      Navigator.pop(context);
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

  final format = DateFormat("KK:mmaa, EEEE dd MMMM yyyy");

  DateTime start;
  DateTime end;
  bool incognitoMode = false;
  bool ghostMode = false;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          ios: (context) => CupertinoNavigationBarData(
              heroTag: "createTrip", transitionBetweenRoutes: false),
          title: Text("Plan New Trip"),
          trailingActions: <Widget>[
            new PlatformIconButton(
              androidIcon: Icon(Icons.check),
              iosIcon: Icon(CupertinoIcons.check_mark_circled_solid),
              onPressed: saveTrip,
            )
          ],
        ),
        body: ModalProgressHUD(
            inAsyncCall: loading,
            progressIndicator: PlatformCircularProgressIndicator(),
            child: SingleChildScrollView(
              child: new Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          placeholder: (context, url) {
                            return PlatformCircularProgressIndicator();
                          },
                          imageUrl:
                              "https://api.mapbox.com/styles/v1/shea9872/ck1espu983mxl1cpdrwdif6mp/static/geojson(" +
                                  Uri.encodeComponent(
                                      generateGeoJson(planPreset.points)) +
                                  ")/auto/1000x700?access_token=pk.eyJ1Ijoic2hlYTk4NzIiLCJhIjoiY2pzNnNsdHJrMDBveTN6bXZsZGkybzN1NiJ9.5lcwkKBVWS9p-NmVGfBbQQ&attribution=false&logo=false",
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(
                          planPreset.name,
                          style: TextStyle(color: Colors.white, fontSize: 25),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: DateTimeField(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: false,
                              prefixIcon: Icon(Icons.date_range),
                              labelText: "Start Time",
                              focusColor: Color(0xFF16A816),
                              border: OutlineInputBorder(),
                              errorText: error),
                          format: format,
                          style: TextStyle(color: Colors.white),
                          initialValue: start,
                          onShowPicker: (context, currentValue) async {
                            if (isMaterial) {
                              final date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: end ?? DateTime(2100));
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()),
                                );
                                start = DateTimeField.combine(date, time);
                                return start;
                              } else {
                                return currentValue;
                              }
                            } else {
                              await showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoDatePicker(
                                      initialDateTime: start,
                                      minimumDate: DateTime.now(),
                                      onDateTimeChanged: (DateTime date) {
                                        start = date;
                                      },
                                    );
                                  });
                              setState(() {});
                              return start;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: DateTimeField(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: false,
                              prefixIcon: Icon(Icons.date_range),
                              labelText: "End Time",
                              focusColor: Color(0xFF16A816),
                              border: OutlineInputBorder()),
                          format: format,
                          style: TextStyle(color: Colors.white),
                          initialValue: end,
                          onShowPicker: (context, currentValue) async {
                            if (isMaterial) {
                              final date = await showDatePicker(
                                  context: context,
                                  firstDate: start ?? DateTime.now(),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()),
                                );
                                end = DateTimeField.combine(date, time);
                                return end;
                              } else {
                                return currentValue;
                              }
                            } else {
                              await showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoDatePicker(
                                      initialDateTime: end,
                                      minimumDate: DateTime.now(),
                                      onDateTimeChanged: (DateTime date) {
                                        end = date;
                                      },
                                    );
                                  });
                              setState(() {});
                              return end;
                            }
                          },
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Row(
                            children: <Widget>[
                              Text("Incognito Mode (Hides your name) "),
                              PlatformSwitch(
                                  value: incognitoMode,
                                  onChanged: (value) => ghostMode = value)
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Row(
                            children: <Widget>[
                              Text("Ghost Mode (Hides your current location) "),
                              PlatformSwitch(
                                  value: ghostMode,
                                  onChanged: (value) => ghostMode = value)
                            ],
                          )),
                    ],
                  )),
            )));
  }

  generateGeoJson(List<LatLngObj> points) {
    String json =
        '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"fill":"#0000FF","fill-opacity":0.5,"stroke":"#0000FF"},"geometry":{"type":"Polygon","coordinates":[[';

    points.forEach((points) => json += "[${points.lng}, ${points.lat}],");

    json += "[${points[0].lng}, ${points[0].lat}]]]}}]}";

    return json;
  }
}
