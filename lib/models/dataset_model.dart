class DatasetItemModel {
  final int? id;
  final String content;
  final int position;
  final bool disabled;

  DatasetItemModel({
    this.id,
    required this.content,
    required this.position,
    this.disabled = false,
  });

  factory DatasetItemModel.fromJson(Map<String, dynamic> json) {
    return DatasetItemModel(
      id: json['id'],
      content: json['content'],
      position: json['position'],
      disabled: json['disabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'position': position,
      'disabled': disabled,
    };
  }

  DatasetItemModel copyWith({
    int? id,
    String? content,
    int? position,
    bool? disabled,
  }) {
    return DatasetItemModel(
      id: id ?? this.id,
      content: content ?? this.content,
      position: position ?? this.position,
      disabled: disabled ?? this.disabled,
    );
  }
}

class DatasetModel {
  final int? id; // Local database ID
  final String? firebaseId; // Firebase ID for cloud sync
  final String title;
  final String content;
  final List<String> tags;
  final int lastUpdated;
  final String userId;
  final List<DatasetItemModel> items;
  final String prefix;
  final String suffix;

  DatasetModel({
    this.id,
    this.firebaseId,
    required this.title,
    required this.content,
    this.tags = const [],
    required this.lastUpdated,
    required this.userId,
    this.items = const [],
    this.prefix = '',
    this.suffix = '',
  });

  factory DatasetModel.fromJson(Map<String, dynamic> json) {
    return DatasetModel(
      id: json['id'],
      firebaseId: json['firebaseId'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      lastUpdated: json['lastUpdated'],
      userId: json['userId'],
      items: json['items'] != null
          ? List<DatasetItemModel>.from(
              json['items'].map((x) => DatasetItemModel.fromJson(x)))
          : [],
      prefix: json['prefix'] ?? '',
      suffix: json['suffix'] ?? '',
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
      'items': items.map((item) => item.toJson()).toList(),
      'prefix': prefix,
      'suffix': suffix,
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
      'prefix': prefix,
      'suffix': suffix,
      // Items will be stored separately in their own table
    };
  }

  factory DatasetModel.fromMap(Map<String, dynamic> map) {
    return DatasetModel(
      id: map['id'],
      firebaseId: map['firebase_id'],
      title: map['title'],
      content: map['content'],
      tags: map['tags']?.split(',').where((tag) => tag.isNotEmpty).toList() ?? [],
      lastUpdated: map['last_updated'],
      userId: map['user_id'],
      prefix: map['prefix'] ?? '',
      suffix: map['suffix'] ?? '',
      // Items will be loaded separately
    );
  }

  DatasetModel copyWith({
    int? id,
    String? firebaseId,
    String? title,
    String? content,
    List<String>? tags,
    int? lastUpdated,
    String? userId,
    List<DatasetItemModel>? items,
    String? prefix,
    String? suffix,
  }) {
    return DatasetModel(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
    );
  }
} 