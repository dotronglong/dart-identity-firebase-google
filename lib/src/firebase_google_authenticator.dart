import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:identity/identity.dart';
import 'package:identity_firebase/identity_firebase.dart';
import 'package:sso/sso.dart';

class FirebaseGoogleAuthenticator implements Authenticator {
  @override
  WidgetBuilder get action => (context) => ActionButton(
      onPressed: () => authenticate(context),
      color: Color.fromRGBO(234, 67, 53, 1),
      textColor: Colors.white,
      icon: Image.asset("images/google.png",
          package: "identity_firebase_google", width: 24, height: 24),
      text: "Sign In with Google");

  @override
  Future<void> authenticate(BuildContext context, [Map parameters]) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return Identity.of(context)
          .error(Exception('There was an error. Please try again.'));
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((result) => FirebaseProvider.convert(result.user))
        .catchError(Identity.of(context).error);
  }
}