// class User {
//   final String username;
//   final String password;
//   final String role;
//
//   User({required this.username, required this.password, required this.role});
// }
//
// final List<User> users = [
//   // User(username: 'admin', password: 'admin123', role: 'admin'),
//   // User(username: 'moderator', password: 'mod123', role: 'moderator'),
//   User(username: 'a', password: 'a1', role: 'admin'),
//   User(username: 'm', password: 'm1', role: 'moderator'),
// ];


///
///
///
///
///
// userModel.dart
class User {
  final String username;
  final String password;
  final String role;

  User({required this.username, required this.password, required this.role});
}

List<User> users = [
  User(username: 'admin', password: 'admin123', role: 'admin'),
  User(username: 'moderator', password: 'moderator123', role: 'moderator'),
];
