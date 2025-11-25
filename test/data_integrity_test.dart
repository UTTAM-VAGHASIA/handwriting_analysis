import 'package:handwriting_analysis/models/analysis_data.dart';

void main() {
  List<String> missingKeys = [];

  void checkKeys(dynamic data) {
    if (data is Map) {
      data.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            if (item is String && !values.containsKey(item)) {
              missingKeys.add(item);
            }
          }
        } else {
          checkKeys(value);
        }
      });
    } else if (data is List) {
      for (var item in data) {
        if (item is String && !values.containsKey(item)) {
          missingKeys.add(item);
        }
      }
    }
  }

  checkKeys(macroAnalysis);
  checkKeys(microAnalysis);
  checkKeys(areasToImprove);

  if (missingKeys.isNotEmpty) {
    print('Found ${missingKeys.length} missing keys in values map:');
    for (var key in missingKeys) {
      print('- "$key"');
    }
  } else {
    print('All keys are present in values map.');
  }
}
