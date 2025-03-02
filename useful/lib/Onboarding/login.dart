import 'package:cineflix/Constants/bottomnav.dart';
import 'package:cineflix/Onbaording/signup.dart';
import 'package:cineflix/Services/database.dart';
import 'package:cineflix/Services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "", myname = "", myid = "", myimage = "";
  TextEditingController passwordController = TextEditingController();
  TextEditingController mailController = TextEditingController();

  // Method to handle user login
  userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserbyemail(email);
      myname = "${querySnapshot.docs[0]["Name"]}";
      myid = "${querySnapshot.docs[0]["Id"]}";
      myimage = "${querySnapshot.docs[0]["Image"]}";

      await SharedpreferencesHelper().saveUserImage(myimage);
      await SharedpreferencesHelper().saveUserId(myid);
      await SharedpreferencesHelper().saveUserEmail(email);
      await SharedpreferencesHelper().saveUserDisplayName(myname);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
      // If login is successful, navigate to BottomNav or wherever appropriate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No user found for that Email",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Wrong Password",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff14141d),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/images/signin.png"),
              Padding(
                padding: const EdgeInsets.only(left: 35, top: 20, right: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome!",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Login",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 90),
                    Text(
                      "Email",
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(157, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: mailController,
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        hintStyle: TextStyle(
                            color: Color.fromARGB(219, 255, 255, 255)),
                        suffixIcon:
                            Icon(Icons.email_rounded, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color(0xff6b63ff),
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Password",
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(157, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle: TextStyle(
                            color: Color.fromARGB(219, 255, 255, 255)),
                        suffixIcon:
                            Icon(Icons.password_rounded, color: Colors.white),
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color(0xff6b63ff),
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            color: Color(0xff6b63ff),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xff6b63ff),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (mailController.text != "" &&
                                passwordController.text != "") {
                              setState(() {
                                email = mailController.text;
                                password = passwordController.text;
                              });
                            }
                            userLogin(); // Call the login function
                          },
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  color: Color(0xff6b63ff),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
