import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class StatusBar extends StatefulWidget {
  @override
  _StatusBarState createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late Timer _timer;
  String _timeString = "";

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getTime() {
    final String formattedDateTime = _formatTime(DateTime.now());
    if (mounted) setState(() => _timeString = formattedDateTime);
  }

  String _formatTime(DateTime dateTime) => DateFormat('HH:mm').format(dateTime);

  @override
  Widget build(BuildContext context) {
    // "Fake OS" look - Mundane, intrusive, real
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _timeString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            )
          ),
          const Row(
            children: [
              Icon(Icons.signal_cellular_alt_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Icon(Icons.wifi_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              // Battery
              Icon(Icons.battery_5_bar_rounded, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
