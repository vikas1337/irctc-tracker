import 'package:flutter/foundation.dart';

@immutable
class Station {
  final String code;
  final String name;
  final String state;

  const Station({required this.code, required this.name, required this.state});

  String get label => '$name ($code)';
}

@immutable
class ScheduleStop {
  final String stationCode;
  final String stationName;
  final String? arrival;
  final String? departure;
  final int day;
  final int distanceKm;
  final String platform;

  const ScheduleStop({
    required this.stationCode,
    required this.stationName,
    this.arrival,
    this.departure,
    required this.day,
    required this.distanceKm,
    this.platform = '-',
  });

  bool get isOrigin => arrival == null;
  bool get isDestination => departure == null;
  String get timeLabel => arrival ?? departure ?? '--:--';
}

enum TrainClass { sleeper, ac3, ac2, ac1, chairCar, general, secondAc }

@immutable
class Train {
  final String number;
  final String name;
  final String type;
  final String fromCode;
  final String fromName;
  final String toCode;
  final String toName;
  final String departure;
  final String arrival;
  final int durationMinutes;
  final List<bool> runsOn;
  final List<TrainClass> classes;
  final List<ScheduleStop> schedule;

  const Train({
    required this.number,
    required this.name,
    required this.type,
    required this.fromCode,
    required this.fromName,
    required this.toCode,
    required this.toName,
    required this.departure,
    required this.arrival,
    required this.durationMinutes,
    required this.runsOn,
    required this.classes,
    required this.schedule,
  });

  int get distanceKm => schedule.isEmpty ? 0 : schedule.last.distanceKm;

  String get durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  bool runsOnWeekday(int weekday) => runsOn[(weekday - 1) % 7];
}

enum StopState { departed, arrived, approaching, upcoming }

@immutable
class LiveStop {
  final ScheduleStop stop;
  final int delayMinutes;
  final StopState state;
  final String? actualTime;

  const LiveStop({
    required this.stop,
    required this.delayMinutes,
    required this.state,
    this.actualTime,
  });
}

@immutable
class LiveStatus {
  final Train train;
  final DateTime asOf;
  final int currentIndex;
  final int delayMinutes;
  final double progress;
  final String headline;
  final List<LiveStop> stops;

  const LiveStatus({
    required this.train,
    required this.asOf,
    required this.currentIndex,
    required this.delayMinutes,
    required this.progress,
    required this.headline,
    required this.stops,
  });

  bool get hasArrived => currentIndex >= stops.length - 1;
  bool get onTime => delayMinutes <= 0;
}

enum BookingState { confirmed, rac, waitlist, cancelled }

@immutable
class Passenger {
  final int number;
  final String bookingStatus;
  final String currentStatus;
  final BookingState state;

  const Passenger({
    required this.number,
    required this.bookingStatus,
    required this.currentStatus,
    required this.state,
  });
}

@immutable
class PnrStatus {
  final String pnr;
  final String trainNumber;
  final String trainName;
  final String fromCode;
  final String toCode;
  final DateTime journeyDate;
  final String boardingTime;
  final String travelClass;
  final bool chartPrepared;
  final List<Passenger> passengers;

  const PnrStatus({
    required this.pnr,
    required this.trainNumber,
    required this.trainName,
    required this.fromCode,
    required this.toCode,
    required this.journeyDate,
    required this.boardingTime,
    required this.travelClass,
    required this.chartPrepared,
    required this.passengers,
  });
}

@immutable
class BoardEntry {
  final Train train;
  final String time;
  final int delayMinutes;
  final String platform;
  final bool isDeparture;

  const BoardEntry({
    required this.train,
    required this.time,
    required this.delayMinutes,
    required this.platform,
    required this.isDeparture,
  });
}
