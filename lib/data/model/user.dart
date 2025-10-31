class User {
  /// Standard-Konstruktor.
  const User(
      {required this.id, required this.username, required this.displayName});

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory User.fromJson(final Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        displayName: json['displayName'],
      );

  final int id;

  final String username;

  final String displayName;

  /// Methode zur JSON‑Serialisierung.
  Map<String, dynamic> toJSON() =>
      {'id': id, 'username': username, 'displayName': displayName};
}
