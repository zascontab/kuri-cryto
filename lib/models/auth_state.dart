/// Authentication state model for MATP integration
class AuthState {
  final bool isAuthenticated;
  final String? jwtToken;
  final String? refreshToken;
  final int userLevel;
  final DateTime? tokenExpiry;
  final UserInfo? userInfo;

  const AuthState({
    required this.isAuthenticated,
    this.jwtToken,
    this.refreshToken,
    required this.userLevel,
    this.tokenExpiry,
    this.userInfo,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      userLevel: 1,
    );
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      isAuthenticated: json['isAuthenticated'] ?? false,
      jwtToken: json['jwtToken'],
      refreshToken: json['refreshToken'],
      userLevel: json['userLevel'] ?? 1,
      tokenExpiry: json['tokenExpiry'] != null
          ? DateTime.parse(json['tokenExpiry'])
          : null,
      userInfo:
          json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAuthenticated': isAuthenticated,
      'jwtToken': jwtToken,
      'refreshToken': refreshToken,
      'userLevel': userLevel,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'userInfo': userInfo?.toJson(),
    };
  }

  AuthState copyWith({
    bool? isAuthenticated,
    String? jwtToken,
    String? refreshToken,
    int? userLevel,
    DateTime? tokenExpiry,
    UserInfo? userInfo,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      jwtToken: jwtToken ?? this.jwtToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userLevel: userLevel ?? this.userLevel,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  /// Check if token is expired
  bool get isTokenExpired {
    if (tokenExpiry == null) return false;
    return DateTime.now().isAfter(tokenExpiry!);
  }

  /// Check if user has required access level
  bool hasAccessLevel(int requiredLevel) {
    return userLevel >= requiredLevel;
  }

  /// Check if authentication is valid (authenticated and not expired)
  bool get isValidAuth {
    return isAuthenticated && !isTokenExpired && jwtToken != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.jwtToken == jwtToken &&
        other.refreshToken == refreshToken &&
        other.userLevel == userLevel &&
        other.tokenExpiry == tokenExpiry &&
        other.userInfo == userInfo;
  }

  @override
  int get hashCode {
    return Object.hash(
      isAuthenticated,
      jwtToken,
      refreshToken,
      userLevel,
      tokenExpiry,
      userInfo,
    );
  }

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, userLevel: $userLevel, tokenExpiry: $tokenExpiry)';
  }
}

/// User information model for MATP integration
class UserInfo {
  final String id;
  final String phone;
  final int level;
  final String tenantId;
  final String companyId;
  final List<String> featuresEnabled;
  final Map<String, int> limits;

  const UserInfo({
    required this.id,
    required this.phone,
    required this.level,
    required this.tenantId,
    required this.companyId,
    required this.featuresEnabled,
    required this.limits,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      level: json['level'] ?? 1,
      tenantId: json['tenantId'] ?? '',
      companyId: json['companyId'] ?? '',
      featuresEnabled: List<String>.from(json['featuresEnabled'] ?? []),
      limits: Map<String, int>.from(json['limits'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'level': level,
      'tenantId': tenantId,
      'companyId': companyId,
      'featuresEnabled': featuresEnabled,
      'limits': limits,
    };
  }

  UserInfo copyWith({
    String? id,
    String? phone,
    int? level,
    String? tenantId,
    String? companyId,
    List<String>? featuresEnabled,
    Map<String, int>? limits,
  }) {
    return UserInfo(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      level: level ?? this.level,
      tenantId: tenantId ?? this.tenantId,
      companyId: companyId ?? this.companyId,
      featuresEnabled: featuresEnabled ?? this.featuresEnabled,
      limits: limits ?? this.limits,
    );
  }

  /// Check if user has specific feature enabled
  bool hasFeature(String feature) {
    return featuresEnabled.contains(feature);
  }

  /// Get limit for specific resource
  int getLimit(String resource) {
    return limits[resource] ?? 0;
  }

  /// Check if user has reached limit for resource
  bool hasReachedLimit(String resource, int currentUsage) {
    final limit = getLimit(resource);
    return limit > 0 && currentUsage >= limit;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo &&
        other.id == id &&
        other.phone == phone &&
        other.level == level &&
        other.tenantId == tenantId &&
        other.companyId == companyId &&
        other.featuresEnabled.length == featuresEnabled.length &&
        other.featuresEnabled
            .every((element) => featuresEnabled.contains(element)) &&
        other.limits.length == limits.length &&
        other.limits.entries.every((entry) => limits[entry.key] == entry.value);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      phone,
      level,
      tenantId,
      companyId,
      Object.hashAll(featuresEnabled),
      Object.hashAll(limits.entries),
    );
  }

  @override
  String toString() {
    return 'UserInfo(id: $id, phone: $phone, level: $level)';
  }
}
