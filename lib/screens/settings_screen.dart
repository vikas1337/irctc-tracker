import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Appearance'),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: app.themeMode,
              onChanged: (m) => app.setThemeMode(m!),
              child: Column(
                children: [
                  for (final mode in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      value: mode,
                      activeColor: AppColors.primary,
                      title: Text(_modeLabel(mode)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('Clear recent searches'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    app.clearRecent();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recent searches cleared')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.train_rounded),
                  title: Text('RailRadar'),
                  subtitle: Text('Version 1.0.0'),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('Schedule data'),
                  subtitle: Text('Sample timetable for demo. Live tracking is simulated.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'Match system',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }
}
