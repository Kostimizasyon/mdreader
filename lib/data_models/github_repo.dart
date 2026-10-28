class GithubRepo {
  final String owner;
  final String name;
  final String defaultBranch;
  final bool isActive;
  final DateTime lastSyncedAt;

  const GithubRepo({
    required this.owner,
    required this.name,
    required this.defaultBranch,
    this.isActive = false,
    required this.lastSyncedAt,
  });

  String get fullName => '$owner/$name';

  String get cacheKey => '${owner}_$name';

  GithubRepo copyWith({
    String? owner,
    String? name,
    String? defaultBranch,
    bool? isActive,
    DateTime? lastSyncedAt,
  }) {
    return GithubRepo(
      owner: owner ?? this.owner,
      name: name ?? this.name,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      isActive: isActive ?? this.isActive,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner': owner,
      'name': name,
      'defaultBranch': defaultBranch,
      'isActive': isActive,
      'lastSyncedAt': lastSyncedAt.toIso8601String(),
    };
  }

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      owner: json['owner'] as String,
      name: json['name'] as String,
      defaultBranch: json['defaultBranch'] as String,
      isActive: json['isActive'] as bool? ?? false,
      lastSyncedAt: DateTime.parse(json['lastSyncedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GithubRepo &&
        other.owner.toLowerCase() == owner.toLowerCase() &&
        other.name.toLowerCase() == name.toLowerCase();
  }

  @override
  int get hashCode =>
      owner.toLowerCase().hashCode ^ name.toLowerCase().hashCode;
}