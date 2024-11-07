import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sp32_firebase/Dashboard.dart';
// import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDnekI_xLqvj9VvTAhbaPagUU-wsuu_Oe0",
            authDomain: "tkll-hk241.firebaseapp.com",
            databaseURL:
                "https://tkll-hk241-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "tkll-hk241",
            storageBucket: "tkll-hk241.firebasestorage.app",
            messagingSenderId: "572373084526",
            appId: "1:572373084526:web:b9e6214c245ad68cbe797f"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Temp & Humid App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 204, 255)),
        useMaterial3: true,
      ),
      home: const LoginScreen(title: 'ESP32 Temperature & Humidity App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

//Mới thêm vào

class LoginScreen extends StatefulWidget {
  final String title;

  const LoginScreen({super.key, required this.title});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
  );

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleFirebase();
      }
    });
    _googleSignIn.signInSilently(); //Auto login if previous login was success
  }

  void _handleFirebase() async {
    GoogleSignInAuthentication? googleAuth = await _currentUser?.authentication;

    // Kiểm tra token trước khi tiếp tục
    if (googleAuth?.idToken != null && googleAuth?.accessToken != null) {
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken,
      );

      try {
        // Đăng nhập Firebase với credential
        UserCredential userCredential =
            await firebaseAuth.signInWithCredential(credential);
        User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          print('Login successful');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Dashboard()));
        } else {
          print('Login failed');
        }
      } catch (error) {
        print('Error during sign-in: $error');
      }
    } else {
      print('Google Sign-In failed: No valid tokens found.');
    }
  }

  Future<void> _handleSignIn() async {
    try {
      // Gọi signIn để bắt đầu quá trình đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Nếu googleUser là null, tức là người dùng đã hủy đăng nhập
      if (googleUser == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đăng nhập bị hủy')));
        return; // Thoát hàm nếu người dùng không tiếp tục đăng nhập
      }

      // Lấy thông tin xác thực từ Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential để đăng nhập vào Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase với credential từ Google
      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      // Kiểm tra nếu đăng nhập thành công, chuyển sang màn hình Dashboard
      if (userCredential.user != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Dashboard()));
      }
    } catch (error) {
      // Hiển thị lỗi cho người dùng nếu xảy ra lỗi
      print('Lỗi khi đăng nhập: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 0, 204, 255),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: const Text('Google Sign in'),
        ),
      ),
    );
  }
}
