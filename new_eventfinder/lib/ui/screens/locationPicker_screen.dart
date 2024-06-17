import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  Future<void> _handlePressButton() async {
    final query = await _showSearchDialog();
    if (query != null && query.isNotEmpty) {
      final url = 'http://maps.google.com/?q=$query';
      if (await canLaunch(url)) {
        await launch(url);
        // Tunggu beberapa saat sampai user membuka link dan kembali ke aplikasi
        await Future.delayed(Duration(seconds: 5));
        _extractCoordinatesFromURL(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Future<String?> _showSearchDialog() async {
    String? searchQuery;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: Text('Search Location'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter location'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () {
                searchQuery = _controller.text;
                Navigator.of(context).pop(searchQuery);
              },
            ),
          ],
        );
      },
    );
    return searchQuery;
  }

  void _extractCoordinatesFromURL(String url) {
    final regex = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+),');
    final match = regex.firstMatch(url);
    if (match != null) {
      final lat = double.parse(match.group(1)!);
      final lng = double.parse(match.group(2)!);
      developer.log('Extracted coordinates: $lat, $lng');

      setState(() {
        _pickedLocation = LatLng(lat, lng);
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
    } else {
      developer.log('Failed to extract coordinates from URL.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Lokasi Acara'),
        backgroundColor: const Color(0xFF30244D),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _handlePressButton,
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_pickedLocation != null) {
                Navigator.of(context).pop(_pickedLocation);
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-6.200000, 106.816666),
          zoom: 15,
        ),
        onTap: _selectLocation,
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: MarkerId('m1'),
                  position: _pickedLocation!,
                ),
              },
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
