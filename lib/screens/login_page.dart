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

  Future<UserCredential?> signInWithGoogle() async {
    // 認証フローのトリガー
    final googleUser = await GoogleSignIn(scopes: [
      'email',
    ]).signIn();

    if (googleUser == null) {
      // ユーザーがGoogleサインインをキャンセルまたは失敗した場合
      return null;
    }

    // リクエストから、認証情報を取得
    final googleAuth = await googleUser.authentication;

    if (googleAuth == null) {
      return null;
    }

    // クレデンシャルを新しく作成
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
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
                    child: SignInButton(Buttons.Google,
                        text: "Sign up with Google", onPressed: () async {
                      // 現在のユーザーを確認
                      final currentUser = FirebaseAuth.instance.currentUser;

                      if (currentUser != null) {
                        // ログイン済みの場合、直接ホームページにリダイレクト
                        print('Already logged in. User ID: ${currentUser.uid}');
                        goRouter.go('/home');
                        return;
                      }

                      final userCredential = await signInWithGoogle();

                      if (userCredential != null &&
                          userCredential.user != null) {
                        print(
                            'Login Successful. User ID: ${userCredential.user!.uid}');
                        goRouter.go('/home');
                      } else {
                        print('Login Failed.');
                      }
                    }),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}