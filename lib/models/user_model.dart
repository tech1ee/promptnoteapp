class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool isPremium;
  final int promptsUsedToday;
  final int lastPromptResetDate;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.isPremium = false,
    this.promptsUsedToday = 0,
    this.lastPromptResetDate = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      isPremium: json['isPremium'] ?? false,
      promptsUsedToday: json['promptsUsedToday'] ?? 0,
      lastPromptResetDate: json['lastPromptResetDate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isPremium': isPremium,
      'promptsUsedToday': promptsUsedToday,
      'lastPromptResetDate': lastPromptResetDate,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isPremium,
    int? promptsUsedToday,
    int? lastPromptResetDate,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isPremium: isPremium ?? this.isPremium,
      promptsUsedToday: promptsUsedToday ?? this.promptsUsedToday,
      lastPromptResetDate: lastPromptResetDate ?? this.lastPromptResetDate,
    );
  }
} 