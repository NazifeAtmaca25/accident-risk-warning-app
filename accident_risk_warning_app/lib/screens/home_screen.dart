import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  final LatLng _center=const LatLng(37.7765, 29.0864);
  void _onMapCreated(GoogleMapController controller){
    mapController=controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kaza Riski Uyarı Sistemi"),
      centerTitle: true,),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target:_center,zoom: 11),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,),
    );
  }
}
