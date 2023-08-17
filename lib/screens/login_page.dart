import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:me_good/router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;

  // Googleを使ってサインイン
  Future<UserCredential> signInWithGoogle() async {
    // 認証フローのトリガー
    final googleUser = await GoogleSignIn(scopes: [
      'email',
    ]).signIn();
    // リクエストから、認証情報を取得
    final googleAuth = await googleUser?.authentication;
    // クレデンシャルを新しく作成
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    // サインインしたら、UserCredentialを返す
    return FirebaseAuth.instance.signInWithCredential(credential);
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
            child: Container(
              height: 50,
              width: 300,
              child: SignInButton(Buttons.Google, text: "Sign up with Google",
                  onPressed: () async {
                try {
                  final userCredential = await signInWithGoogle();
                  if (userCredential.user != null) {
                    print(
                        'Login Successful. User ID: ${userCredential.user!.uid}');

                    // 以下の行を修正
                    goRouter.go('/home');
                  } else {
                    print('Login Failed.');
                  }
                } on FirebaseAuthException catch (e) {
                  print('FirebaseAuthException');
                  print('${e.code}');
                } on Exception catch (e) {
                  print('Other Exception');
                  print('${e.toString()}');
                }
              }),
            ),
          )),
    );
  }
}
