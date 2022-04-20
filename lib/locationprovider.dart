import 'package:flutter/cupertino.dart';
import 'package:latlng/latlng.dart';
import 'package:location/location.dart';
import 'dart:developer';

class LocationProvider with ChangeNotifier {
  Location? _location;
  Location get location => _location!;
  LatLng? _locatiopos;
  LatLng get locationpos => _locatiopos!;

  bool locationactiver = true;

  LocationProvider() {
    _location = new Location();
  }

  initialization() async {
    await getuserlocation();
  }

  getuserlocation() async {
    bool _serviceenabled;
    PermissionStatus _permissiongranted;

    _serviceenabled = await location.serviceEnabled();
    if (!_serviceenabled) {
      _serviceenabled = await location.requestService();

      if (!_serviceenabled) return;
    }

    _permissiongranted = await location.hasPermission();
    if (_permissiongranted == PermissionStatus.denied) {
      _permissiongranted = await location.requestPermission();
      if (_permissiongranted != PermissionStatus.granted) return;
    }
    try {
      await location.enableBackgroundMode(enable: true);
    } catch (error) {
      print("Can't set background mode");
    }

    location.onLocationChanged.listen((LocationData currentlocation) {
      _locatiopos =
          LatLng(currentlocation.latitude!, currentlocation.longitude!);
    });
    // print(_locatiopos);

    log('loc: $_locatiopos');
    notifyListeners();
  }
}
