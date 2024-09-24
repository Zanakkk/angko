class ScoreEntry {
  final String username;
  final DateTime timestamp;
  final int score;
  final int digitLength; // Panjang digit
  final int inputCount; // Jumlah input
  final int elapsedTime; // Waktu yang telah dihabiskan

  ScoreEntry({
    required this.username,
    required this.timestamp,
    required this.score,
    required this.digitLength,
    required this.inputCount,
    required this.elapsedTime,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'timestamp': timestamp.toIso8601String(),
        'score': score,
        'digitLength': digitLength,
        'inputCount': inputCount,
        'elapsedTime': elapsedTime,
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        username: json['username'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        score: json['score'] as int,
        digitLength: json['digitLength'] as int,
        inputCount: json['inputCount'] as int,
        elapsedTime: json['elapsedTime'] as int,
      );
}
