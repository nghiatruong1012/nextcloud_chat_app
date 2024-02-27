import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/utils.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class Location extends StatefulWidget {
  const Location({super.key, required this.token});
  final String token;

  @override
  State<Location> createState() => _LocationState(token: token);
}

class _LocationState extends State<Location> {
  Future<Position> position =
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  final String token;

  _LocationState({required this.token});

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('')),
        body: FutureBuilder(
          future: position,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return OpenStreetMapSearchAndPick(
                  center: LatLong(
                      snapshot.data!.latitude, snapshot.data!.longitude),
                  buttonColor: Colors.blue,
                  buttonText: 'Set Current Location',
                  onPicked: (pickedData) {
                    print(pickedData.latLong.latitude);
                    print(pickedData.latLong.longitude);
                    print(pickedData.address);
                    ChatService().shareRichObject(token, {
                      "objectType": 'geo-location',
                      "objectId":
                          "geo:${pickedData.latLong.latitude},${pickedData.latLong.longitude}",
                      "metaData": jsonEncode(
                        {
                          "id":
                              "geo:${pickedData.latLong.latitude},${pickedData.latLong.longitude}",
                          "name": pickedData.address.values.join(', '),
                          "latitude": pickedData.latLong.latitude.toString(),
                          "longitude": pickedData.latLong.longitude.toString()
                        },
                      ),
                      "actorDisplayName": '',
                      "referenceId": generateRandomStringWithSha256(64),
                    });
                    Navigator.pop(context);
                  });
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error'),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
