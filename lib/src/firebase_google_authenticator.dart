import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:identity/identity.dart';
import 'package:sso/sso.dart';

class FirebaseGoogleAuthenticator
    with WillNotify, WillConvertUser
    implements Authenticator {
  final List<String> scopes;

  FirebaseGoogleAuthenticator({this.scopes = const ["email"]});

  @override
  WidgetBuilder get action => (context) => ActionButton(
      onPressed: () => authenticate(context),
      color: Colors.white,
      textColor: Colors.black.withOpacity(0.54),
      icon: Image.asset("images/google.png",
          package: "identity_firebase_google", width: 24, height: 24),
      text: "Sign in with Google");

  @override
  Future<void> authenticate(BuildContext context, [Map parameters]) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return Identity.of(context)
          .error('There was an error. Please try again.');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    notify(context, "Processing ...");
    return FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((result) => convert(result.user))
        .then((user) => Identity.of(context).user = user)
        .catchError(Identity.of(context).error);
  }
}
