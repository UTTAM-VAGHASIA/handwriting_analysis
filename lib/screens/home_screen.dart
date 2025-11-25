import 'package:flutter/material.dart';

import '../models/analysis_data.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const HomeScreen({super.key, this.onThemeChanged});

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
    _tabController = TabController(length: 3, vsync: this);
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

  Widget buildCategoryContent(String categoryName, dynamic categoryData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => resetTabSelections(categoryName),
                icon: Icon(Icons.clear_all),
                label: Text('Clear Tab'),
              ),
            ],
          ),
        ),
        Expanded(
          child: categoryData is Map<String, List<String>>
              ? _buildGroupedList(categoryName, categoryData)
              : _buildFlatList(categoryName, categoryData as List<String>),
        ),
      ],
    );
  }

  Widget _buildGroupedList(
      String categoryName, Map<String, List<String>> data) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final entry = data.entries.elementAt(index);
        final subCategoryName = entry.key;
        final subCategoryData = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                subCategoryName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            _buildGridItems(categoryName, subCategoryName, subCategoryData),
            SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildFlatList(String categoryName, List<String> data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: _buildGridItems(categoryName, null, data),
    );
  }

  Widget _buildGridItems(
      String categoryName, String? subCategoryName, List<String> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = 200;
        final int crossAxisCount = (constraints.maxWidth / itemWidth).floor();

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final itemKey = subCategoryName != null
                ? "$categoryName > $subCategoryName > $item"
                : "$categoryName > $item";
            final isSelected = selectedOptions[itemKey] ?? false;

            return InkWell(
              onTap: () => toggleSelection(itemKey, !isSelected),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => toggleSelection(itemKey, value),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: Text(
                                item,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                maxLines: 3,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Handwriting Analysis'),
        actions: [
          if (widget.onThemeChanged != null)
            IconButton(
              onPressed: widget.onThemeChanged,
              icon: Icon(Icons.brightness_6),
              tooltip: 'Toggle Theme',
            ),
          IconButton(
            onPressed: resetAllSelections,
            icon: Icon(Icons.refresh),
            tooltip: 'Reset All',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          tabs: [
            Tab(text: 'Macro Analysis', icon: Icon(Icons.analytics)),
            Tab(text: 'Micro Analysis', icon: Icon(Icons.search)),
            Tab(text: 'Improvements', icon: Icon(Icons.trending_up)),
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
      floatingActionButton: AnimatedScale(
        scale: selectedOptions.isNotEmpty ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  selectedOptions: selectedOptions,
                  onNewAnalysis: resetAllSelections,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            );
          },
          tooltip: 'Submit Analysis',
          icon: Icon(Icons.check),
          label: Text('Analyze'),
        ),
      ),
    );
  }
}
