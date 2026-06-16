import '../models.dart';

const stations = <Station>[
  Station(code: 'NDLS', name: 'New Delhi', state: 'Delhi'),
  Station(code: 'MMCT', name: 'Mumbai Central', state: 'Maharashtra'),
  Station(code: 'CSMT', name: 'Mumbai CSMT', state: 'Maharashtra'),
  Station(code: 'HWH', name: 'Howrah Jn', state: 'West Bengal'),
  Station(code: 'SBC', name: 'KSR Bengaluru', state: 'Karnataka'),
  Station(code: 'MAS', name: 'MGR Chennai Central', state: 'Tamil Nadu'),
  Station(code: 'SC', name: 'Secunderabad Jn', state: 'Telangana'),
  Station(code: 'ADI', name: 'Ahmedabad Jn', state: 'Gujarat'),
  Station(code: 'BPL', name: 'Bhopal Jn', state: 'Madhya Pradesh'),
  Station(code: 'JP', name: 'Jaipur Jn', state: 'Rajasthan'),
  Station(code: 'PUNE', name: 'Pune Jn', state: 'Maharashtra'),
  Station(code: 'NGP', name: 'Nagpur Jn', state: 'Maharashtra'),
  Station(code: 'BBS', name: 'Bhubaneswar', state: 'Odisha'),
  Station(code: 'BRC', name: 'Vadodara Jn', state: 'Gujarat'),
  Station(code: 'KOTA', name: 'Kota Jn', state: 'Rajasthan'),
  Station(code: 'JHS', name: 'Jhansi Jn', state: 'Uttar Pradesh'),
  Station(code: 'ET', name: 'Itarsi Jn', state: 'Madhya Pradesh'),
  Station(code: 'GWL', name: 'Gwalior Jn', state: 'Madhya Pradesh'),
  Station(code: 'AGC', name: 'Agra Cantt', state: 'Uttar Pradesh'),
  Station(code: 'BZA', name: 'Vijayawada Jn', state: 'Andhra Pradesh'),
  Station(code: 'SWM', name: 'Sawai Madhopur', state: 'Rajasthan'),
  Station(code: 'CNB', name: 'Kanpur Central', state: 'Uttar Pradesh'),
  Station(code: 'DDU', name: 'Pt DD Upadhyaya Jn', state: 'Uttar Pradesh'),
  Station(code: 'GAYA', name: 'Gaya Jn', state: 'Bihar'),
  Station(code: 'GTL', name: 'Guntakal Jn', state: 'Andhra Pradesh'),
  Station(code: 'KPD', name: 'Katpadi Jn', state: 'Tamil Nadu'),
  Station(code: 'KGP', name: 'Kharagpur Jn', state: 'West Bengal'),
  Station(code: 'ST', name: 'Surat', state: 'Gujarat'),
];

final stationByCode = {for (final s in stations) s.code: s};

const _daily = [true, true, true, true, true, true, true];

