
// class LoginScreen extends StatefulWidget {
//   final String title;

//   LoginScreen({Key key, this.title}) : super(key: key);

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//   GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: <String>['email'],
//   );

//   GoogleSignInAccount _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//       setState(() {
//         _currentUser = account;
//       });

//       if (_currentUser != null) {
//         _handleFirebase();
//       }
//     });

//     _googleSignIn.signInSilently(); //Auto login if previous login was success
//   }

//   void _handleFirebase() async {
//     GoogleSignInAuthentication googleAuth = await _currentUser.authentication;

//     final AuthCredential credential = GoogleAuthProvider.getCredential(
//         idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

//     final FirebaseUser firebaseUser =
//         await firebaseAuth.signInWithCredential(credential);

//     if (firebaseUser != null) {
//       print('Login');

//       Navigator.of(context).pushReplacement(
//           new MaterialPageRoute(builder: (context) => new Dashboard()));
//     }
//   }

//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//     } catch (error) {
//       print(error);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: FlatButton(
//           onPressed: _handleSignIn,
//           child: Text('Google Sign in'),
//           color: Colors.amber,
//         ),
//       ),
//     );
//   }
// }
