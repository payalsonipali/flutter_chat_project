import 'package:chatting_app/provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatting_app/shared_preference.dart';
import 'package:chatting_app/routes.dart';
import 'package:chatting_app/view/home.dart';
import 'package:chatting_app/view/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPref.init();
  SharedPreferences prefs = await SharedPref.instance;
  bool isUserLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(
      ChangeNotifierProvider(
        create: (context) => PasswordProvider(), // Replace with your data model.
        child: MaterialApp(
                title: "Chatting App",
                debugShowCheckedModeBanner: false,
                routes: Routes.routes,
                home:isUserLoggedIn ? Home() : const Login()
              ),
      ),
  );
}