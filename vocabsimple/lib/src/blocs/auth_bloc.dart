import 'dart:async';
import 'package:vocabsimple/src/validators/validations.dart';
import 'package:vocabsimple/src/firebase/firebase_auth_service.dart';

class AuthBloc {
  final _emailController = StreamController<String>.broadcast();
  final _passController = StreamController<String>.broadcast();

  Stream<String> get emailStream => _emailController.stream;
  Stream<String> get passStream => _passController.stream;

  void emailChanged(String email) {
    if (!Validations.isValidEmail(email)) {
      _emailController.sink.addError('Email không hợp lệ');
    } else {
      _emailController.sink.add(email);
    }
  }

  void passChanged(String pass) {
    if (!Validations.isValidPassword(pass)) {
      _passController.sink.addError('Mật khẩu phải từ 6 ký tự');
    } else {
      _passController.sink.add(pass);
    }
  }

  bool isValidLogin(String email, String pass) {
    return Validations.isValidEmail(email) && Validations.isValidPassword(pass);
  }

  void signIn(String email, String pass, Function onSuccess, Function(String) onError) {
    FirebaseAuthService().signIn(email, pass).then((user) {
      if (user != null) {
        onSuccess();
      } else {
        onError('Đăng nhập thất bại');
      }
    }).catchError((e) {
      onError(e.toString());
    });
  }

  void signInGoogle(Function onSuccess, Function(String) onError) {
    FirebaseAuthService().signInGoogle().then((user) {
      if (user != null) {
        onSuccess();
      } else {
        onError('Đăng nhập Google thất bại');
      }
    }).catchError((e) {
      onError(e.toString());
    });
  }

  void signInFacebook(Function onSuccess, Function(String) onError) {
    FirebaseAuthService().signInFacebook().then((user) {
      if (user != null) {
        onSuccess();
      } else {
        onError('Đăng nhập Facebook thất bại');
      }
    }).catchError((e) {
      onError(e.toString());
    });
  }

  void dispose() {
    _emailController.close();
    _passController.close();
  }
}
