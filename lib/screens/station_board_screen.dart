import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'train_detail_screen.dart';

enum _Filter { all, departures, arrivals }

class StationBoardScreen extends StatefulWidget {
  const StationBoardScreen({super.key, required this.station});

  final Station station;

  @override
  State<StationBoardScreen> createState() => _StationBoardScreenState();
}

class _StationBoardScreenState extends State<StationBoardScreen> {
  Timer? _timer;
  _Filter _filter = _Filter.all;
  List<BoardEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  void _refresh() {
    setState(() => _entries = repository.stationBoard(widget.station.code));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _entries.where((e) {
      return switch (_filter) {
        _Filter.all => true,
        _Filter.departures => e.isDeparture,
        _Filter.arrivals => !e.isDeparture,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.station.name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text('${widget.station.code} · ${widget.station.state}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SegmentedButton<_Filter>(
              segments: const [
                ButtonSegment(value: _Filter.all, label: Text('All')),
                ButtonSegment(value: _Filter.departures, label: Text('Departures')),
                ButtonSegment(value: _Filter.arrivals, label: Text('Arrivals')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
              showSelectedIcon: false,
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.departure_board_outlined,
                    title: 'Nothing scheduled',
                    message: 'No trains match this filter right now.',
                  )
                : RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _BoardRow(entry: filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({required this.entry});

  final BoardEntry entry;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          context.read<AppState>().pushRecent(entry.train.number);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TrainDetailScreen(train: entry.train)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.time,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          fontFeatures: [FontFeature.tabularFigures()])),
                  Text(entry.isDeparture ? 'Dep' : 'Arr',
                      style: TextStyle(color: subtle, fontSize: 11.5)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${entry.train.number} · ${entry.train.name}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    DelayChip(entry.delayMinutes, compact: true),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text('PF', style: TextStyle(color: subtle, fontSize: 10.5)),
                  Text(entry.platform,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
