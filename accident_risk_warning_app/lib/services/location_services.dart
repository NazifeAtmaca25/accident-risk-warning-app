import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationServices{
  Future<bool> checkPermissions(BuildContext context) async{
    bool serviceEnable= await Geolocator.isLocationServiceEnabled();
    if(!serviceEnable){
      if(context.mounted){
        _showLocationServicesDialog(context);
      }
      return false;
    }

    LocationPermission permission= await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission== LocationPermission.denied){
        if(context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:  Text('Konum izinleri reddedildi'))
          );
        }
        return false;
      }
    }
    if(permission== LocationPermission.deniedForever){
      if(context.mounted){
        _showPermissionDeniedDialog(context);
      }
      return false;
    }
    return true;
  }
  Future<Position?> getCurrentLocation(BuildContext context) async{
    bool hasPermmission = await checkPermissions(context);
    if(!hasPermmission) return null;

    try{
      return await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high
          )
      ); 
    } catch(e){
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konum alınırken bir hata oluştu')));
      }
      return null;
    }
    
  }
  
  void _showLocationServicesDialog(BuildContext context){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text("Konum Servisleri Kapalı"),
      content: Text("Uygulamanın düzgün çalışabilmesi için konum servisini açmanız gerek!"),
      actions: [
        TextButton(onPressed: ()=>Navigator.of(context).pop(),
            child: Text("İptal")),
        TextButton(onPressed: () async{
          Navigator.of(context).pop();
          await Geolocator.openLocationSettings();
        }, child: Text("Ayarlar"))
      ],
    ));
  }
  void _showPermissionDeniedDialog(BuildContext context){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text("Konum izni gerekli"),
      content: Text("Uygulamanın düzgün çalışması için konum izinlerine ihtiyacı var. Lütfen ayarlardan izin verin."),
      actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text("İptal")),
        TextButton(onPressed: () async{
          Navigator.of(context).pop();
          await Geolocator.openLocationSettings();
        }, child: Text("Ayarlar"))
      ],
    ));
  }
  
  Stream<Position> get locationStream => Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    )
  );
}