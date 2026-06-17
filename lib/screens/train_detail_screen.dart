import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class TrainDetailScreen extends StatefulWidget {
  const TrainDetailScreen({super.key, required this.train, this.initialTab = 0});

  final Train train;
  final int initialTab;

  @override
  State<TrainDetailScreen> createState() => _TrainDetailScreenState();
}

class _TrainDetailScreenState extends State<TrainDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.train;
    final app = context.watch<AppState>();
    final fav = app.isFavorite(t.number);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.number}  ${t.type}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(t.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => app.toggleFavorite(t.number),
            icon: Icon(fav ? Icons.star_rounded : Icons.star_border_rounded,
                color: fav ? AppColors.accent : null),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Theme.of(context).dividerColor,
          tabs: const [Tab(text: 'Live status'), Tab(text: 'Schedule')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_LiveTab(train: t), _ScheduleTab(train: t)],
      ),
    );
  }
}

class _LiveTab extends StatefulWidget {
  const _LiveTab({required this.train});

  final Train train;

  @override
  State<_LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<_LiveTab> {
  Timer? _timer;
  late LiveStatus _status;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  void _refresh() {
    setState(() => _status = repository.liveStatus(widget.train));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LiveHeader(status: s),
          const SizedBox(height: 20),
          const SectionHeader('Journey'),
          for (var i = 0; i < s.stops.length; i++)
            _TimelineRow(stop: s.stops[i], isLast: i == s.stops.length - 1),
        ],
      ),
    );
  }
}

class _LiveHeader extends StatelessWidget {
  const _LiveHeader({required this.status});

  final LiveStatus status;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DelayChip(status.delayMinutes),
                const Spacer(),
                Icon(Icons.bolt_rounded, size: 15, color: subtle),
                const SizedBox(width: 3),
                Text('live', style: TextStyle(color: subtle, fontSize: 12.5)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              status.headline,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: status.progress,
                minHeight: 7,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(status.train.fromName,
                    style: TextStyle(color: subtle, fontSize: 12)),
                Text('${(status.progress * 100).round()}%',
                    style: TextStyle(color: subtle, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(status.train.toName,
                    style: TextStyle(color: subtle, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.stop, required this.isLast});

  final LiveStop stop;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final s = stop.stop;
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final departed = stop.state == StopState.departed;
    final approaching = stop.state == StopState.approaching;
    final accent = approaching ? AppColors.accent : AppColors.primary;
    final lineColor = departed || approaching ? AppColors.primary : Theme.of(context).dividerColor;

    final delayed = stop.delayMinutes > 0 && !s.isOrigin;
    final etaColor = stop.delayMinutes <= 0
        ? AppColors.success
        : (stop.delayMinutes <= 15 ? AppColors.amber : AppColors.danger);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                _Node(filled: departed || approaching, color: accent, ring: approaching),
                if (!isLast) Expanded(child: Container(width: 2, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.stationName,
                          style: TextStyle(
                            fontWeight: approaching ? FontWeight.w700 : FontWeight.w600,
                            color: approaching ? AppColors.accent : null,
                          ),
                        ),
                      ),
                      Text(
                        'PF ${s.platform}',
                        style: TextStyle(color: subtle, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        s.timeLabel,
                        style: TextStyle(
                          color: subtle,
                          fontSize: 13,
                          decoration: delayed ? TextDecoration.lineThrough : null,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (delayed) ...[
                        const SizedBox(width: 8),
                        Text(
                          stop.actualTime ?? '',
                          style: TextStyle(
                            color: etaColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                      const SizedBox(width: 10),
                      Text('${s.distanceKm} km', style: TextStyle(color: subtle, fontSize: 12)),
                    ],
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

class _Node extends StatelessWidget {
  const _Node({required this.filled, required this.color, required this.ring});

  final bool filled;
  final Color color;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
    return Container(
      margin: const EdgeInsets.only(top: 2),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: filled ? color : Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: filled ? color : border, width: 2),
        boxShadow: ring
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 0, spreadRadius: 3)]
            : null,
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.train});

  final Train train;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: train.schedule.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: Theme.of(context).dividerColor),
      itemBuilder: (_, i) {
        final s = train.schedule[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.timeLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        )),
                    Text('Day ${s.day}', style: TextStyle(color: subtle, fontSize: 11.5)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.stationName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      s.isOrigin
                          ? 'Starts • Dep ${s.departure}'
                          : s.isDestination
                              ? 'Ends • Arr ${s.arrival}'
                              : 'Arr ${s.arrival}  ·  Dep ${s.departure}',
                      style: TextStyle(color: subtle, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${s.distanceKm} km', style: TextStyle(color: subtle, fontSize: 12.5)),
                  Text('PF ${s.platform}', style: TextStyle(color: subtle, fontSize: 12.5)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
