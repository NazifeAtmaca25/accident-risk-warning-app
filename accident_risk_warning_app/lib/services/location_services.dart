import 'package:geolocator/geolocator.dart';

class LocationServices{
  Future<bool> checkPermissions() async{
    bool serviceEnable= await Geolocator.isLocationServiceEnabled();
    if(!serviceEnable){
      return false;
    }

    LocationPermission permission= await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission == await Geolocator.requestPermission();
      if(permission== LocationPermission.denied){
        return false;
      }
    }
    if(permission== LocationPermission.deniedForever){
      return false;
    }
    return true;
  }
  Future<Position?> getCurrentLocation() async{
    bool hasPermmission = await checkPermissions();
    if(!hasPermmission) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high
      )
    );
  }
  Stream<Position> get locationStream => Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    )
  );
}