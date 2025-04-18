
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
