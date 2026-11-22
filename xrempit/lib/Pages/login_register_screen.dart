import 'package:flutter/material.dart';

import '../Pages/login_screen.dart';
import '../Pages/signup_screen.dart';
//import 'package:xrempit/main.dart';



class LogOrRegScreen extends StatefulWidget {

  const LogOrRegScreen({super.key});

  @override
  State<LogOrRegScreen> createState() => _LogOrRegScreenState();

}

class _LogOrRegScreenState extends State<LogOrRegScreen> {
  
  // to toggle between login and register
  bool showLogin = true;
  
  void toggleScreens(){
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin){
      return LoginScreen(
        onTap: toggleScreens
      );
    }
    else{
      return SignupScreen(
        onTap: toggleScreens
      );
    }
  }
}