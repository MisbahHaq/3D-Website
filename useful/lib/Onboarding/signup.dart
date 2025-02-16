import 'package:flutter/material.dart';
import 'package:useful/Services/database.dart';
import 'package:useful/Services/shared_pref.dart';
import 'package:useful/Stripe/detail_page.dart' as FirebaseAuth;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mailController = TextEditingController();

  // Register user function
  registration() async {
    // Ensure that all fields are not empty
    if (passwordController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        mailController.text.isNotEmpty) {
      try {
        // Register user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: mailController.text,
              password: passwordController.text,
            );

        print("Registration successful: ${userCredential.user?.email}");

        // Use the Firebase UID instead of a random ID
        String id = userCredential.user?.uid ?? '';

        Map<String, dynamic> userInfoMap = {
          "Name": nameController.text,
          "Email": mailController.text,
          "Id": id, // Use the UID from FirebaseAuth
          "Image":
              "https://example.com/default_image.png", // Replace with your image URL
        };

        // Save user details to SharedPreferences
        await SharedpreferencesHelper().saveUserDisplayName(
          nameController.text,
        );
        await SharedpreferencesHelper().saveUserEmail(mailController.text);
        await SharedpreferencesHelper().saveUserId(id);
        await SharedpreferencesHelper().saveUserImage(
          "https://example.com/default_image.png",
        );

        // Add user details to Firestore
        await DatabaseMethods().addUserDetails(userInfoMap, id);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registered Successfully!",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        );

        // Navigate to the BottomNav screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
      } on FirebaseAuthException catch (e) {
        // Handle Firebase Authentication errors
        print("Firebase Error Code: ${e.code}");
        print("Firebase Error Message: ${e.message}");
        handleFirebaseError(e); // Handle different error codes
      } catch (e) {
        // Handle general errors
        print("General Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("An unexpected error occurred: $e"),
          ),
        );
      }
    } else {
      // Show error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please fill in all fields"),
        ),
      );
    }
  }

  // Handle Firebase errors
  handleFirebaseError(FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Password Provided is too weak",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    } else if (e.code == "email-already-in-use") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text("Account Already exists"),
        ),
      );
    } else if (e.code == 'invalid-email') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Invalid email format"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Registration failed: ${e.message}"),
        ),
      );
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
                      "Sign Up",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Name",
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(157, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter Name",
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(219, 255, 255, 255),
                        ),
                        suffixIcon: Icon(
                          Icons.person_2_rounded,
                          color: Colors.white,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color(0xff6b63ff),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Email",
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(157, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: mailController,
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(219, 255, 255, 255),
                        ),
                        suffixIcon: Icon(
                          Icons.email_rounded,
                          color: Colors.white,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color(0xff6b63ff),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Password",
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(157, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(219, 255, 255, 255),
                        ),
                        suffixIcon: Icon(
                          Icons.password_rounded,
                          color: Colors.white,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color(0xff6b63ff),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Confirm Password",
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(157, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(219, 255, 255, 255),
                        ),
                        suffixIcon: Icon(
                          Icons.password_rounded,
                          color: Colors.white,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color(0xff6b63ff),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (nameController.text != "" &&
                                mailController.text != "" &&
                                passwordController.text != "") {
                              print("Sign Up button clicked!");
                              setState(() {
                                name = nameController.text;
                                email = mailController.text;
                                password = passwordController.text;
                              });
                              registration(); // Call the registration function
                            } else {
                              print("Please fill all fields");
                            }
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
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.poppins(
                            color: const Color.fromARGB(157, 255, 255, 255),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
