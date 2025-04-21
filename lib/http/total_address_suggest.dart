import 'address_suggest.dart';

class TotalAddressSuggest {
  final List<AddressSuggest> results;

  TotalAddressSuggest({
    required this.results,
  });

  factory TotalAddressSuggest.fromJson(Map<String, dynamic> json) {
    return TotalAddressSuggest(
      results: (json['results'] as List)
          .map((e) => AddressSuggest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
} 