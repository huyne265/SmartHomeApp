import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng ký tài khoản mới
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Kiểm tra tính hợp lệ của email và mật khẩu
      if (!_validateEmail(email)) {
        throw 'Email không hợp lệ';
      }

      if (!_validatePassword(password)) {
        throw 'Mật khẩu phải có ít nhất 6 ký tự';
      }

      // Thực hiện đăng ký
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể từ Firebase
      _handleAuthError(e);
      return null;
    } catch (e) {
      // Xử lý các lỗi khác
      print('Lỗi đăng ký: $e');
      return null;
    }
  }

  // Kiểm tra định dạng email
  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  // Kiểm tra độ mạnh mật khẩu
  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  // Xử lý lỗi xác thực
  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'weak-password':
        errorMessage = 'Mật khẩu quá yếu';
        break;
      case 'email-already-in-use':
        errorMessage = 'Email đã được đăng ký';
        break;
      case 'invalid-email':
        errorMessage = 'Địa chỉ email không hợp lệ';
        break;
      default:
        errorMessage = 'Đã xảy ra lỗi khi đăng ký';
    }

    // In ra console hoặc hiển thị thông báo lỗi
    print(errorMessage);
  }
}

// Ví dụ sử dụng trong Widget
class RegisterScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _register() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final result = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result != null) {
        // Đăng ký thành công, chuyển đến màn hình khác
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => LoginScreen(
                    title: 'ABCDEF',
                  )),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Account'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              child: Text('Resgister'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
