// lib/core/utils/constants.dart
import 'package:flutter/material.dart';

// App Colors
const kPrimaryColor = Color(0xFF0077B6);
const kSecondaryColor = Color(0xFF00B4D8);
const kBackgroundColor = Colors.white;
const kErrorColor = Colors.red;
const kSuccessColor = Colors.green;

// Map Constants
const double kDefaultMapZoom = 15.0;
const double kDefaultMarkerZoom = 16.0;

// Padding and Spacing
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;

// Text Sizes
const double kHeadingSize = 24.0;
const double kSubheadingSize = 18.0;
const double kBodySize = 16.0;
const double kCaptionSize = 14.0;

// Animation Durations
const Duration kShortAnimationDuration = Duration(milliseconds: 250);
const Duration kMediumAnimationDuration = Duration(milliseconds: 500);
const Duration kLongAnimationDuration = Duration(milliseconds: 800);

// API Constants
const int kApiTimeoutSeconds = 15;
const int kApiRetries = 3;

// Kathmandu boundaries for random generation
const double kKathmanduMinLat = 27.6698;
const double kKathmanduMaxLat = 27.7300;
const double kKathmanduMinLng = 85.2885;
const double kKathmanduMaxLng = 85.3700;

// Default position for Kathmandu (Thamel area)
const double kKathmanduDefaultLat = 27.7172;
const double kKathmanduDefaultLng = 85.3240;