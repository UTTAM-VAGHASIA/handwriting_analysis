import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/analysis_data.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, bool> selectedOptions;
  final VoidCallback onNewAnalysis;
  final VoidCallback? onThemeChanged;

  const ResultScreen({
    super.key,
    required this.selectedOptions,
    required this.onNewAnalysis,
    this.onThemeChanged,
  });

  String capitalize(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

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
          final trait = parts[1];

          if (values.containsKey(trait)) {
            detailedPoints[category]?.putIfAbsent("", () => {});
            detailedPoints[category]?[""]!.putIfAbsent(trait, () => []);
            detailedPoints[category]?[""]![trait]!.addAll(values[trait]!);
          }
        }
      }
    });

    detailedPoints.forEach((category, subCategories) {
      subCategories.removeWhere((key, traits) => key.isEmpty && traits.isEmpty);
    });
    detailedPoints.removeWhere((_, subCategories) => subCategories.isEmpty);

    return detailedPoints;
  }

  String formatPoints(String point) {
    return point.replaceAll('\n', '\n    ');
  }

  String formatDetailedPoints(
      Map<String, Map<String, Map<String, List<String>>>> points) {
    StringBuffer buffer = StringBuffer();

    buffer.writeln("PERSONALITY");
    buffer.writeln("TRAITS IN METAPHORS\n");

    points.forEach((category, subCategories) {
      buffer.writeln("${capitalize(category)}:\n");

      subCategories.forEach((subCategory, traits) {
        if (subCategory.isNotEmpty) {
          buffer.writeln("${capitalize(subCategory)}:");
        }

        traits.forEach((trait, points) {
          buffer.writeln("• ${capitalize(trait)}:");
          for (var point in points) {
            buffer.writeln("    - ${formatPoints(point)}");
          }
        });

        buffer.writeln();
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
        centerTitle: true,
        actions: [
          if (onThemeChanged != null)
            IconButton(
              onPressed: onThemeChanged,
              icon: Icon(Icons.brightness_6),
              tooltip: 'Toggle Theme',
            ),
        ],
      ),
      body: detailedPoints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_dissatisfied,
                      size: 64, color: Theme.of(context).disabledColor),
                  SizedBox(height: 16),
                  Text(
                    'No options selected.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: detailedPoints.entries.map((categoryEntry) {
                      final category = categoryEntry.key;
                      final subCategories = categoryEntry.value;

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            capitalize(category),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          children: subCategories.entries.map((subEntry) {
                            final subCategory = subEntry.key;
                            final traits = subEntry.value;

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (subCategory.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        capitalize(subCategory),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ...traits.entries.map((traitEntry) {
                                    final trait = traitEntry.key;
                                    final points = traitEntry.value;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "• ${capitalize(trait)}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          ...points.map((point) => Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0, top: 2.0),
                                                child: Text(
                                                  "- ${formatPoints(point)}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              )),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: formattedText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied to clipboard!')),
                              );
                            },
                            icon: Icon(Icons.copy),
                            label: Text('Copy All'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onNewAnalysis();
                            },
                            icon: Icon(Icons.refresh),
                            label: Text('New Analysis'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
