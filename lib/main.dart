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
  runApp(
      ChangeNotifierProvider(
        create: (context) => PasswordProvider(), // Replace with your data model.
        child: const MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chatting App",
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: Routes.routes,
      home: FutureBuilder<bool>(
        future: checkUserLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return const CircularProgressIndicator();
          } else {
            return snapshot.data!  ? Home() : const Login();
          }
        },
      ),
    );
  }

  Future<bool> checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    return email.isNotEmpty;
  }
}