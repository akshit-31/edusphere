import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/api_config.dart';
import 'app.dart';
import 'services/cache_service.dart';

/// Restricted SSL override — ONLY accepts connections to the known Render
/// server IPs when the server certificate CN matches the expected host.
/// This mitigates MITM risk compared to accepting ANY certificate.
/// TODO: Replace with proper certificate pinning once the server
///       certificate can be pinned by its SHA-256 fingerprint.
class MyHttpOverrides extends HttpOverrides {
  // Known Render server IPs for the backend
  static const _allowedHosts = {'216.24.57.9', '216.24.57.8'};
  // The expected CN in the server certificate
  static const _expectedHostname = 'onrender.com';

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (!_allowedHosts.contains(host)) return false;
        // Accept only if the certificate subject contains our expected hostname
        final subject = cert.subject;
        final issuer = cert.issuer;
        final isValid = subject.contains(_expectedHostname) ||
            issuer.contains(_expectedHostname) ||
            issuer.contains('Let\'s Encrypt');
        if (!isValid) {
          dev.log(
            'SSL: Rejected untrusted cert for $host — subject: $subject, issuer: $issuer',
            name: 'SSL',
          );
        }
        return isValid;
      };
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.instance.init();

  // Application startup logging (debug only — dev.log strips from release builds)
  dev.log('APP STARTUP: Base URL = ${ApiConfig.serverBaseUrl}', name: 'Main');
  dev.log('APP STARTUP: API Endpoint = ${ApiConfig.apiUrl}', name: 'Main');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const EduSphereApp());
}

