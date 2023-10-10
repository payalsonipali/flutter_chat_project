import 'package:chatting_app/view/home.dart';
import 'package:chatting_app/view/login.dart';
import 'package:chatting_app/view/signup.dart';
import 'package:flutter/material.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    '/home': (context) =>  Home(),
    '/login': (context) => const Login(),
    '/signup': (context) => const SignUp(),
    };
}