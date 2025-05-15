import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class StoreMarker extends StatefulWidget {
  final LatLng point;
  final String customerName;

  const StoreMarker({
    required this.point,
    required this.customerName,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StoreMarkerState createState() => _StoreMarkerState();
}

class _StoreMarkerState extends State<StoreMarker> {
  bool _isNameVisible = false;

  void _toggleNameVisibility() {
    setState(() {
      _isNameVisible = !_isNameVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggleNameVisibility,
              child: Image.asset(
                'assets/images/store_location_pin_icon.png',
                width: 50.0,
                height: 40.0,
              ),
            ),
            if (_isNameVisible) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  widget.customerName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
