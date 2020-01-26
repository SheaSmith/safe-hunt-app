class Trip {
  String id;
  DateTime start;
  DateTime end;
  DateTime created;
  PlanPreset preset;
  User user;

  Trip({this.id, this.start, this.end, this.created, this.preset, this.user});

  Trip.fromJson(Map<String, dynamic> data)
      : id = data['Id'],
        start = DateTime.parse(data['Start']),
        end = DateTime.parse(data['End']),
        created = DateTime.parse(data['Created']),
        preset = PlanPreset.fromJson(data['Preset']),
        user = User.fromJson(data['User']);
}

class TripCreate {
  DateTime start;
  DateTime end;
  String presetId;
  bool incognitoMode;
  bool ghostMode;

  TripCreate(
      this.start, this.end, this.presetId, this.incognitoMode, this.ghostMode);

  Map<String, dynamic> toJson() => {
        'Start': start.toIso8601String(),
        'End': end.toIso8601String(),
        'PresetId': presetId,
        'IncognitoMode': incognitoMode,
        'GhostMode': ghostMode
      };
}

class TripUpdate {
  DateTime start;
  DateTime end;
  bool incognitoMode;
  bool ghostMode;

  TripUpdate(this.start, this.end, this.incognitoMode, this.ghostMode);

  Map<String, dynamic> toJson() => {
        'Start': start.toIso8601String(),
        'End': end.toIso8601String(),
        'IncognitoMode': incognitoMode,
        'GhostMode': ghostMode
      };
}

class PlanPreset {
  String id;
  String name;
  List<LatLngObj> points = [];
  DateTime created;
  DateTime lastUpdated;
  DateTime lastUsed;

  PlanPreset(
      {this.id,
      this.name,
      this.points,
      this.created,
      this.lastUpdated,
      this.lastUsed});

  PlanPreset.fromJson(Map<String, dynamic> data) {
    id = data['Id'];
    name = data['Name'];
    points =
        (data['Points'] as List).map((e) => LatLngObj.fromJson(e)).toList();
    try {
      created = DateTime.parse(data['Created']);
      lastUpdated = DateTime.parse(data['LastUpdated']);
      if (data['LastUsed'] != null) lastUsed = DateTime.parse(data['LastUsed']);
    }
    on Exception {}
  }
}

class PlanPresetCreateUpdate {
  String name;
  String points;

  PlanPresetCreateUpdate(this.name, this.points);

  Map<String, dynamic> toJson() => {'Name': name, 'Points': points};
}

class LatLngObj {
  double lat;
  double lng;

  LatLngObj({this.lat, this.lng});

  LatLngObj.fromJson(Map<String, dynamic> data)
      : this.lat = data['Lat'],
        this.lng = data['Lng'];
}

class User {
  String id;
  String name;
  LatLngObj lastLocation;
  DateTime lastSeen;

  User({this.id, this.name, this.lastLocation, this.lastSeen});

  User.fromJson(Map<String, dynamic> data) {
    id = data['Id'];
    name = data['Name'];
    lastLocation = LatLngObj.fromJson(data['LastLocation']);
    if (data['LastSeen'] != null) lastSeen = DateTime.parse(data['LastSeen']);
  }
}

class HuntingBlock {
  String id;
  String parentName;
  String name;
  List<LatLngObj> points = [];
  String provider;

  HuntingBlock(
      {this.id, this.parentName, this.name, this.points, this.provider});

  HuntingBlock.fromJson(Map<String, dynamic> data)
      : id = data['Id'],
        parentName = data['ParentName'],
        name = data['Name'],
        points = (data['Points'] as List).map((p) => LatLngObj.fromJson(p)).toList(),
        provider = data['Provider'];
}

class Register {
  String email;
  String password;
  String confirmPassword;
  String name;

  Register({this.email, this.password, this.confirmPassword, this.name});

  Map<String, dynamic> toJson() => {
        'Email': email,
        'Password': password,
        'ConfirmPassword': confirmPassword,
        'Name': name
      };
}
