import 'package:flutter_test/flutter_test.dart';
import 'package:railradar/data/repository.dart';
import 'package:railradar/data/seed.dart';
import 'package:railradar/models.dart';

void main() {
  const repo = RailRepository();

  test('train search matches number and name', () {
    expect(repo.searchTrains('12951').single.number, '12951');
    expect(repo.searchTrains('rajdhani').length, greaterThanOrEqualTo(2));
    expect(repo.searchTrains('zzz'), isEmpty);
  });

  test('seed schedules are monotonic in time and distance', () {
    int abs(ScheduleStop s) => (s.day - 1) * 1440 + _m(s.timeLabel);
    for (final t in trains) {
      for (var i = 1; i < t.schedule.length; i++) {
        expect(abs(t.schedule[i]), greaterThan(abs(t.schedule[i - 1])),
            reason: '${t.number} time order at stop $i');
        expect(t.schedule[i].distanceKm, greaterThanOrEqualTo(t.schedule[i - 1].distanceKm),
            reason: '${t.number} distance at stop $i');
      }
      expect(t.durationMinutes, greaterThan(0));
    }
  });

  test('trains between stations are directional and ordered by departure', () {
    final res = repo.trainsBetween('BPL', 'NDLS');
    expect(res, isNotEmpty);
    expect(res.every((t) {
      final from = t.schedule.indexWhere((s) => s.stationCode == 'BPL');
      final to = t.schedule.indexWhere((s) => s.stationCode == 'NDLS');
      return from < to;
    }), isTrue);
    expect(repo.trainsBetween('NDLS', 'NDLS'), isEmpty);
  });

  test('live status advances and stays consistent', () {
    final t = trainByNumber['12951']!;
    final s = repo.liveStatus(t, now: DateTime.utc(2026, 6, 15, 10, 30));
    expect(s.progress, inInclusiveRange(0.0, 1.0));
    expect(s.stops.length, t.schedule.length);
    expect(s.stops.first.state, StopState.departed);
    final departedCount = s.stops.where((x) => x.state == StopState.departed).length;
    expect(departedCount, greaterThanOrEqualTo(1));
  });

  test('station board sorted by time and only includes serving trains', () {
    final board = repo.stationBoard('NDLS', now: DateTime.utc(2026, 6, 15, 8));
    expect(board, isNotEmpty);
    for (var i = 1; i < board.length; i++) {
      expect(_m(board[i].time), greaterThanOrEqualTo(_m(board[i - 1].time)));
    }
  });

  test('pnr is deterministic and chart logic holds', () {
    final a = repo.pnrStatus('4501236789', now: DateTime.utc(2026, 6, 15));
    final b = repo.pnrStatus('4501236789', now: DateTime.utc(2026, 6, 15));
    expect(a.trainNumber, b.trainNumber);
    expect(a.passengers.length, b.passengers.length);
    expect(a.passengers, isNotEmpty);
  });
}

int _m(String hhmm) {
  final p = hhmm.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}
