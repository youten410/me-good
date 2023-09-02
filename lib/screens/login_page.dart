import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:me_good/router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    initialization();
    //ウィジェットが初期化された直後にログイン状態をチェック
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void initialization() async {
    print('wait...');
    await Future.delayed(const Duration(seconds: 5));
    print('Loading Done!');
    FlutterNativeSplash.remove();
  }

  // 認証
  final _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(scopes: [
      'email',
    ]).signIn();

    if (googleUser == null) {
      return null;
    }

    final googleAuth = await googleUser.authentication;

    if (googleAuth == null) {
      return null;
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      print(
          'Successfully logged in with Apple. User ID: ${userCredential.user!.uid}');
      goRouter.go('/home');
    } catch (error) {
      print('Error occurred during Apple Sign In: $error');
    }
  }

  void _checkLoginStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // ログイン済みの場合、直接ホームページにリダイレクト
      print('Already logged in. User ID: ${currentUser.uid}');
      goRouter.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[100]!,
                Colors.orange[300]!,
                Colors.orange[700]!,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'me good',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 50,
                  width: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: SignInButton(Buttons.AppleDark,
                        text: "Sign in with Apple", onPressed: () async {
                      signInWithApple();
                    }),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 50,
                  width: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: SignInButton(
                      Buttons.Google,
                      onPressed: () async {
                        signInWithGoogle();
                      },
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
