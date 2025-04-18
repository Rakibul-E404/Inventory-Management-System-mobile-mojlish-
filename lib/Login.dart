//
// import 'package:flutter/material.dart';
// import '../Dashboard/Dashboard.dart';
// class User {
//   final String username;
//   final String password;
//   final String role;
//   User({required this.username, required this.password, required this.role});
// }
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final List<User> users = [
//     User(username: 'admin', password: 'admin123', role: 'admin'),
//     User(username: 'moderator', password: 'moderator123', role: 'moderator'),
//   ];
//   void handleLogin(String username, String password) {
//     User? _loggedInUser = _login(username, password);
//     if (_loggedInUser != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => Dashboard(role: _loggedInUser.role, stockItems: [],)),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error'),
//             content: const Text('Invalid username or password.'),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   User? _login(String username, String password) {
//     for (User user in users) {
//       if (user.username == username && user.password == password) {
//         return user;
//       }
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(
//                 labelText: 'Username',
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: () {
//                 handleLogin(_usernameController.text, _passwordController.text);
//               },
//               child: const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//ok

///===================================
///
///
///
/// ------------------------------------Upper code is correct,,,
///
///
///
/// ===================================
///
///




// LoginPage.dart
import 'package:flutter/material.dart';
import 'DashBoard.dart';
import 'userModel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void handleLogin(String username, String password) {
    User? _loggedInUser = _login(username, password);
    if (_loggedInUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(
            role: _loggedInUser.role,
            stockItems: [],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid username or password.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  User? _login(String username, String password) {
    for (User user in users) {
      if (user.username == username && user.password == password) {
        return user;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                handleLogin(_usernameController.text, _passwordController.text);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

