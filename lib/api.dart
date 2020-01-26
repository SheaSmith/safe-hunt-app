import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cache.dart';
import 'models.dart';

class Api {
  static String token;
  static String baseUrl = "https://safehunt.azurewebsites.net";
  Cache cache;

  static Map<String, String> standardHeaders;

  Api() {
    cache = Cache();
    cache.initAsync().then((_) {
      if (cache.hasValue("token")) {
        token = cache.getValue("token");

        standardHeaders = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        };
      }
    });
  }

  Api.withCache(Cache cache) {
    this.cache = cache;
    if (cache.hasValue("token")) {
      token = cache.getValue("token");

      standardHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + token
      };
    }
  }

  /// Login to SafeHunt, requires a username and password
  /// @returns name of the user
  Future<String> login(String username, String password) async {
    try {
      var response = await http.post(baseUrl + "/api/account/token", body: {
        'grant_type': 'password',
        'username': username,
        'password': password
      }, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      });

      if (response.statusCode == 400)
        return Future.error("Invalid username or password");
      else if (response.statusCode == 200) {
        var jsonRes = json.decode(response.body);
        token = jsonRes['access_token'];
        String name = jsonRes['name'];
        String email = jsonRes['userName'];
        String id = jsonRes['id'];

        if (cache == null) {
          cache = Cache();
          await cache.initAsync();
        }

        cache.putValue('token', token);
        cache.putValue('name', name);
        cache.putValue('email', email);
        cache.putValue('userId', id);

        standardHeaders = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        };

        return name;
      } else
        return Future.error("Unknown server error");
    } catch (e) {
      return Future.error("No internet connection. Please try again later.");
    }
  }

  Future<List<Trip>> getCurrentTrips() async {
    try {
      var response =
          await http.get(baseUrl + "/api/trips/now", headers: standardHeaders);

      if (response.statusCode == 200) {
        DateTime expiry = DateTime.parse(response.headers['expiry']);

        cache.putValue(
            "currentTrips",
            response.body,
            expiry: expiry.millisecondsSinceEpoch -
                DateTime.now().millisecondsSinceEpoch);

        var parsed = json.decode(response.body).cast<Map<String, dynamic>>();

        return parsed.map<Trip>((json) => Trip.fromJson(json)).toList();
      } else if (response.statusCode == 204) {
        return new List();
      } else {
        return Future.error("Unknown server error");
      }
    } on Exception {
      String cacheItem = cache.getValue("currentTrips");

      if (cacheItem != null) {
        var parsed = json.decode(cacheItem).cast<Map<String, dynamic>>();

        return parsed.map<Trip>((json) => Trip.fromJson(json)).toList();
      }

      return Future.error("No internet connection. Please try again later.");
    }
  }

  Future<List<Trip>> getMyTrips() async {
    try {
      var response =
          await http.get(baseUrl + "/api/trips/mine", headers: standardHeaders);

      if (response.statusCode == 200) {
        var parsed = json.decode(response.body).cast<Map<String, dynamic>>();

        return parsed.map<Trip>((json) => Trip.fromJson(json)).toList();
      } else if (response.statusCode == 204) {
        return new Future.error(
            "You have no trips! You can add one by clicking the plus button above");
      } else {
        return Future.error("Unknown server error");
      }
    } on Exception {
      return Future.error("No internet connection. Please try again later.");
    }
  }

  Future<Trip> createTrip(TripCreate tripCreate) async {
    try {
      var response = await http.post(baseUrl + "/api/trips",
          headers: standardHeaders, body: json.encode(tripCreate));

      if (response.statusCode == 201)
        return Trip.fromJson(json.decode(response.body));
      else if (response.statusCode == 404)
        return Future.error("Plan preset not found");
      else if (response.statusCode == 409)
        return Future.error("There is already a trip at this time!");
      else if (response.statusCode == 400)
        return Future.error("The start date must be before the end date");
      else
        return Future.error("Unknown server error");
    } on Exception {
      return Future.error("No internet connection. Please try again later.");
    }
  }

  Future<Trip> updateTrip(TripUpdate tripUpdate, String id) async {
    try {
      var response = await http.put(baseUrl + "/api/trips/" + id,
          headers: standardHeaders, body: json.encode(tripUpdate.toJson()));

      if (response.statusCode == 200)
        return Trip.fromJson(json.decode(response.body));
      else if (response.statusCode == 404)
        return Future.error("Trip not found");
      else if (response.statusCode == 409)
        return Future.error("There is already a trip at this time!");
      else if (response.statusCode == 400)
        return Future.error("The start date must be before the end date");
      else
        return Future.error("Unknown server error");
    } on Exception {
      return Future.error("No internet connection. Please try again later.");
    }
  }

  Future<void> deleteTrip(String id) async {
    try {
      var response = await http.delete(baseUrl + "/api/trips/" + id,
          headers: standardHeaders);

      if (response.statusCode == 200)
        return null;
      else if (response.statusCode == 404)
        return Future.error("Trip not found");
      else
        return Future.error("Unknown server error");
    } on Exception {
      return Future.error("No internet connection. Please try again later.");
    }
  }

  Future<List<HuntingBlock>> getHuntingBlocks() async {
    try {
      if (cache.hasValue("huntingBlocks")) {
        var parsed = json
            .decode(cache.getValue("huntingBlocks"))
            .cast<Map<String, dynamic>>();

        return parsed
            .map<HuntingBlock>((json) => HuntingBlock.fromJson(json))
            .toList();
      }

      var response =
          await http.get(baseUrl + "/api/blocks", headers: standardHeaders);

      if (response.statusCode == 200) {
        cache.putValue(
            "huntingBlocks",
            response.body,
            expiry: new Duration(days: 14).inMilliseconds);

        var parsed = json.decode(response.body).cast<Map<String, dynamic>>();

        return parsed
            .map<HuntingBlock>((json) => HuntingBlock.fromJson(json))
            .toList();
      } else if (response.statusCode == 204)
        return Future.error("There are no hunting blocks available to select");
      else
        return Future.error("Unknown server error");
    } on Exception {
      return Future.error("No internet connection. Please try again later");
    }
  }

  Future<List<PlanPreset>> getPlanPresets() async {
    try {
      var response = await http.get(baseUrl + "/api/planpresets",
          headers: standardHeaders);

      if (response.statusCode == 200) {
        var parsed = json.decode(response.body).cast<Map<String, dynamic>>();

        return parsed
            .map<PlanPreset>((json) => PlanPreset.fromJson(json))
            .toList();
      } else if (response.statusCode == 204)
        return new Future.error(
            "You have no plan presets! Create one by pressing the '+' icon above.");
      else
        return Future.error("Unknown server error");
    } on Exception {
      return Future.error("No internet connection. Please try again later");
    }
  }

  Future<PlanPreset> createPlanPreset(
      PlanPresetCreateUpdate planPresetCreate) async {
    try {
      var response = await http.post(baseUrl + "/api/planpresets",
          headers: standardHeaders,
          body: json.encode(planPresetCreate.toJson()));

      if (response.statusCode == 201)
        return PlanPreset.fromJson(json.decode(response.body));
      else
        return Future.error("Unknown server error");
    } catch (e) {
      return Future.error("No internet connection. Please try again later");
    }
  }

  Future<PlanPreset> updatePlanPreset(
      PlanPresetCreateUpdate planPresetCreate, String id) async {
    try {
      var response = await http.put(baseUrl + "/api/planpresets/" + id,
          headers: standardHeaders,
          body: json.encode(planPresetCreate.toJson()));

      if (response.statusCode == 200)
        return PlanPreset.fromJson(json.decode(response.body));
      else
        return Future.error("Unknown server error");
    } on Exception {
      return Future.error("No internet connection. Please try again later");
    }
  }

  Future<void> deletePlanPreset(String id) async {
    try {
      var response = await http.delete(baseUrl + "/api/planpresets/" + id,
          headers: standardHeaders);

      if (response.statusCode == 200)
        return PlanPreset.fromJson(json.decode(response.body));
      else
        return Future.error("Unknown server error");
    } on Exception {
      return Future.error("No internet connection. Please try again later");
    }
  }
}
