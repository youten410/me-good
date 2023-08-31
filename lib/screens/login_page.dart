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

  void _checkLoginStatus() async {
    // 現在のユーザーを確認
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: SignInButton(Buttons.Google,
                        text: "Login with Google", onPressed: () async {
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
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: SignInButton(
                      Buttons.Apple,
                      onPressed: () async {
                        final credential =
                            await SignInWithApple.getAppleIDCredential(
                          scopes: [
                            AppleIDAuthorizationScopes.email,
                            AppleIDAuthorizationScopes.fullName,
                          ],
                        );

                        print(credential);

                        // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                        // after they have been validated with Apple (see `Integration` section for more information on how to do this)
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
