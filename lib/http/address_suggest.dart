class AddressSuggest {
  final String title;
  final String subtitle;
  final double lat;
  final double lon;

  AddressSuggest({
    required this.title,
    required this.subtitle,
    required this.lat,
    required this.lon,
  });

  factory AddressSuggest.fromJson(Map<String, dynamic> json) {
    return AddressSuggest(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'lat': lat,
      'lon': lon,
    };
  }
} 