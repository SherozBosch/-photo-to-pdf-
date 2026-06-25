// App settings: theme mode, default layout, and default quality.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pdf_settings_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final settings = context.watch<PdfSettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          RadioListTile<ThemeMode>(
            title: const Text('System default'),
            value: ThemeMode.system,
            groupValue: theme.mode,
            onChanged: (m) => theme.setMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: theme.mode,
            onChanged: (m) => theme.setMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: theme.mode,
            onChanged: (m) => theme.setMode(m!),
          ),
          const Divider(),
          const _SectionHeader('Default layout'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: GridLayout.values.map((layout) {
                return ChoiceChip(
                  label: Text(layout.label),
                  selected: settings.layout == layout,
                  onSelected: (_) => settings.setLayout(layout),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const _SectionHeader('Default quality'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: PdfQuality.values.map((quality) {
                return ChoiceChip(
                  label: Text(quality.label),
                  selected: settings.quality == quality,
                  onSelected: (_) => settings.setQuality(quality),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: AppStrings.appName,
            applicationVersion: '1.0.0',
            aboutBoxChildren: [
              Text('Merge photos into a single PDF, entirely on-device.'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
