import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool hasPermission = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchPermissionStatus();
  }

  void fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((value) {
      if (mounted) {
        setState(() {
          hasPermission = (value == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body
      body: Builder(
        builder: (context) {
          if (hasPermission) {
            return buildCompass();
          } else {
            return buildPermissionSheet();
          }
        },
      ),
    );
  }

  /// compass widget

  Widget buildCompass() {
    return StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          /// error msg
          if (snapshot.hasError) {
            return Text('Error reading Heading ${snapshot.hasError}');
          }

          /// loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          double? direction = snapshot.data!.heading;

          /// if direction is null, then device not support this sensor
          if (direction == null) {
            return const Center(
              child: Text('Device does not have compass sensors'),
            );
          }

          return Center(
            child: Container(
              padding: const EdgeInsets.all(30.0),
              child: Transform.rotate(
                angle: direction * (math.pi / 180) * -1,
                child: Image.asset('assets/images/compass.png',
                color: Colors.black,
                ),
              ),
            ),
          );
        });
  }

  /// permission sheet widget

  Widget buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: Text('Request Permission'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            fetchPermissionStatus();
          });
        },
      ),
    );
  }
}
