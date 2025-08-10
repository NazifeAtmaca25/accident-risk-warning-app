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
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoading=true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLocation();
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

        _locationServices.locationStream.listen((pos) {
          setState(() {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
          });
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
      GoogleMap(initialCameraPosition: CameraPosition(target: _currentPosition!,zoom: 17),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller){
        _mapController=controller;
      },),
    );
  }
}
