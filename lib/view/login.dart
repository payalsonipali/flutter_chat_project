import 'package:chatting_app/provider.dart';
import 'package:chatting_app/services/authentication_service.dart';
import 'package:chatting_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  final PasswordProvider _passwordProvider = PasswordProvider();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Sign In",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                _emailContainer(),
                SizedBox(
                  height: 40,
                ),
                _passwordContainer(),
                SizedBox(
                  height: 40,
                ),
                _signInContainer(),
                SizedBox(
                  height: 40,
                ),

                SizedBox(
                  height: 40,
                ),
                _buildUserDontHaveAccount(),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Container _emailContainer(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.email,
            color: Color(0xff46d0c3),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                controller: _emailController,
                decoration:
                InputDecoration(border: UnderlineInputBorder()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _passwordContainer(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: Color(0xff46d0c3),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Consumer<PasswordProvider>(
                builder: (context, provider, child) {
                  return TextFormField(
                    obscureText: provider.isPasswordObscured,
                    controller: _passwordController,
                    decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            provider.togglePasswordVisibility();
                          },
                          child: Icon(
                            provider.isPasswordObscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                        border: UnderlineInputBorder()),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  Container _signInContainer(){
    return Container(
      height: 60,
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey),
          onPressed: () async {
            if (validateForm()) {
              final credential =
              await AuthenticationService(context).signIn(
                  email: _emailController.text,
                  password: _passwordController.text);
              if (credential != null) {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              }
            }
          },
          child: Text(
            "Sign In",
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
    );
  }

  GestureDetector _buildUserDontHaveAccount(){
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamedAndRemoveUntil('/signup', (route) => false);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "New user?",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(width: 5,),
          Text(
            "Sign Up",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  bool validateForm() {
    if (!isEmailValid(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid email!'),
        behavior: SnackBarBehavior.floating, // Use floating behavior
        margin: EdgeInsets.fromLTRB(20, 0, 20, 50),
      ));
      return false;
    }
    if (_passwordController.text.trim() == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a password!'),
        behavior: SnackBarBehavior.floating, // Use floating behavior
        margin: EdgeInsets.fromLTRB(20, 0, 20, 50),
      ));
      return false;
    }
    return true;
  }
}
