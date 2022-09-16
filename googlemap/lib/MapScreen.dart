import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late List<Marker> _markers;
  Set<Marker> markers = Set();
  Set<Circle> circles = Set();
  bool isActivated = false;
  double boundryLAT = 0;
  double boundryLON = 0;
  bool changed = false;

  var radius = 60.0;
  Completer<GoogleMapController> _controller = Completer();

  DatabaseReference ref =
      FirebaseDatabase.instance.reference().child("gps_devices/sim800gps00001");

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-0.093018, -78.517925),
    zoom: 14.4746,
  );
  var lat = LatLng(-0.093018, -78.517925);

  @override
  void initState() {}
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text("your pet has left the created geofence"),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.blueAccent,
        title: Text("Petroute",style:TextStyle(fontSize: 22,color:Colors.white,fontWeight: FontWeight.bold,fontFamily:"cursive",)),
        actions: [
          Row(
            children: [
              Text("Activate"),
              Switch(
                onChanged: (value) {
                  setState(() {
                    isActivated = value;
                    changed = value;
                  });
                },
                value: isActivated,
                activeColor: Colors.red,
                activeTrackColor: Colors.yellow,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white54,
              ),
            ],
          ),
          IconButton(
              onPressed: () {
                showBoundry(context);
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, AsyncSnapshot<Event> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          markers.clear();
          circles.clear();
          DataSnapshot dataValues = snapshot.data!.snapshot;
          Map<dynamic, dynamic> values = dataValues.value;

          double latt = double.parse(
              values['lat'].substring(1, values['lat'].toString().length - 1));
          double lang = double.parse(
              values['lng'].substring(1, values['lat'].toString().length - 1));
          Marker resultMarker = Marker(
              markerId: MarkerId(values['lng'].toString()),
              position: LatLng(latt, lang));
// Add it to Set
          markers.add(resultMarker);
          if (isActivated) {
            if (changed) {
              boundryLAT = latt;
              boundryLON = lang;

              circles.add(Circle(
                  circleId: CircleId("0qwe"),
                  center: LatLng(boundryLAT, boundryLON),
                  radius: radius,
                  strokeWidth: 2,
                  strokeColor: Colors.red,
                  fillColor: Colors.black12));
              changed = false;
            } else {
              circles.add(Circle(
                  circleId: CircleId("0qwe"),
                  center: LatLng(boundryLAT, boundryLON),
                  radius: radius,
                  strokeWidth: 2,
                  strokeColor: Colors.red,
                  fillColor: Colors.black12));
            }
          }

          lat = LatLng(latt, lang);
          if(isActivated)
            {
              var distance = calculateDistance(latt, lang, boundryLAT, boundryLON);
              var meter = distance * 1000;
              if (meter > radius) {
                Future.delayed(Duration.zero, () => showAlert(context));
              }
            }


          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: lat,
              zoom: 16.4746,
            ),
            circles: circles,
            scrollGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: markers,
            onCameraMove: (position) {
              print("kkkk");
            },
            onCameraMoveStarted: () {
              print("kkkk");
            },
          );
        },
      ),
    );
  }

  Future<void> showBoundry(BuildContext context) async {
    var result = await showDialog(
      context: context,
      builder: (context) {
        String BoundryRadius = "";

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("GeoFence"),
              content: TextField(
                onChanged: (v) {
                  BoundryRadius = v;
                },
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      print(radius.toString());
                      radius = double.parse(BoundryRadius);
                      print(radius.toString());

                      Navigator.pop(context);
                    });
                  },
                  child: Text("Change"),
                ),
              ],
            );
          },
        );
      },
    );

    setState(() {});
  }
}
