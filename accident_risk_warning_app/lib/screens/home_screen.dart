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
  LatLng? _currentPossition;
  final LatLng _center=const LatLng(37.7765, 29.0864);
  void _onMapCreated(GoogleMapController controller){
    _mapController=controller;
  }
  @override
  void initState() {
    super.initState();
    _initLocation();
  }
  Future<void> _initLocation() async{
    Position? position=await _locationServices.getCurrentLocation();
    if(position != null){
      setState(() {
        _currentPossition=LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPossition!));

      _locationServices.locationStream.listen((pos) {
        setState(() {
          _currentPossition = LatLng(pos.latitude, pos.longitude);
        });
        _mapController?.animateCamera(
            CameraUpdate.newLatLng(_currentPossition!));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kaza Riski Uyarı Sistemi"),
      centerTitle: true,),
      body: _currentPossition==null?
      Center(child: CircularProgressIndicator(),):
      GoogleMap(initialCameraPosition: CameraPosition(target: _currentPossition!,zoom: 15),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller){
        _mapController=controller;
      },),
    );
  }
}
