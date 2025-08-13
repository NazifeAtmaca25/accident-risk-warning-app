import 'package:accident_risk_warning_app/services/danger_zone_services.dart';
import 'package:accident_risk_warning_app/services/location_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationServices _locationServices=LocationServices();
  final DangerZoneServices _dangerZoneServices=DangerZoneServices();

  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoading=true;
  String? _errorMessage;
  Set<String> _alertZones={};

  Map<String,dynamic> _alertInfo={
    'type':'safe',
    'message':'Güvenli bölgedesiniz',
    'zones': <String>{},
  };
  Set<Marker> _marker={};
  Set<Circle> _circles={};


  @override
  void initState() {
    super.initState();
    _initApp();
  }
  Future<void> _initApp() async{
    try{
      await _dangerZoneServices.loadZones();
      _updateMarkersAndCircles();
      await _initLocation();
    }catch(e){
      setState(() {
        _isLoading=false;
        _errorMessage = "Veriler yüklenirken hata oluştu: $e";
      });
    }
  }
  Future<void> _initLocation() async{
    try{
      Position? position=await _locationServices.getCurrentLocation(context);
      if(position != null){
        setState(() {
          _currentPosition=LatLng(position.latitude, position.longitude);
          _isLoading=false;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
        _checkProximityAndAlert(position);

        _locationServices.locationStream.listen((pos) {
          LatLng newPos=LatLng(pos.latitude, pos.longitude);
          setState(() {
            _currentPosition=newPos;
          });
          _checkProximityAndAlert(pos);
          _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
        });
      } else{
        setState(() {
          _isLoading=false;
          _errorMessage="Konum alınamadı. Lütfen izinleri kontrol edin.";
        });
      }
    }catch(e){
      setState(() {
        _isLoading=false;
        _errorMessage = 'Konum alınırken bir hata oluştu: $e';
      });
    }
  }

  void _updateMarkersAndCircles(){
    final zones=_dangerZoneServices.zones;
    final markers=zones.map((zone)=>Marker(markerId: MarkerId(zone.name),
    position: LatLng(zone.lat, zone.lng),
    infoWindow: InfoWindow(title: zone.name),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange))).toSet();

    final circles=zones.map((zone)=>Circle(circleId: CircleId(zone.name),
    center: LatLng(zone.lat, zone.lng),
    radius: zone.radius,
      fillColor: Colors.red.withOpacity(0.3),
      strokeColor: Colors.red,
      strokeWidth: 2
    )).toSet();

    setState(() {
      _marker=markers;
      _circles=circles;
    });
  }

  void _checkProximityAndAlert(Position pos){
    final inDangerZones=_dangerZoneServices.checkInDangerZone(pos);
    final nearbyZones=_dangerZoneServices.checkNearbyZones(pos);
    setState(() {
      if(inDangerZones.isNotEmpty){
        _alertInfo={
          'type':'danger',
          'message':'DİKKAT TEHLİKELİ BÖLGEDESİNİZ!',
          'zones':inDangerZones.map((z)=>z.name).toSet()
        };
      } else if(nearbyZones.isNotEmpty){
        _alertInfo={
          'type':"warning",
          'message':'Dikkat! Tehlikeli bölgeye yaklaşıyorsunuz',
          'zones':nearbyZones.map((z)=>z.name).toSet()
        };
      } else{
        _alertInfo={
          'type':'safe',
          'message':'Güvenli bölgedesiniz',
          'zones':<String>{}
        };
      }
    });
  }
  Future<void> _refreshLocation() async{
    setState(() {
      _isLoading=true;
      _errorMessage=null;
    });
    await _initLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kaza Riski Uyarı Sistemi"),
      centerTitle: true,),
      body: _isLoading?
      Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16,),
          Text("Konumunuz alınıyor...")
        ],
      ),): _errorMessage != null ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 32),child: Text(_errorMessage!,textAlign: TextAlign.center,style: TextStyle(fontSize: 16),),
            ),
            SizedBox(height: 24,),
            ElevatedButton.icon(onPressed: _refreshLocation, label: Text("Tekrar dene"),icon: Icon(Icons.refresh),)
          ],
        ),
      ):
      Stack(
        children: [
          GoogleMap(initialCameraPosition: CameraPosition(target: _currentPosition!,zoom: 17),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller){
              _mapController=controller;
            },
          markers: _marker,
          circles: _circles,),
            Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12,horizontal: 16),
                  decoration: BoxDecoration(
                    color: _alertInfo['type']=='danger' ?
                      Colors.redAccent:
                      _alertInfo['type']=='warning'? Colors.orange:Colors.green,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2)
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_alertInfo['message'],
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),
                      textAlign: TextAlign.center,),
                      if((_alertInfo['zones'] as Set<String>).isNotEmpty) ...[
                        SizedBox(height: 4,),
                        Text('Bölgeler: ${(_alertInfo['zones'] as Set<String>).join(', ')}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14
                        ),
                        textAlign: TextAlign.center,)
                      ]
                    ],
                  )

                ))
        ],
      )
    );
  }
}
