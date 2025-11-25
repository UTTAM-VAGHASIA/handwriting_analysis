import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/hover_3d_card.dart';
import 'home_screen.dart';
import 'numerology_screen.dart';
import '../main.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 800;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome',
                            style: GoogleFonts.outfit(
                              fontSize: isDesktop ? 64 : 48,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 64),
                          if (isDesktop)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: _buildOptionCard(
                                      context,
                                      title: 'Handwriting Analysis',
                                      icon: Icons.edit_note,
                                      onTap: () => _navigateTo(
                                          context, const HomeScreen()),
                                      width: 600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  child: Center(
                                    child: _buildOptionCard(
                                      context,
                                      title: 'Numerology',
                                      icon: Icons.format_list_numbered,
                                      onTap: () => _navigateTo(
                                          context, const NumerologyScreen()),
                                      width: 600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildOptionCard(
                                  context,
                                  title: 'Handwriting Analysis',
                                  icon: Icons.edit_note,
                                  onTap: () =>
                                      _navigateTo(context, const HomeScreen()),
                                  width: double.infinity,
                                ),
                                const SizedBox(height: 24),
                                _buildOptionCard(
                                  context,
                                  title: 'Numerology',
                                  icon: Icons.format_list_numbered,
                                  onTap: () => _navigateTo(
                                      context, const NumerologyScreen()),
                                  width: double.infinity,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    final currentMode =
                        HandwritingAnalysisApp.themeNotifier.value;
                    HandwritingAnalysisApp.themeNotifier.value =
                        currentMode == ThemeMode.light
                            ? ThemeMode.dark
                            : ThemeMode.light;
                  },
                  icon: const Icon(Icons.brightness_6),
                  tooltip: 'Toggle Theme',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
  }) {
    return Hover3DCard(
      onTap: onTap,
      width: width,
      height: 350,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
