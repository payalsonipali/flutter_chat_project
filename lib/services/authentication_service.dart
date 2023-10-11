import 'package:chatting_app/utils/shared_preference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {

  final BuildContext context;
  AuthenticationService(this.context);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  get user => _auth.currentUser;

  Future<UserCredential?> signUp({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveUserToSharedPreferences();
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'email': userCredential.user?.email,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Email already in Use!'),
          behavior: SnackBarBehavior.floating, // Use floating behavior
          margin: EdgeInsets.fromLTRB(20,0,20,50),
        ));
      }
      return null;
    }
  }

  Future signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await saveUserToSharedPreferences();
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No user found for that email!'),
          behavior: SnackBarBehavior.floating, // Use floating behavior
          margin: EdgeInsets.fromLTRB(20,0,20,50),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Wrong password provided for that user!'
          ),
          behavior: SnackBarBehavior.floating, // Use floating behavior
          margin: EdgeInsets.fromLTRB(20,0,20,50),
        ));
      }
      return null;
    }
  }

  saveUserToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPref.instance;
    final currentUser = _auth.currentUser;
    if(currentUser==null){
      return;
    }
    await sharedPreferences.setString('email', currentUser.email!);
    await sharedPreferences.setBool('isLoggedIn', true);
  }

  Future signOut() async {
    SharedPreferences sharedPreferences = await SharedPref.instance;
    if(_auth.currentUser!=null){
      await _auth.signOut();
    }
    await sharedPreferences.clear();

  }
}