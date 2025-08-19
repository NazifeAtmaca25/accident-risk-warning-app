import 'dart:convert';

import 'package:accident_risk_warning_app/model/danger_zone.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class DangerZoneServices{
  List<DangerZone> zones=[];
  Future<void> loadZones() async{
    final jsonString= await rootBundle.loadString('assets/risk_zones.json');
    final List<dynamic> jsonData= json.decode(jsonString);

    zones=jsonData.map((item){
      return DangerZone(name: item["name"], lat: item["lat"], lng: item["lng"], radius: item["radius"].toDouble());
    }).toList();
  }

  List<DangerZone> checkInDangerZone(Position userPosition){
    return zones.where((zone){
      double distance=Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, zone.lat, zone.lng);
      return distance <= zone.radius;
    }).toList();
  }

  List<DangerZone> checkNearbyZones(Position userPositon, {double warningDistance= 150}){
    return zones.where((zone){
      double distance=Geolocator.distanceBetween(userPositon.latitude, userPositon.longitude, zone.lat, zone.lng);
      return distance>zone.radius && distance <=(zone.radius+warningDistance);
    }).toList();
  }
}