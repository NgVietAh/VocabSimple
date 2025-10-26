import 'package:flutter/material.dart';
import 'package:vocabsimple/src/blocs/auth_bloc.dart';
import 'package:vocabsimple/src/components/dialog/LoadingDialog.dart';
import 'package:vocabsimple/src/components/dialog/MassageDialog.dart';
import 'package:vocabsimple/src/firebase/firebase_auth_service.dart';
import 'package:vocabsimple/src/validators/Validations.dart';

class PageRegister extends StatefulWidget {
  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  final AuthBloc _authBloc = AuthBloc();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isShowPass = false;

  void _handleRegister() {
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    final confirm = _confirmController.text.trim();

    if (!Validations.isValidEmail(email)) {
      MassageDialog.show(context, 'Lỗi', 'Email không hợp lệ');
      return;
    }

    if (!Validations.isValidPassword(pass)) {
      MassageDialog.show(context, 'Lỗi', 'Mật khẩu phải từ 6 ký tự');
      return;
    }

    if (!Validations.isPasswordConfirmed(pass, confirm)) {
      MassageDialog.show(context, 'Lỗi', 'Mật khẩu xác nhận không khớp');
      return;
    }

    LoadingDialog.showLoading(context, message: 'Đang tạo tài khoản...');
    FirebaseAuthService().signUp(email, pass).then((user) {
      LoadingDialog.hideLoading(context);
      if (user != null) {
        MassageDialog.show(context, 'Thành công', 'Tài khoản đã được tạo');
        Navigator.pop(context);
      } else {
        MassageDialog.show(context, 'Lỗi', 'Không thể tạo tài khoản');
      }
    }).catchError((e) {
      LoadingDialog.hideLoading(context);
      MassageDialog.show(context, 'Lỗi', e.toString());
    });
  }

  @override
  void dispose() {
    _authBloc.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isShowPass ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _isShowPass = !_isShowPass),
                ),
              ),
              obscureText: !_isShowPass,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu'),
              obscureText: !_isShowPass,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleRegister,
              child: const Text('Tạo tài khoản'),
            ),
          ],
        ),
      ),
    );
  }
}
