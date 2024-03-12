import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymtrack/colors/colors.dart';
import 'package:gymtrack/models/user_model.dart';
import 'package:gymtrack/screens/home.dart';
import 'package:gymtrack/services/api_services.dart';
import 'package:gymtrack/widgets/custom_route.dart';
import 'package:gymtrack/widgets/svg_icon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<bool> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      print(googleUser);

      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);

      print(googleAuth.idToken);

      //TODO:call backend, /auth

      final resp = await ApiService().login(googleAuth.idToken ?? "");
      print(resp);
      if (resp != null) {
        UserModel user = resp;
        print(user.email);
        return true;
      }
      return false;
    } catch (error) {
      //TODO:handle
      print(error);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: MyColors().primary),
      ),
      backgroundColor: MyColors().primary,
      body: Center(
        child: Container(
          height: 52,
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
              color: MyColors().textColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                bool res = await signInWithGoogle();
                if (res) {
                  Navigator.pushAndRemoveUntil(context,
                      CustomPageRoute(child: HomeScreen()), (route) => false);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgIcon(
                      "assets/icons/google.svg",
                      size: 36,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Continue With Google",
                      style: TextStyle(
                        color: MyColors().primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
