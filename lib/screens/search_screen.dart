import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repository.dart';
import '../data/seed.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/train_card.dart';
import 'train_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.onSelect, this.title});

  final void Function(Train train)? onSelect;
  final String? title;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(Train train) {
    if (widget.onSelect != null) {
      widget.onSelect!(train);
      return;
    }
    context.read<AppState>().pushRecent(train.number);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrainDetailScreen(train: train)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = repository.searchTrains(_query);
    final app = context.watch<AppState>();
    final recents = app.recent.map((n) => trainByNumber[n]).whereType<Train>().toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Search trains')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: widget.onSelect != null,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Train number or name',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Expanded(child: _body(results, recents)),
        ],
      ),
    );
  }

  Widget _body(List<Train> results, List<Train> recents) {
    if (_query.trim().isEmpty) {
      if (recents.isEmpty) {
        return const EmptyState(
          icon: Icons.travel_explore_rounded,
          title: 'Find any train',
          message: 'Search by train number like 12951, or by name.',
        );
      }
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Recent'),
          for (final t in recents)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TrainCard(train: t, onTap: () => _open(t)),
            ),
        ],
      );
    }

    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No trains found',
        message: 'Nothing matches "$_query". Check the number and try again.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => TrainCard(train: results[i], onTap: () => _open(results[i])),
    );
  }
}
