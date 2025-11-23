import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/analysis_data.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, bool> selectedOptions;
  final VoidCallback onNewAnalysis;

  ResultScreen({required this.selectedOptions, required this.onNewAnalysis});

  // Method to capitalize the first letter of each word
  String capitalize(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // Method to get detailed analysis points
  // Method to get detailed analysis points
  // Method to get detailed analysis points
  Map<String, Map<String, Map<String, List<String>>>>
      getDetailedAnalysisPoints() {
    Map<String, Map<String, Map<String, List<String>>>> detailedPoints = {
      'Macro Analysis': {},
      'Micro Analysis': {},
      'Areas to Improve': {},
    };

    selectedOptions.forEach((key, value) {
      if (value) {
        final parts = key.split(' > ');
        final category = parts[0];

        if (parts.length == 3) {
          // Handling for Macro and Micro Analysis
          final subCategory = parts[1];
          final trait = parts[2];

          if (values.containsKey(trait)) {
            detailedPoints[category]?.putIfAbsent(subCategory, () => {});
            detailedPoints[category]?[subCategory]!
                .putIfAbsent(trait, () => []);
            detailedPoints[category]?[subCategory]![trait]!
                .addAll(values[trait]!);
          }
        } else if (parts.length == 2 && category == "Areas to Improve") {
          // Handling for Areas to Improve (without a sub-category)
          final trait = parts[1];

          if (values.containsKey(trait)) {
            detailedPoints[category]?.putIfAbsent("", () => {});
            detailedPoints[category]?[""]!.putIfAbsent(trait, () => []);
            detailedPoints[category]?[""]![trait]!.addAll(values[trait]!);
          }
        }
      }
    });

    // Remove empty sub-categories so no extra space is left
    detailedPoints.forEach((category, subCategories) {
      subCategories.removeWhere((key, traits) => key.isEmpty && traits.isEmpty);
    });
    detailedPoints.removeWhere((_, subCategories) => subCategories.isEmpty);

    return detailedPoints;
  }

  // Format points with proper indentation
  String formatPoints(String point) {
    return point.replaceAll('\n', '\n    '); // Indent each new line
  }

  // Format detailed points for display
  String formatDetailedPoints(
      Map<String, Map<String, Map<String, List<String>>>> points) {
    StringBuffer buffer = StringBuffer();

    buffer.writeln("PERSONALITY");
    buffer.writeln("TRAITS IN METAPHORS\n");

    points.forEach((category, subCategories) {
      buffer.writeln("${capitalize(category)}:\n");

      subCategories.forEach((subCategory, traits) {
        buffer.writeln("${capitalize(subCategory)}:");

        traits.forEach((trait, points) {
          buffer.writeln("• ${capitalize(trait)}:");
          for (var point in points) {
            buffer.writeln("    - ${formatPoints(point)}");
          }
        });

        buffer.writeln(); // Add spacing between subcategories
      });
    });

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final detailedPoints = getDetailedAnalysisPoints();
    final formattedText = formatDetailedPoints(detailedPoints);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Results'),
      ),
      body: detailedPoints.isEmpty
          ? Center(
              child: Text(
                'No options selected.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Analysis:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: detailedPoints.entries.map((categoryEntry) {
                        final category = categoryEntry.key;
                        final subCategories = categoryEntry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capitalize(category),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ...subCategories.entries.map((subEntry) {
                              final subCategory = subEntry.key;
                              final traits = subEntry.value;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      capitalize(subCategory),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    ...traits.entries.map((traitEntry) {
                                      final trait = traitEntry.key;
                                      final points = traitEntry.value;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "    • ${capitalize(trait)}:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            ...points
                                                .map((point) => Text(
                                                    "       - ${formatPoints(point)}"))
                                                .toList(),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: formattedText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Copied to clipboard!')),
                          );
                        },
                        child: Text('Copy All'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Edit'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onNewAnalysis();
                        },
                        child: Text('New Analysis'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
