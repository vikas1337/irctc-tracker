import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/seed.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/train_card.dart';
import 'train_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final saved = app.favorites.map((n) => trainByNumber[n]).whereType<Train>().toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved trains')),
      body: saved.isEmpty
          ? const EmptyState(
              icon: Icons.star_border_rounded,
              title: 'No saved trains yet',
              message: 'Tap the star on any train to keep it here for quick access.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: saved.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final t = saved[i];
                return TrainCard(
                  train: t,
                  onTap: () {
                    app.pushRecent(t.number);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TrainDetailScreen(train: t)),
                    );
                  },
                );
              },
            ),
    );
  }
}
