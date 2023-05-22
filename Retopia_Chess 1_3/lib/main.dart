import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chess_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MaterialApp(home: LoginScreen()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: '그냥 체스',
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          color: Colors.black,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Just Chess'),
        ),
        body: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 55.0),
              child: ChessBoard(),
            ),
            Expanded(
              child: SizedBox(),
            ),
            SizedBox(width: 55.0),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  LoginScreen({Key? key}) : super(key: key);

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);
        final User? currentUser = _auth.currentUser;
        assert(user.uid == currentUser!.uid);

        return user;
      }
    } catch (e) {
      print('Error occurred using Google Sign-In: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Google Sign In'),
          onPressed: () {
            signInWithGoogle().then((User? user) {
              print(user);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return MyApp();
                  },
                ),
              );
            });
          },
        ),
      ),
    );
  }
}





