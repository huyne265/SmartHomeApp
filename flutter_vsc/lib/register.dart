import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!_validateEmail(email)) {
        throw 'Email không hợp lệ';
      }

      if (!_validatePassword(password)) {
        throw 'Mật khẩu phải có ít nhất 6 ký tự';
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => const LoginScreen(
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
        title: const Text(
          'Register Account',
          style: TextStyle(
            color: Color(0xFFc1e8ff),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF021024),
        iconTheme: const IconThemeData(
          color: Color(0xFFc1e8ff),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFc1e8ff),
              Color(0xFF7da0ca),
              Color(0xFF5483b3),
              Color(0xFF2b669c),
              Color(0xFF052659),
              Color(0xFF021024),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'images/res2.jpg',
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFc1e8ff),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFc1e8ff),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFc1e8ff),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFc1e8ff),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                obscureText: true,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF7da0ca),
                ),
                child: const Text('Resgister',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
