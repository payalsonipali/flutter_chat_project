import 'package:chatting_app/utils/provider.dart';
import 'package:chatting_app/services/authentication_service.dart';
import 'package:chatting_app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                _buildEmailContainer(),
                SizedBox(
                  height: 40,
                ),
                _buildPasswordContainer(),
                SizedBox(
                  height: 40,
                ),
                _buildLoginButton(),
                SizedBox(
                  height: 40,
                ),
                _buildAlreadyHaveAccount(),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Container _buildLoginButton() {
    return Container(
      height: 60,
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          onPressed: () async {
            if (validateForm()) {
              final result = await AuthenticationService(context).signUp(
                  email: _emailController.text,
                  password: _passwordController.text);
              if (result != null) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/home', (route) => false);
              }
            }
          },
          child: Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
    );
  }

  Container _buildEmailContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                decoration: InputDecoration(border: UnderlineInputBorder()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildPasswordContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            child:
                Consumer<PasswordProvider>(builder: (context, provider, child) {
              return TextFormField(
                controller: _passwordController,
                obscureText: provider.isPasswordObscured,
                decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          provider.togglePasswordVisibility();
                        });
                      },
                      child: Icon(
                          provider.isPasswordObscured
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                    ),
                    border: const UnderlineInputBorder()),
              );
            }),
          ),
        ],
      ),
    );
  }

  GestureDetector _buildAlreadyHaveAccount() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already Have An Account?",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Sign In",
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
    final passwordValidateString =
        isPasswordValid(_passwordController.text.trim());
    if (passwordValidateString != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(passwordValidateString),
        behavior: SnackBarBehavior.floating, // Use floating behavior
        margin: EdgeInsets.fromLTRB(20, 0, 20, 50),
      ));
      return false;
    }
    return true;
  }
}
