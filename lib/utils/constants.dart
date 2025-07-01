// lib/utils/constants.dart
import 'package:flutter/material.dart';

// App Colors
const Color kPrimaryColor = Color(0xFF0077B6);
const Color kSecondaryColor = Color(0xFF00B4D8);
const Color kAccentColor = Color(0xFF90E0EF);
const Color kBackgroundColor = Color(0xFFF8F9FA);
const Color kTextColor = Color(0xFF212529);
const Color kLightTextColor = Color(0xFF6C757D);
const Color kSuccessColor = Color(0xFF28A745);
const Color kErrorColor = Color(0xFFDC3545);
const Color kWarningColor = Color(0xFFFFC107);

// Padding and margins
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;

// Border radius
const double kDefaultBorderRadius = 10.0;
const double kSmallBorderRadius = 5.0;
const double kLargeBorderRadius = 20.0;

// Text styles
const TextStyle kHeadingTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

const TextStyle kSubheadingTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: kTextColor,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 16,
  color: kTextColor,
);

const TextStyle kCaptionTextStyle = TextStyle(
  fontSize: 14,
  color: kLightTextColor,
);

// Animation durations
const Duration kDefaultAnimationDuration = Duration(milliseconds: 300);
const Duration kSlowAnimationDuration = Duration(milliseconds: 500);

// API endpoints
const String kBaseApiUrl = 'https://api.smartparkingapp.com';

// Map default settings
const double kDefaultMapZoom = 14.0;
const double kCloseMapZoom = 17.0;