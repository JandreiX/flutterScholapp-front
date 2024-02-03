import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_front/models/api.dart';
import 'package:flutter_front/models/api_response.dart';
import 'package:flutter_front/views/navigated_pages/main_page.dart';
import 'package:flutter_front/views/auth/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert' as convert;

class LoginPage extends StatefulWidget {

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  var formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String email = "";
  String password = "";

  bool validate(String email, String password){     // Validate if email is valid
    if(email.isEmpty || password.isEmpty) {
      return false;
    }
    else if(EmailValidator.validate(email, true)){
      return true;
    }
    else {
      return false;
    }
  }

  showStatus({required Color color, required String text}) {    // Snackbar to show message of API Response

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(text),
            backgroundColor: color,
            padding: const EdgeInsets.all(15),
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )
        )
    );
  }


  login(context) async {    //  Login function to attempt Authentication and set Shared Preferences

    if(!formKey.currentState!.validate()){
      return;
    }

    Map credentials = {
      'email' : emailController.text,
      'password' : passwordController.text
    };


    var connectivity = await Connectivity().checkConnectivity();

    if(connectivity == ConnectivityResult.none) {
      showStatus(color: Colors.red, text: "No Internet Connection");
      return;
    }

    var response = await Api.instance.loginUser(credentials);  // Call API Method

    if(response.runtimeType != List<Object>){
      if(response.statusCode == 500){
        showStatus(color: Colors.red, text: response.body);
        return;
      }
    }

    if(response[1] != 200){
      showStatus(color: Colors.red, text: response[0].message);
      return;
    }

    preferences(response[0]);
  }

  preferences(ApiResponse response) async {

    final pref = await SharedPreferences.getInstance();
    pref.setString("token", response.data!['token']);
    pref.setString("user", convert.jsonEncode(response.data!['user']));
    pref.setBool("loggedIn", true);


    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(
          builder: (context) => const MainPage()
        ), (route) => false);
  }

  @override
  void dispose() {
    emailController;
    passwordController;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bg2.jpg', // Replace with your image asset path
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          Container(
            margin: const EdgeInsets.only(left: 50, right: 50),
            child: Center(
              child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/S1.png', height: 140, width: 200),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10, left: 5),
                          child: Row(
                            children: [
                              Text("LOG IN",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w200
                                ),
                              ),
                            ],
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white)
                                ),
                                prefixIcon: const Icon(Icons.email_rounded),
                                hintText: "Email"
                            ),
                            onChanged: (value) {
                              return value.isEmpty ?
                              "The Email field is required" : setState(() {
                                email = value;
                              });
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              hintText: "Password",
                            ),
                            onChanged: (value) {
                              return value.isEmpty ?
                              "The Password field is required" : setState(() {
                                password = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            width: size.width * 0.8,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: validate(email, password) ? () => login(context) : null,
                                child: const Text("LOG IN",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                  ),)),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.black), // Set the text color to black
                          ),
                          child: const Text("Sign Up for Scholapp"),
                        ),
                      ],
                    ),
                  )
              ),
            )
        )
        ]
      )
    );
  }
}