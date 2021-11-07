import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urbanbus/Screens/directions.dart';

import 'directions_model.dart';
const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
class MainScreen extends StatefulWidget{
    @override
    static const String idScreen="mainscreen";
    _MainScreenState createState()=>_MainScreenState();
}

class _MainScreenState extends State<MainScreen>{

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  List places=[{'location':'RGIA','latitude':17.2403,'longitude':78.4294},{'location':'Gachibowli(ORR)','latitude':17.440081,'longitude':78.348915},{'location':'Shilparamam(Hitech City)','latitude':17.4526,'longitude':78.3783},{'location':'JNTU','latitude':17.4933,'longitude':78.3914}];
  Completer<GoogleMapController> _controller=Completer();
  Map<PolylineId,Polyline> polylines={};
  Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints=PolylinePoints();
  List<Marker> allMarkers=[];
  String googleAPIKey = "AIzaSyArbAIIe2DNFzV8bWdqno7S-9UcZmMlkos";
  @override
  void initState() {
    super.initState();
    setSourceAndDestinationIcons();
  }
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.defaultMarkerWithHue(96);
    destinationIcon = await BitmapDescriptor.defaultMarkerWithHue(0);
  }
  @override
  Widget build(BuildContext context) {
    final LatLng SOURCE_LOCATION = new LatLng(places[0]['latitude'], places[0]['longitude']);
    final LatLng DEST_LOCATION = new LatLng(places[places.length-1]['latitude'], places[places.length-1]['longitude']);
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: SOURCE_LOCATION
    );
    return GoogleMap(
        myLocationEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        markers: _markers,
        polylines: Set<Polyline>.of(polylines.values),
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        onMapCreated: onMapCreated
    );
  }
  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setMapPins();
    setPolylines();
  }
  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: LatLng(places[0]['latitude'], places[0]['longitude']),
          icon: sourceIcon
      ));
      for(int i=1;i<places.length-1;i++){
        _markers.add(Marker(
            markerId: MarkerId('Pin'+i.toString()),
            position: LatLng(places[i]['latitude'], places[i]['longitude']),
            icon: sourceIcon
        ));
      }
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: LatLng(places[places.length-1]['latitude'], places[places.length-1]['longitude']),
          icon: destinationIcon
      ));
    });
  }
  _addPolyline(){
    // create a Polyline instance
    // with an id, an RGB color and the list of LatLng pairs
    PolylineId id=PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Color.fromARGB(255, 40, 122, 198),
        points: polylineCoordinates
    );
    polylines[id]=polyline;
    setState((){});

    // add the constructed polyline as a set of points
    // to the polyline set, which will eventually
    // end up showing up on the map
    //polylines.add(polyline);
    //});
  }
  setPolylines() async {
    GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(
        apiKey: "AIzaSyArbAIIe2DNFzV8bWdqno7S-9UcZmMlkos");
    //List<LatLng> result = await googleMapPolyline.getCoordinatesWithLocation(
    //        origin: LatLng(places[0]['latitude'],places[0]['longitude']),
    //         destination: LatLng(places[places.length-1]['latitude'], places[places.length-1]['longitude']),
    //        mode: RouteMode.driving);
    PolylinePoints polylinePoints = PolylinePoints();
    for(int i=0;i<places.length-1;i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleAPIKey,
          PointLatLng(places[i]['latitude'],
              places[i]['longitude']),
          PointLatLng(places[i+1]['latitude'],
              places[i+1]['longitude']),
          travelMode: TravelMode.driving);
      print(result);
      if (result.points.isNotEmpty) {
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(
              LatLng(point.latitude, point.longitude));
        });
      }
    }
    print(polylineCoordinates);
    _addPolyline();
  }

  //GoogleMapPolyline googleMapPolyline= new GoogleMapPolyline(apiKey:"AIzaSyACnONgAw8F8sJ8Hxj1F3Qr6ghDj_oBw8M" );
  //getsomePoints() async{
    //var permissions = await Permission.getPermissionsStatus([PermissionName.Location]);
    //if(permissions[0].permissionStatus==PermissionStatus.notAgain) {
    //  var askpermissions = await Permission.requestPermissions(
    //      [PermissionName.Location]);
    //} else {
   //   routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
   //       origin: LatLng(40.6782, -73.9442),
   //       destination: LatLng(40.6944, -73.9212),
   //       mode: RouteMode.driving);
    //}
  //}

  //static const CameraPosition _initialCameraPosition=CameraPosition(
  //    target: LatLng(17.2403,78.4294),
  //    zoom:14.474
   // );
   // @override
   // void dispose(){
   //   _googleMapController.dispose();
   //   super.dispose();
   // }
  //  @override
  //  Widget build(BuildContext context) {
  //    final LatLng _center = new LatLng(
  //        places[0]['latitude'], places[0]['longitude']);
  //    var points = [];
  //    BitmapDescriptor descriptor = BitmapDescriptor.defaultMarkerWithHue(96);
  //    for (int i = 0; i < places.length-1; i++) {

//        if (i == places.length - 1) {
 //         descriptor = BitmapDescriptor.defaultMarkerWithHue(0);
  //      }
  //      else if (i != 0 && i != places.length - 1) {
  //        descriptor = BitmapDescriptor.defaultMarkerWithHue(90);
   //     }
   //     allMarkers.add(Marker(
   //         markerId: MarkerId('markers'+i.toString()),
   //         draggable: false,
    //        icon: descriptor,
     //       position: LatLng(places[0]['latitude'],
      //          places[0]['longitude']),
       //     infoWindow: InfoWindow(
       //       title: 'Location: ' + places[0]['location'],
       //     )
       // )
       // );
     // }
     // void _onMapCreated(GoogleMapController controller) {
     //   setState(() {
      //    _controller = controller;
       //   polyline.add(Polyline(
       //       polylineId: PolylineId('route'),
       //       visible: true,
       //       points: points,
        //      width: 2,
         //     color: Colors.blue,
         //     startCap: Cap.roundCap,
         //     endCap: Cap.buttCap));
    //    });
     // }

      //return Scaffold(
       // appBar: AppBar(
       //   title: Text("MainScreen"),
       // ),
        //body:
    //    GoogleMap(
     //     mapType: MapType.normal,
      //    initialCameraPosition: CameraPosition(
       //     target: _center,
       //     zoom: 14.0,
       //   ),
       //   onMapCreated: _onMapCreated,
       //   markers: Set.from(allMarkers),
       //   polylines:polyline,
          //{
          //  setState((){
          //    _controller = controller;
          //    polyline.add(Polyline(
          //      polylineId: PolylineId('route1'),
          //      visible: true,
          //      points: routeCoords,
          //      width:4,
          //      color:Colors.blue,
          //     startCap: Cap.roundCap,
          //      endCap: Cap.buttCap
          //    ));
          //  });
          //  _controllerGoogleMap.complete(controller);
          //  newGoogleMapController=controller;
          //},
        //),

   //   );
   // }
}


