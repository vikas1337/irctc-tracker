import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../data/seed.dart';
import '../models.dart';
import 'common.dart';

Future<Station?> pickStation(BuildContext context, {String title = 'Select station'}) {
  return showModalBottomSheet<Station>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _StationPickerSheet(title: title),
  );
}

class _StationPickerSheet extends StatefulWidget {
  const _StationPickerSheet({required this.title});

  final String title;

  @override
  State<_StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends State<_StationPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = _query.trim().isEmpty ? stations.toList() : repository.searchStations(_query);
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: true,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Station name or code',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: Icons.location_off_rounded,
                      title: 'No stations found',
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final s = list[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Text(
                              s.code.length > 3 ? s.code.substring(0, 3) : s.code,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${s.code} · ${s.state}'),
                          onTap: () => Navigator.of(context).pop(s),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
