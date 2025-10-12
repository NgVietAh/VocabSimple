import 'package:flutter/material.dart';
import 'package:vocabsimple/src/blocs/auth_bloc.dart';
import 'package:vocabsimple/src/components/dialog/LoadingDialog.dart';
import 'package:vocabsimple/src/components/dialog/MassageDialog.dart';
import 'package:vocabsimple/src/components/user/PageRegister.dart';
import 'package:vocabsimple/src/components/user/ForgotPassword.dart';
import 'package:vocabsimple/src/components/homepage/home_screen.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final AuthBloc _authBloc = AuthBloc();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isShowPass = false;

  void _handleLogin() {
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();

    if (!_authBloc.isValidLogin(email, pass)) {
      MassageDialog.show(context, 'Lỗi', 'Email hoặc mật khẩu không hợp lệ');
      return;
    }

    LoadingDialog.showLoading(context, message: 'Đang đăng nhập...');
    _authBloc.signIn(
      email,
      pass,
      () {
        LoadingDialog.hideLoading(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
      (errMsg) {
        LoadingDialog.hideLoading(context);
        MassageDialog.show(context, 'Đăng nhập thất bại', errMsg);
      },
    );
  }

  void _handleGoogleLogin() {
    LoadingDialog.showLoading(context, message: 'Đang đăng nhập Google...');
    _authBloc.signInGoogle(
      () {
        LoadingDialog.hideLoading(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
      (errMsg) {
        LoadingDialog.hideLoading(context);
        MassageDialog.show(context, 'Google thất bại', errMsg);
      },
    );
  }

  void _handleFacebookLogin() {
    LoadingDialog.showLoading(context, message: 'Đang đăng nhập Facebook...');
    _authBloc.signInFacebook(
      () {
        LoadingDialog.hideLoading(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
      (errMsg) {
        LoadingDialog.hideLoading(context);
        MassageDialog.show(context, 'Facebook thất bại', errMsg);
      },
    );
  }

  @override
  void dispose() {
    _authBloc.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<String>(
              stream: _authBloc.emailStream,
              builder: (context, snapshot) => TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: snapshot.hasError ? snapshot.error.toString() : null,
                ),
                onChanged: _authBloc.emailChanged,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<String>(
              stream: _authBloc.passStream,
              builder: (context, snapshot) => TextField(
                controller: _passController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  errorText: snapshot.hasError ? snapshot.error.toString() : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isShowPass ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isShowPass = !_isShowPass),
                  ),
                ),
                obscureText: !_isShowPass,
                onChanged: _authBloc.passChanged,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Đăng nhập'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _handleGoogleLogin,
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập bằng Google'),
            ),
            ElevatedButton.icon(
              onPressed: _handleFacebookLogin,
              icon: const Icon(Icons.facebook),
              label: const Text('Đăng nhập bằng Facebook'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ForgotPassword()),
              ),
              child: const Text('Quên mật khẩu?'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PageRegister()),
              ),
              child: const Text('Tạo tài khoản mới'),
            ),
          ],
        ),
      ),
    );
  }
}
