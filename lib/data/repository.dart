import '../models.dart';
import 'seed.dart';

int _minutesOf(String hhmm) {
  final p = hhmm.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

String _fmt(int minutesOfDay) {
  final m = ((minutesOfDay % 1440) + 1440) % 1440;
  final h = (m ~/ 60).toString().padLeft(2, '0');
  final mm = (m % 60).toString().padLeft(2, '0');
  return '$h:$mm';
}

class RailRepository {
  const RailRepository();

  List<Train> searchTrains(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return trains.where((t) {
      return t.number.contains(q) || t.name.toLowerCase().contains(q);
    }).toList();
  }

  List<Station> searchStations(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return stations.where((s) {
      return s.code.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q) ||
          s.state.toLowerCase().contains(q);
    }).toList();
  }

  Train? trainByCode(String number) => trainByNumber[number];

  List<Train> trainsBetween(String fromCode, String toCode) {
    final result = <Train>[];
    for (final t in trains) {
      final from = t.schedule.indexWhere((s) => s.stationCode == fromCode);
      final to = t.schedule.indexWhere((s) => s.stationCode == toCode);
      if (from != -1 && to != -1 && from < to) result.add(t);
    }
    result.sort((a, b) {
      final ai = a.schedule.firstWhere((s) => s.stationCode == fromCode);
      final bi = b.schedule.firstWhere((s) => s.stationCode == fromCode);
      return _minutesOf(ai.timeLabel).compareTo(_minutesOf(bi.timeLabel));
    });
    return result;
  }

  int _delayFor(Train t) {
    final seed = t.number.hashCode & 0x7fffffff;
    const buckets = [0, 0, 0, 6, 11, 19, 28, 44];
    return buckets[seed % buckets.length];
  }

  LiveStatus liveStatus(Train t, {DateTime? now}) {
    final ref = (now ?? DateTime.now()).toUtc();
    final originAbs = _minutesOf(t.departure);
    final offsets = t.schedule.map((s) {
      final abs = (s.day - 1) * 1440 + _minutesOf(s.timeLabel);
      return abs - originAbs;
    }).toList();

    final total = t.durationMinutes;
    final seed = t.number.hashCode & 0x7fffffff;
    final cycle = total + 150;
    final nowMin = ref.millisecondsSinceEpoch ~/ 60000;
    final elapsed = (nowMin + seed) % cycle;
    final delay = _delayFor(t);
    final covered = (elapsed - delay).clamp(0, total);

    var k = 0;
    for (var i = 0; i < offsets.length; i++) {
      if (covered >= offsets[i]) k = i;
    }
    final arrived = elapsed >= total;
    final progress = (covered / total).clamp(0.0, 1.0);

    final stops = <LiveStop>[];
    for (var i = 0; i < t.schedule.length; i++) {
      final s = t.schedule[i];
      final isOrigin = i == 0;
      final stopDelay = isOrigin ? 0 : delay;
      StopState state;
      if (arrived) {
        state = StopState.departed;
      } else if (i < k || (i == k && !arrived)) {
        state = StopState.departed;
      } else if (i == k + 1) {
        state = StopState.approaching;
      } else {
        state = StopState.upcoming;
      }
      if (i == 0) state = StopState.departed;
      final schedMin = _minutesOf(s.timeLabel);
      stops.add(LiveStop(
        stop: s,
        delayMinutes: stopDelay,
        state: state,
        actualTime: _fmt(schedMin + stopDelay),
      ));
    }

    final String headline;
    if (arrived) {
      headline = delay <= 0
          ? 'Reached ${t.toName} on time'
          : 'Reached ${t.toName} • $delay min late';
    } else {
      final next = (k + 1).clamp(0, t.schedule.length - 1);
      final status = delay <= 0 ? 'Running on time' : 'Running $delay min late';
      headline = 'Departed ${t.schedule[k].stationName} • approaching '
          '${t.schedule[next].stationName} — $status';
    }

    return LiveStatus(
      train: t,
      asOf: now ?? DateTime.now(),
      currentIndex: arrived ? t.schedule.length - 1 : k,
      delayMinutes: delay,
      progress: arrived ? 1.0 : progress,
      headline: headline,
      stops: stops,
    );
  }

  List<BoardEntry> stationBoard(String code, {DateTime? now}) {
    final entries = <BoardEntry>[];
    for (final t in trains) {
      final idx = t.schedule.indexWhere((s) => s.stationCode == code);
      if (idx == -1) continue;
      final stop = t.schedule[idx];
      final live = liveStatus(t, now: now);
      entries.add(BoardEntry(
        train: t,
        time: stop.timeLabel,
        delayMinutes: idx == 0 ? 0 : live.delayMinutes,
        platform: stop.platform,
        isDeparture: stop.departure != null,
      ));
    }
    entries.sort((a, b) => _minutesOf(a.time).compareTo(_minutesOf(b.time)));
    return entries;
  }

  PnrStatus pnrStatus(String pnr, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final digits = pnr.replaceAll(RegExp(r'\D'), '');
    final h = (digits.isEmpty ? pnr.hashCode : int.parse(digits.substring(0, digits.length.clamp(0, 6)))) & 0x7fffffff;
    final t = trains[h % trains.length];
    final doj = DateTime(today.year, today.month, today.day).add(Duration(days: h % 4));
    final cls = t.classes[h % t.classes.length];
    final count = 1 + (h % 3);
    final chart = doj.difference(DateTime(today.year, today.month, today.day)).inDays == 0;

    final passengers = <Passenger>[];
    for (var i = 0; i < count; i++) {
      final r = (h >> (i * 3)) % 10;
      final coach = 'S${1 + (r % 9)}';
      final berth = 1 + ((h >> i) % 72);
      if (r < 5) {
        passengers.add(Passenger(
          number: i + 1,
          bookingStatus: 'CNF/$coach/$berth',
          currentStatus: 'CNF/$coach/$berth',
          state: BookingState.confirmed,
        ));
      } else if (r < 7) {
        passengers.add(Passenger(
          number: i + 1,
          bookingStatus: 'RAC ${10 + r}',
          currentStatus: chart ? 'CNF/$coach/$berth' : 'RAC ${2 + (r % 5)}',
          state: chart ? BookingState.confirmed : BookingState.rac,
        ));
      } else {
        final wl = 5 + r;
        passengers.add(Passenger(
          number: i + 1,
          bookingStatus: 'WL $wl',
          currentStatus: chart ? 'CNF/$coach/$berth' : 'WL ${1 + (r % 4)}',
          state: chart ? BookingState.confirmed : BookingState.waitlist,
        ));
      }
    }

    return PnrStatus(
      pnr: pnr,
      trainNumber: t.number,
      trainName: t.name,
      fromCode: t.fromCode,
      toCode: t.toCode,
      journeyDate: doj,
      boardingTime: t.departure,
      travelClass: classLabel(cls),
      chartPrepared: chart,
      passengers: passengers,
    );
  }
}

String classLabel(TrainClass c) {
  switch (c) {
    case TrainClass.sleeper:
      return 'SL';
    case TrainClass.ac3:
      return '3A';
    case TrainClass.ac2:
      return '2A';
    case TrainClass.ac1:
      return '1A';
    case TrainClass.chairCar:
      return 'CC';
    case TrainClass.general:
      return 'GEN';
    case TrainClass.secondAc:
      return 'EC';
  }
}

const repository = RailRepository();
