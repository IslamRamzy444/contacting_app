
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/features/auth/login/presentation/views/screens/login_screen.dart';
import 'package:contacting_app/features/auth/register/presentation/views/screens/register_screen.dart';
import 'package:contacting_app/features/calls/presentation/views/screens/audio_screen.dart';
import 'package:contacting_app/features/calls/presentation/views/screens/incoming_call_screen.dart';
import 'package:contacting_app/features/calls/presentation/views/screens/video_call_screen.dart';
import 'package:contacting_app/features/home/presentation/views/screens/home_screen.dart';
import 'package:contacting_app/features/profile/presentation/views/screens/edit_profile_screen.dart';
import 'package:contacting_app/features/search/presentation/views/screens/search_screen.dart';
import 'package:contacting_app/features/splash/presentation/views/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> getRoutes(RouteSettings settings){
    switch(settings.name){
      case AppRoutes.login:
        return MaterialPageRoute(builder: (context) => const LoginScreen(),);
      case AppRoutes.register:
        return MaterialPageRoute(builder: (context) => const RegisterScreen(),);
      case AppRoutes.home:
        return MaterialPageRoute(builder: (context) => const HomeScreen(),);
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen(),);
      case AppRoutes.search:
        return MaterialPageRoute(builder: (context) => const SearchScreen(),);
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (context) => const EditProfileScreen(),); 
      case AppRoutes.audioCall:
        return MaterialPageRoute(builder: (context) => const AudioScreen(),settings: settings);
      case AppRoutes.videoCall:
        return MaterialPageRoute(builder: (context) => const VideoCallScreen(),settings: settings);
      case AppRoutes.incomingCall:
        return MaterialPageRoute(builder: (context) => const IncomingCallScreen(),settings: settings);    
       default:
        return unDefinedRoute();
    }
  }
  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('No Route Found')),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
}