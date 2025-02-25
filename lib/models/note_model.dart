class NoteModel {
  final int? id; // Local database ID
  final String? firebaseId; // Firebase ID for cloud sync
  final String title;
  final String content;
  final List<String> tags;
  final int lastUpdated;
  final String userId;

  NoteModel({
    this.id,
    this.firebaseId,
    required this.title,
    required this.content,
    this.tags = const [],
    required this.lastUpdated,
    required this.userId,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      firebaseId: json['firebaseId'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      lastUpdated: json['lastUpdated'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'title': title,
      'content': content,
      'tags': tags,
      'lastUpdated': lastUpdated,
      'userId': userId,
    };
  }

  // For SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags.join(','),
      'last_updated': lastUpdated,
      'user_id': userId,
      'firebase_id': firebaseId,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      firebaseId: map['firebase_id'],
      title: map['title'],
      content: map['content'],
      tags: map['tags']?.split(',').where((tag) => tag.isNotEmpty).toList() ?? [],
      lastUpdated: map['last_updated'],
      userId: map['user_id'],
    );
  }

  NoteModel copyWith({
    int? id,
    String? firebaseId,
    String? title,
    String? content,
    List<String>? tags,
    int? lastUpdated,
    String? userId,
  }) {
    return NoteModel(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userId: userId ?? this.userId,
    );
  }
} 