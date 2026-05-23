import 'package:flutter/material.dart';

class Trip {
  final String destination;
  final String date;
  final String status;
  final String imagePath;
  final bool isUpcoming;

  Trip({
    required this.destination,
    required this.date,
    required this.status,
    required this.imagePath,
    required this.isUpcoming,
  });
}

class DocumentItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DocumentItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
