import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/service_detail_screen.dart';
import 'screens/booking_new_screen.dart';
import 'screens/my_bookings_screen.dart';

class AppRoutes {
  static const home = '/';
  static const serviceDetail = '/service/detail';
  static const bookingNew = '/booking/new';
  static const login = '/login';
  static const register = '/register';
  static const myBookings = '/bookings';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);

    case AppRoutes.serviceDetail: {
      final map = (settings.arguments as Map?) ?? const {};
      return MaterialPageRoute(
        builder: (_) => ServiceDetailScreen(
          id: (map['id'] ?? '') as String,
          title: (map['title'] ?? '') as String,
          description: (map['description'] ?? '') as String,
          rating: ((map['rating'] ?? 0) as num).toDouble(),
        ),
        settings: settings,
      );
    }

    case AppRoutes.bookingNew: {
      final map = (settings.arguments as Map?) ?? const {};
      return MaterialPageRoute(
        builder: (_) => BookingNewScreen(
          serviceId: (map['serviceId'] ?? '') as String,
          serviceTitle: (map['serviceTitle'] ?? '') as String,
        ),
        settings: settings,
      );
    }

    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);

    case AppRoutes.register:
      return MaterialPageRoute(builder: (_) => const RegisterScreen(), settings: settings);

    case AppRoutes.myBookings:
      return MaterialPageRoute(builder: (_) => const MyBookingsScreen(), settings: settings);

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        settings: settings,
      );
  }
}
