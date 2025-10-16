import 'package:flutter/material.dart';
import 'package:vocabsimple/src/components/dialog/MassageDialog.dart';
import 'package:vocabsimple/src/components/user/PageLogin.dart';
import 'package:vocabsimple/src/firebase/firebase_auth_service.dart';

class ProfileSetting extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin tài khoản')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user?.displayName ?? 'Tên người dùng',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'UID: ${user?.uid ?? 'Không có'}',
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 40,
              runSpacing: 30,
              children: [
                _buildIconLabel(Icons.cached, 'Cập nhật\nTài khoản'),
                _buildIconLabel(Icons.show_chart, 'Tiến trình học'),
                _buildIconLabel(Icons.settings, 'Thiết lập\nPhần mềm'),
                _buildIconLabel(Icons.support_agent, 'Liên hệ &\nHỗ trợ'),
                _buildIconLabel(Icons.lightbulb_outline, 'Góp ý'),
                _buildIconLabel(Icons.help_outline, 'Hướng dẫn\nTrợ giúp'),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () async {
                await _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PageLogin()),
                );
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 30),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
