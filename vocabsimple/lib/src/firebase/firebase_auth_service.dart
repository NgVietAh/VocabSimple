import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Đăng nhập bằng email và mật khẩu
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw 'Đăng nhập thất bại: ${e.toString()}';
    }
  }

  /// Đăng ký tài khoản mới
  Future<User?> signUp(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw 'Đăng ký thất bại: ${e.toString()}';
    }
  }

  /// Gửi email khôi phục mật khẩu
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Không thể gửi email khôi phục: ${e.toString()}';
    }
  }

  /// Đăng nhập bằng Google
  Future<User?> signInGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      throw 'Đăng nhập Google thất bại: ${e.toString()}';
    }
  }

  /// Đăng nhập bằng Facebook
  Future<User?> signInFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        final userCredential =
            await _auth.signInWithCredential(facebookAuthCredential);

        return userCredential.user;
      } else {
        throw 'Đăng nhập Facebook thất bại: ${result.message}';
      }
    } catch (e) {
      throw 'Lỗi Facebook: ${e.toString()}';
    }
  }

  /// Đăng xuất khỏi tất cả tài khoản
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}
