class TokenPair {
  final String jwtToken;
  final String refreshToken;

  TokenPair({
    required this.jwtToken,
    required this.refreshToken,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      jwtToken: json['jwtToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jwtToken': jwtToken,
      'refreshToken': refreshToken,
    };
  }
} 