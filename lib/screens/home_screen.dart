import 'package:flutter/material.dart';

import '../models/analysis_data.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Three tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void toggleSelection(String key, bool? value) {
    setState(() {
      if (value != null) selectedOptions[key] = value;
    });
  }

  void resetAllSelections() {
    setState(() {
      selectedOptions.clear();
    });
  }

  void resetTabSelections(String category) {
    setState(() {
      selectedOptions.removeWhere((key, _) => key.startsWith("$category >"));
    });
  }

  void selectAll(String category, List<String> items) {
    setState(() {
      for (var item in items) {
        selectedOptions["$category > $item"] = true;
      }
    });
  }

  Widget buildCategoryContent(String categoryName, dynamic categoryData) {
    if (categoryData is Map<String, List<String>>) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => resetTabSelections(categoryName),
                child: Text('Clear'),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(8),
              children: categoryData.entries.map<Widget>((entry) {
                final subCategoryName = entry.key;
                final subCategoryData = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subCategoryName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      childAspectRatio: 3,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      children: subCategoryData.map((item) {
                        final itemKey =
                            "$categoryName > $subCategoryName > $item";

                        return GestureDetector(
                          onTap: () => toggleSelection(
                              itemKey, !(selectedOptions[itemKey] ?? false)),
                          child: Card(
                            child: Center(
                              child: CheckboxListTile(
                                title:
                                    Text(item, style: TextStyle(fontSize: 18)),
                                value: selectedOptions[itemKey] ?? false,
                                onChanged: (value) =>
                                    toggleSelection(itemKey, value),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else if (categoryData is List<String>) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => resetTabSelections(categoryName),
                child: Text('Clear'),
              ),
            ],
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              childAspectRatio: 3,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 8),
              children: categoryData.map((item) {
                final itemKey = "$categoryName > $item";

                return GestureDetector(
                  onTap: () => toggleSelection(
                      itemKey, !(selectedOptions[itemKey] ?? false)),
                  child: Card(
                    child: Center(
                      child: CheckboxListTile(
                        title: Text(item, style: TextStyle(fontSize: 18)),
                        value: selectedOptions[itemKey] ?? false,
                        onChanged: (value) => toggleSelection(itemKey, value),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      return Center(child: Text('Unsupported data format.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Handwriting Analysis'),
        actions: [
          IconButton(
            onPressed: resetAllSelections,
            icon: Icon(Icons.clear_all),
            tooltip: 'Clear All',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Macro Analysis'),
            Tab(text: 'Micro Analysis'),
            Tab(text: 'Areas to Improve'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildCategoryContent(
              'Macro Analysis', macroAnalysis['Macro Analysis']),
          buildCategoryContent(
              'Micro Analysis', microAnalysis['Micro Analysis']),
          buildCategoryContent('Areas to Improve',
              areasToImprove['Micro + Macro Analysis']['Areas to Improve']),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedOptions.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      selectedOptions: selectedOptions,
                      onNewAnalysis: resetAllSelections,
                    ),
                  ),
                );
              }
            : null,
        tooltip: 'Submit Analysis',
        child: Icon(Icons.check),
      ),
    );
  }
}
