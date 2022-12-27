import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthHelper {
  FirebaseAuthHelper._();
  static FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper._();

  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //TODO: logInAnonymously()
  Future<User?> logInAnonymously() async {
    UserCredential userCredential = await firebaseAuth.signInAnonymously();

    User? user = userCredential.user;
    return user;
  }

  //TODO: signUpUser()
  Future<User?> signUpUser(
      {required String email, required String password}) async {
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;
    return user;
  }

  //TODO: signInUser()
  Future<User?> signInUser(
      {required String email, required String password}) async {
    UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;
    return user;
  }

  //TODO: singInWithGoogle()
  Future<User?> singInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  }

  //TODO: singOutUser()
  singOutUser() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  Future<void> UpdateEmail({required String email}) async {
    User? user = firebaseAuth.currentUser;

    return await user!.updateEmail("$email");
  }

  Future<void> UpdateName({required String name}) async {
    User? user = firebaseAuth.currentUser;

    return await user!.updateDisplayName("$name");
  }

  Future<void> UpdatePassword({required String password}) async {
    User? user = firebaseAuth.currentUser;

    return await user!.updatePassword("$password");
  }

  Future<void> UpdatePhoto({required String photoURL}) async {
    User? user = firebaseAuth.currentUser;

    await user!.updatePhotoURL("$photoURL");
    // return await user!.updatePhotoURL(photo);
  }

  Future<User?> currentUser() async {
    User? user = firebaseAuth.currentUser;
    return await user;
  }
}
