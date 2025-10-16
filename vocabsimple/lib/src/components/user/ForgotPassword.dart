import 'package:flutter/material.dart';
import 'package:vocabsimple/src/components/dialog/LoadingDialog.dart';
import 'package:vocabsimple/src/components/dialog/MassageDialog.dart';
import 'package:vocabsimple/src/firebase/firebase_auth_service.dart';
import 'package:vocabsimple/src/validators/Validations.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  void _handleResetPassword() {
    final email = _emailController.text.trim();

    if (!Validations.isValidEmail(email)) {
      MassageDialog.show(context, 'Lỗi', 'Email không hợp lệ');
      return;
    }

    LoadingDialog.showLoading(context, message: 'Đang gửi yêu cầu...');
    FirebaseAuthService().forgotPassword(email).then((_) {
      LoadingDialog.hideLoading(context);
      MassageDialog.show(context, 'Thành công', 'Email khôi phục đã được gửi');
      Navigator.pop(context);
    }).catchError((e) {
      LoadingDialog.hideLoading(context);
      MassageDialog.show(context, 'Lỗi', e.toString());
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleResetPassword,
              child: const Text('Gửi yêu cầu khôi phục'),
            ),
          ],
        ),
      ),
    );
  }
}
