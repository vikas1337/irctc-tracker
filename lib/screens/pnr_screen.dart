import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/repository.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PnrScreen extends StatefulWidget {
  const PnrScreen({super.key});

  @override
  State<PnrScreen> createState() => _PnrScreenState();
}

class _PnrScreenState extends State<PnrScreen> {
  final _controller = TextEditingController();
  PnrStatus? _result;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final pnr = _controller.text.trim();
    if (pnr.length != 10) {
      setState(() => _error = 'A PNR is 10 digits.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
      _result = null;
    });
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = repository.pnrStatus(pnr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PNR status')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _check(),
            decoration: InputDecoration(
              hintText: 'Enter 10-digit PNR',
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              counterText: '',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _check,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                : const Text('Check status', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          if (_result != null) _PnrResult(status: _result!),
          if (_result == null && !_loading)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'Track any booking',
                message: 'Enter your PNR to see coach, berth and confirmation chances.',
              ),
            ),
        ],
      ),
    );
  }
}

class _PnrResult extends StatelessWidget {
  const _PnrResult({required this.status});

  final PnrStatus status;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${status.trainNumber} · ${status.trainName}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Pill(status.travelClass),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _meta(context, 'From', status.fromCode),
                    _meta(context, 'To', status.toCode),
                    _meta(context, 'Date', DateFormat('d MMM').format(status.journeyDate)),
                    _meta(context, 'Boarding', status.boardingTime),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      status.chartPrepared ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      size: 16,
                      color: status.chartPrepared ? AppColors.success : AppColors.amber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.chartPrepared ? 'Chart prepared' : 'Chart not prepared',
                      style: TextStyle(
                        color: status.chartPrepared ? AppColors.success : AppColors.amber,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader('Passengers'),
        for (final p in status.passengers)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text('${p.number}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Booking: ${p.bookingStatus}',
                            style: TextStyle(color: subtle, fontSize: 12.5)),
                        const SizedBox(height: 2),
                        Text(p.currentStatus,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                  ),
                  _StatusBadge(state: p.state),
                ],
              ),
            ),
          ).withGap(),
      ],
    );
  }

  Widget _meta(BuildContext context, String label, String value) {
    final subtle = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: subtle, fontSize: 11.5)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (state) {
      BookingState.confirmed => (AppColors.success, 'CNF'),
      BookingState.rac => (AppColors.amber, 'RAC'),
      BookingState.waitlist => (AppColors.danger, 'WL'),
      BookingState.cancelled => (AppColors.danger, 'CAN'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
    );
  }
}

extension on Card {
  Widget withGap() => Padding(padding: const EdgeInsets.only(bottom: 12), child: this);
}
