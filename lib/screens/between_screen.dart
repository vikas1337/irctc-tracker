import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/station_picker.dart';
import 'train_detail_screen.dart';

class BetweenScreen extends StatefulWidget {
  const BetweenScreen({super.key});

  @override
  State<BetweenScreen> createState() => _BetweenScreenState();
}

class _BetweenScreenState extends State<BetweenScreen> {
  Station? _from;
  Station? _to;

  void _swap() => setState(() {
        final t = _from;
        _from = _to;
        _to = t;
      });

  @override
  Widget build(BuildContext context) {
    final results =
        (_from != null && _to != null) ? repository.trainsBetween(_from!.code, _to!.code) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Trains between stations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _StationField(
                            label: 'From',
                            station: _from,
                            onTap: () async {
                              final s = await pickStation(context, title: 'From station');
                              if (s != null) setState(() => _from = s);
                            },
                          ),
                          Divider(height: 1, color: Theme.of(context).dividerColor),
                          _StationField(
                            label: 'To',
                            station: _to,
                            onTap: () async {
                              final s = await pickStation(context, title: 'To station');
                              if (s != null) setState(() => _to = s);
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: (_from == null && _to == null) ? null : _swap,
                      icon: const Icon(Icons.swap_vert_rounded),
                      tooltip: 'Swap',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _results(results)),
        ],
      ),
    );
  }

  Widget _results(List<Train>? results) {
    if (results == null) {
      return const EmptyState(
        icon: Icons.alt_route_rounded,
        title: 'Pick two stations',
        message: 'Choose a source and destination to see direct trains.',
      );
    }
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.train_outlined,
        title: 'No direct trains',
        message: 'No direct trains run from ${_from!.code} to ${_to!.code} in our data.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) =>
          _BetweenCard(train: results[i], fromCode: _from!.code, toCode: _to!.code),
    );
  }
}

class _StationField extends StatelessWidget {
  const _StationField({required this.label, required this.station, required this.onTap});

  final String label;
  final Station? station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Row(
          children: [
            SizedBox(width: 42, child: Text(label, style: TextStyle(color: subtle, fontSize: 12.5))),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                station?.label ?? 'Select station',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: station == null ? subtle : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: subtle),
          ],
        ),
      ),
    );
  }
}

class _BetweenCard extends StatelessWidget {
  const _BetweenCard({required this.train, required this.fromCode, required this.toCode});

  final Train train;
  final String fromCode;
  final String toCode;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final fromStop = train.schedule.firstWhere((s) => s.stationCode == fromCode);
    final toStop = train.schedule.firstWhere((s) => s.stationCode == toCode);
    final dist = toStop.distanceKm - fromStop.distanceKm;
    final dur = _segmentDuration(fromStop, toStop);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          context.read<AppState>().pushRecent(train.number);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TrainDetailScreen(train: train, initialTab: 1)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(train.number,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()])),
                  const SizedBox(width: 8),
                  Pill(train.type),
                ],
              ),
              const SizedBox(height: 2),
              Text(train.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fromStop.departure ?? fromStop.timeLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              fontFeatures: [FontFeature.tabularFigures()])),
                      Text(fromCode, style: TextStyle(color: subtle, fontSize: 12.5)),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Text(_durationLabel(dur),
                              style: TextStyle(color: subtle, fontSize: 11.5)),
                          const SizedBox(height: 2),
                          Container(height: 1.4, color: Theme.of(context).dividerColor),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(toStop.arrival ?? toStop.timeLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              fontFeatures: [FontFeature.tabularFigures()])),
                      Text(toCode, style: TextStyle(color: subtle, fontSize: 12.5)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.straighten_rounded, size: 15, color: subtle),
                  const SizedBox(width: 4),
                  Text('$dist km', style: TextStyle(color: subtle, fontSize: 12.5)),
                  const SizedBox(width: 14),
                  Wrap(
                    spacing: 6,
                    children: [for (final c in train.classes) Pill(classLabel(c))],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _segmentDuration(ScheduleStop from, ScheduleStop to) {
    int m(String hhmm) {
      final p = hhmm.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    final start = (from.day - 1) * 1440 + m(from.departure ?? from.timeLabel);
    final end = (to.day - 1) * 1440 + m(to.arrival ?? to.timeLabel);
    return end - start;
  }

  String _durationLabel(int minutes) {
    final h = minutes ~/ 60;
    final mm = minutes % 60;
    return mm == 0 ? '${h}h' : '${h}h ${mm}m';
  }
}