int _toMinutes(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

Train _train({
  required String number,
  required String name,
  required String type,
  required List<bool> runsOn,
  required List<TrainClass> classes,
  required List<List<Object?>> stops,
}) {
  final schedule = <ScheduleStop>[];
  for (final row in stops) {
    final code = row[0] as String;
    schedule.add(ScheduleStop(
      stationCode: code,
      stationName: stationByCode[code]?.name ?? code,
      arrival: row[1] as String?,
      departure: row[2] as String?,
      day: row[3] as int,
      distanceKm: row[4] as int,
      platform: row[5] as String,
    ));
  }
  final first = schedule.first;
  final last = schedule.last;
  final startAbs = (first.day - 1) * 1440 + _toMinutes(first.departure!);
  final endAbs = (last.day - 1) * 1440 + _toMinutes(last.arrival!);
  return Train(
    number: number,
    name: name,
    type: type,
    fromCode: first.stationCode,
    fromName: first.stationName,
    toCode: last.stationCode,
    toName: last.stationName,
    departure: first.departure!,
    arrival: last.arrival!,
    durationMinutes: endAbs - startAbs,
    runsOn: runsOn,
    classes: classes,
    schedule: schedule,
  );
}

final trains = <Train>[
  _train(
    number: '12951',
    name: 'Mumbai Rajdhani Express',
    type: 'Rajdhani',
    runsOn: _daily,
    classes: [TrainClass.ac1, TrainClass.ac2, TrainClass.ac3],
    stops: [
      ['MMCT', null, '17:00', 1, 0, '3'],
      ['BRC', '19:23', '19:25', 1, 392, '4'],
      ['KOTA', '00:30', '00:35', 2, 1043, '1'],
      ['SWM', '01:53', '01:55', 2, 1151, '2'],
      ['NDLS', '08:32', null, 2, 1386, '16'],
    ],
  ),
  _train(
    number: '12301',
    name: 'Howrah Rajdhani Express',
    type: 'Rajdhani',
    runsOn: _daily,
    classes: [TrainClass.ac1, TrainClass.ac2, TrainClass.ac3],
    stops: [
      ['NDLS', null, '16:50', 1, 0, '16'],
      ['CNB', '21:25', '21:30', 1, 440, '1'],
      ['DDU', '02:33', '02:43', 2, 792, '2'],
      ['GAYA', '04:08', '04:10', 2, 997, '1'],
      ['HWH', '09:55', null, 2, 1451, '9'],
    ],
  ),
  _train(
    number: '12627',
    name: 'Karnataka Express',
    type: 'Superfast',
    runsOn: _daily,
    classes: [TrainClass.sleeper, TrainClass.ac3, TrainClass.ac2],
    stops: [
      ['SBC', null, '19:20', 1, 0, '8'],
      ['GTL', '01:08', '01:10', 2, 312, '2'],
      ['BPL', '21:10', '21:20', 2, 1488, '1'],
      ['JHS', '01:53', '02:03', 3, 1779, '3'],
      ['AGC', '04:35', '04:40', 3, 2000, '3'],
      ['NDLS', '10:45', null, 3, 2225, '12'],
    ],
  ),
  _train(
    number: '12658',
    name: 'Bengaluru Mail',
    type: 'Superfast',
    runsOn: _daily,
    classes: [TrainClass.sleeper, TrainClass.ac3, TrainClass.ac2, TrainClass.ac1],
    stops: [
      ['SBC', null, '22:40', 1, 0, '7'],
      ['KPD', '00:43', '00:45', 2, 161, '1'],
      ['MAS', '04:30', null, 2, 362, '9'],
    ],
  ),
  _train(
    number: '12839',
    name: 'Howrah Chennai Mail',
    type: 'Superfast',
    runsOn: _daily,
    classes: [TrainClass.sleeper, TrainClass.ac3, TrainClass.ac2],
    stops: [
      ['HWH', null, '23:45', 1, 0, '12'],
      ['KGP', '01:35', '01:40', 2, 116, '3'],
      ['BBS', '05:18', '05:28', 2, 437, '4'],
      ['BZA', '15:25', '15:35', 2, 1217, '5'],
      ['MAS', '20:50', null, 2, 1659, '8'],
    ],
  ),
  _train(
    number: '12723',
    name: 'Telangana Express',
    type: 'Superfast',
    runsOn: _daily,
    classes: [TrainClass.sleeper, TrainClass.ac3, TrainClass.ac2, TrainClass.ac1],
    stops: [
      ['SC', null, '12:45', 1, 0, '10'],
      ['NGP', '18:35', '18:45', 1, 581, '1'],
      ['BPL', '23:55', '00:05', 1, 882, '2'],
      ['JHS', '04:38', '04:48', 2, 1173, '4'],
      ['NDLS', '11:00', null, 2, 1675, '14'],
    ],
  ),
  _train(
    number: '12009',
    name: 'Shatabdi Express',
    type: 'Shatabdi',
    runsOn: [true, true, true, true, true, true, false],
    classes: [TrainClass.chairCar, TrainClass.secondAc],
    stops: [
      ['MMCT', null, '06:25', 1, 0, '5'],
      ['ST', '09:13', '09:15', 1, 263, '3'],
      ['BRC', '10:48', '10:53', 1, 392, '6'],
      ['ADI', '13:05', null, 1, 493, '7'],
    ],
  ),
  _train(
    number: '12002',
    name: 'Bhopal Shatabdi Express',
    type: 'Shatabdi',
    runsOn: [true, true, true, true, true, true, false],
    classes: [TrainClass.chairCar, TrainClass.secondAc],
    stops: [
      ['NDLS', null, '06:00', 1, 0, '1'],
      ['AGC', '08:03', '08:05', 1, 195, '2'],
      ['GWL', '09:15', '09:17', 1, 313, '1'],
      ['JHS', '10:28', '10:33', 1, 415, '2'],
      ['BPL', '13:40', null, 1, 707, '4'],
    ],
  ),
];

final trainByNumber = {for (final t in trains) t.number: t};
