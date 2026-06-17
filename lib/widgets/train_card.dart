import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';

const _weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class TrainCard extends StatelessWidget {
  const TrainCard({super.key, required this.train, this.onTap, this.trailing});

  final Train train;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final fav = app.isFavorite(train.number);
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    train.number,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Pill(train.type),
                  const Spacer(),
                  trailing ??
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => app.toggleFavorite(train.number),
                        icon: Icon(
                          fav ? Icons.star_rounded : Icons.star_border_rounded,
                          color: fav ? AppColors.accent : subtle,
                        ),
                        tooltip: fav ? 'Remove from saved' : 'Save train',
                      ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                train.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              _Route(train: train),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 15, color: subtle),
                  const SizedBox(width: 4),
                  Text(train.durationLabel, style: TextStyle(color: subtle, fontSize: 12.5)),
                  const SizedBox(width: 14),
                  Icon(Icons.straighten_rounded, size: 15, color: subtle),
                  const SizedBox(width: 4),
                  Text('${train.distanceKm} km', style: TextStyle(color: subtle, fontSize: 12.5)),
                  const Spacer(),
                  _RunDays(runsOn: train.runsOn),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Route extends StatelessWidget {
  const _Route({required this.train});

  final Train train;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      children: [
        _Terminus(time: train.departure, code: train.fromCode, name: train.fromName),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                _dot(context),
                Expanded(child: Container(height: 1.4, color: Theme.of(context).dividerColor)),
                Icon(Icons.train_rounded, size: 16, color: subtle),
                Expanded(child: Container(height: 1.4, color: Theme.of(context).dividerColor)),
                _dot(context),
              ],
            ),
          ),
        ),
        _Terminus(
          time: train.arrival,
          code: train.toCode,
          name: train.toName,
          alignEnd: true,
        ),
      ],
    );
  }

  Widget _dot(BuildContext context) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      );
}

class _Terminus extends StatelessWidget {
  const _Terminus({
    required this.time,
    required this.code,
    required this.name,
    this.alignEnd = false,
  });

  final String time;
  final String code;
  final String name;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(code, style: TextStyle(fontWeight: FontWeight.w600, color: subtle, fontSize: 12.5)),
      ],
    );
  }
}

class _RunDays extends StatelessWidget {
  const _RunDays({required this.runsOn});

  final List<bool> runsOn;

  @override
  Widget build(BuildContext context) {
    final off = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              _weekdayLetters[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: runsOn[i] ? AppColors.secondary : off,
              ),
            ),
          ),
      ],
    );
  }
}
