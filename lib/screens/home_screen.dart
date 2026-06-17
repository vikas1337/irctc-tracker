import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/seed.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/station_picker.dart';
import '../widgets/train_card.dart';
import 'between_screen.dart';
import 'pnr_screen.dart';
import 'search_screen.dart';
import 'station_board_screen.dart';
import 'train_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openTrain(BuildContext context, Train t, {int tab = 0}) {
    context.read<AppState>().pushRecent(t.number);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrainDetailScreen(train: t, initialTab: tab)),
    );
  }

  void _liveStatus(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SearchScreen(
        title: 'Pick a train',
        onSelect: (t) {
          Navigator.of(context).pop();
          _openTrain(context, t);
        },
      ),
    ));
  }

  Future<void> _board(BuildContext context) async {
    final s = await pickStation(context, title: 'Live station board');
    if (s != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StationBoardScreen(station: s)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final recents = app.recent.map((n) => trainByNumber[n]).whereType<Train>().toList();
    final saved = app.favorites.map((n) => trainByNumber[n]).whereType<Train>().toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            const _Greeting(),
            const SizedBox(height: 18),
            _SearchBar(onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            }),
            const SizedBox(height: 24),
            const SectionHeader('Quick actions'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _ActionTile(
                  icon: Icons.my_location_rounded,
                  label: 'Live status',
                  hint: 'Where is my train',
                  color: AppColors.primary,
                  onTap: () => _liveStatus(context),
                ),
                _ActionTile(
                  icon: Icons.confirmation_number_rounded,
                  label: 'PNR status',
                  hint: 'Check your booking',
                  color: AppColors.accent,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const PnrScreen())),
                ),
                _ActionTile(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Trains between',
                  hint: 'Plan a journey',
                  color: AppColors.secondary,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const BetweenScreen())),
                ),
                _ActionTile(
                  icon: Icons.departure_board_rounded,
                  label: 'Station board',
                  hint: 'Arrivals & departures',
                  color: AppColors.success,
                  onTap: () => _board(context),
                ),
              ],
            ),
            if (recents.isNotEmpty) ...[
              const SizedBox(height: 24),
              SectionHeader('Recent',
                  action: TextButton(
                    onPressed: app.clearRecent,
                    child: const Text('Clear'),
                  )),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recents.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ActionChip(
                    label: Text(recents[i].number),
                    avatar: const Icon(Icons.history_rounded, size: 16),
                    onPressed: () => _openTrain(context, recents[i]),
                  ),
                ),
              ),
            ],
            if (saved.isNotEmpty) ...[
              const SizedBox(height: 24),
              const SectionHeader('Saved trains'),
              for (final t in saved.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TrainCard(train: t, onTap: () => _openTrain(context, t)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.train_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RailRadar',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            Text('Live Indian Railways tracker',
                style: TextStyle(color: subtle, fontSize: 12.5)),
          ],
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: subtle),
              const SizedBox(width: 12),
              Text('Search train number or name',
                  style: TextStyle(color: subtle, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  Text(hint, style: TextStyle(color: subtle, fontSize: 11.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
