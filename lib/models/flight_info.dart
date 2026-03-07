// lib/models/flight_info.dart

class FlightInfo {
  final String airlineName;
  final String flightNumber;
  final String departureIata;
  final String arrivalIata;
  final String? scheduledDepartureTime;
  final String? scheduledArrivalTime;
  final String? duration; // "2h 30m" 형식의 문자열
  final String? delay;
  final String? status;
  final String? departureTerminal;
  final String? departureGate;
  final String? arrivalTerminal;
  final String? arrivalGate;
  final String? aircraftModel;

  FlightInfo({
    required this.airlineName,
    required this.flightNumber,
    required this.departureIata,
    required this.arrivalIata,
    this.scheduledDepartureTime,
    this.scheduledArrivalTime,
    this.duration,
    this.delay,
    this.status,
    this.departureTerminal,
    this.departureGate,
    this.arrivalTerminal,
    this.arrivalGate,
    this.aircraftModel,
  });

  factory FlightInfo.fromAeroDataBoxJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? departureMovement = json['departure'];
    final Map<String, dynamic>? arrivalMovement = json['arrival'];

    // 시간 파싱 (HH:MM)
    String? parseTime(String? dateTimeString) {
      if (dateTimeString != null && dateTimeString.length >= 16) {
        return dateTimeString.substring(11, 16);
      }
      return null;
    }

    final String? depTimeLocal = departureMovement?['scheduledTime']?['local'] as String?;
    final String? arrTimeLocal = arrivalMovement?['scheduledTime']?['local'] as String?;

    // 🚨 Duration 계산 로직 수정
    // AeroDataBox API는 UTC 출발/도착 시간을 제공하므로 이를 이용해 정확한 차이를 계산
    String? durationFormatted;
    final String? depTimeUtcStr = departureMovement?['scheduledTime']?['utc'] as String?;
    final String? arrUtcStr = arrivalMovement?['scheduledTime']?['utc'] as String?;

    if (depTimeUtcStr != null && arrUtcStr != null) {
      try {
        final depUtc = DateTime.parse(depTimeUtcStr);
        final arrUtc = DateTime.parse(arrUtcStr);
        final difference = arrUtc.difference(depUtc);

        if (!difference.isNegative) {
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          // "2h 30m" 형식으로 정확하게 포맷팅
          // 분이 0이어도 "2h 0m"으로 표기하여 파싱 오류 방지
          durationFormatted = '${hours}h ${minutes}m';
        }
      } catch (e) {
        durationFormatted = null;
      }
    }

    // Delay 계산
    String? delayFormatted;
    final String? scheduledDepUtcStr = departureMovement?['scheduledTime']?['utc'] as String?;
    final String? revisedDepUtcStr = departureMovement?['revisedTime']?['utc'] as String?;

    if (scheduledDepUtcStr != null && revisedDepUtcStr != null) {
      try {
        final scheduled = DateTime.parse(scheduledDepUtcStr);
        final revised = DateTime.parse(revisedDepUtcStr);
        final difference = revised.difference(scheduled);

        if (difference.inMinutes > 0) {
          final hours = difference.inMinutes ~/ 60;
          final minutes = difference.inMinutes % 60;
          delayFormatted = '${hours}h ${minutes}m';
        }
      } catch (e) {
        delayFormatted = null;
      }
    }

    return FlightInfo(
      airlineName: json['airline']?['name'] ?? 'Unknown Airline',
      flightNumber: json['number']?.toString() ?? 'Unknown',
      departureIata: departureMovement?['airport']?['iata'] ?? 'N/A',
      arrivalIata: arrivalMovement?['airport']?['iata'] ?? 'N/A',
      scheduledDepartureTime: parseTime(depTimeLocal),
      scheduledArrivalTime: parseTime(arrTimeLocal),
      duration: durationFormatted,
      delay: delayFormatted,
      status: json['status'] as String?,
      departureTerminal: departureMovement?['terminal'] as String?,
      departureGate: departureMovement?['gate'] as String?,
      arrivalTerminal: arrivalMovement?['terminal'] as String?,
      arrivalGate: arrivalMovement?['gate'] as String?,
      aircraftModel: json['aircraft']?['model'] as String?,
    );
  }
}