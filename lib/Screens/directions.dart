import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urbanbus/Screens/directions_model.dart';

class Direction{
  static const String _baseUrl=
        'https://maps.googleapis.com/maps/api/directions/json?';
  final Dio _dio;
  Direction({Dio? dio}):_dio=dio ?? Dio();//maps.
  Future<Directions?> getDirections({
  required LatLng origin,
  required LatLng destination,
}) async{
    final response=await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin':'${origin.latitude},${origin.longitude}',
        'destination':'${destination.latitude},${destination.longitude}',
        'key':'AIzaSyACnONgAw8F8sJ8Hxj1F3Qr6ghDj_oBw8M',
      }
    );
    if (response.statusCode==200){
      return Directions.fromMap(response.data);
    }
    return null;
  }


}