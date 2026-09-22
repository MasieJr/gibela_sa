import 'package:maplibre/maplibre.dart';

class Journey {
  final String type;
  final Geographic origin;
  final Geographic destination;
  final Geographic boardingPoint;
  final Geographic dropOffPoint;
  final List<JourneyLeg> legs;

  const Journey({
    required this.type,
    required this.origin,
    required this.destination,
    required this.boardingPoint,
    required this.dropOffPoint,
    required this.legs,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      type: json['type'] as String,
      origin: _geographicFromJson(json['origin'] as Map<String, dynamic>),
      destination: _geographicFromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      boardingPoint: _geographicFromJson(
        json['boardingPoint'] as Map<String, dynamic>,
      ),
      dropOffPoint: _geographicFromJson(
        json['dropOffPoint'] as Map<String, dynamic>,
      ),
      legs: (json['legs'] as List<dynamic>)
          .map((leg) => JourneyLeg.fromJson(leg as Map<String, dynamic>))
          .toList(),
    );
  }

  static Geographic _geographicFromJson(Map<String, dynamic> json) {
    return Geographic(
      lon: (json['longitude'] as num).toDouble(),
      lat: (json['latitude'] as num).toDouble(),
    );
  }

  List<JourneyLeg> get taxiLegs => legs.where((leg) => leg.isTaxi).toList();

  List<JourneyLeg> get walkingLegs =>
      legs.where((leg) => leg.isWalking).toList();

  JourneyLeg? get taxiLeg {
    for (final leg in legs) {
      if (leg.isTaxi) {
        return leg;
      }
    }

    return null;
  }

  double get totalWalkingDistance {
    return walkingLegs.fold(
      0,
      (total, leg) => total + (leg.distanceMeters ?? 0),
    );
  }

  double get totalWalkingDuration {
    return walkingLegs.fold(
      0,
      (total, leg) => total + (leg.durationSeconds ?? 0),
    );
  }

  double get totalFare {
    return taxiLegs.fold(0, (total, leg) => total + (leg.route?.fare ?? 0));
  }

  bool get hasTransfer => taxiLegs.length > 1;

  TaxiRankRef? get transferRank {
    if (!hasTransfer) {
      return null;
    }

    return taxiLegs.first.route?.destinationRank;
  }

  Geographic? get transferPoint {
    if (!hasTransfer) {
      return null;
    }

    return taxiLegs.first.geometry.lastPoint;
  }
}

class JourneyLeg {
  final String type;
  final double? distanceMeters;
  final double? durationSeconds;
  final JourneyGeometry geometry;
  final JourneyRoute? route;

  const JourneyLeg({
    required this.type,
    this.distanceMeters,
    this.durationSeconds,
    required this.geometry,
    this.route,
  });

  factory JourneyLeg.fromJson(Map<String, dynamic> json) {
    return JourneyLeg(
      type: json['type'] as String,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
      geometry: JourneyGeometry.fromJson(
        json['geometry'] as Map<String, dynamic>,
      ),
      route: json['route'] != null
          ? JourneyRoute.fromJson(json['route'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isWalking => type == 'walk';

  bool get isTaxi => type == 'taxi';
}

class JourneyRoute {
  final String id;
  final String name;
  final TaxiRankRef originRank;
  final TaxiRankRef destinationRank;
  final double? fare;
  final bool verified;

  const JourneyRoute({
    required this.id,
    required this.name,
    required this.originRank,
    required this.destinationRank,
    this.fare,
    required this.verified,
  });

  factory JourneyRoute.fromJson(Map<String, dynamic> json) {
    return JourneyRoute(
      id: json['id'].toString(),
      name: json['name'] as String,
      originRank: TaxiRankRef.fromJson(
        json['originRank'] as Map<String, dynamic>,
      ),
      destinationRank: TaxiRankRef.fromJson(
        json['destinationRank'] as Map<String, dynamic>,
      ),
      fare: (json['fare'] as num?)?.toDouble(),
      verified: json['verified'] as bool? ?? false,
    );
  }
}

class TaxiRankRef {
  final String id;
  final String name;

  const TaxiRankRef({required this.id, required this.name});

  factory TaxiRankRef.fromJson(Map<String, dynamic> json) {
    return TaxiRankRef(id: json['id'].toString(), name: json['name'] as String);
  }
}

class JourneyGeometry {
  final String type;

  final List<List<Geographic>> coordinates;

  const JourneyGeometry({required this.type, required this.coordinates});

  factory JourneyGeometry.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    final rawCoordinates = json['coordinates'] as List<dynamic>;

    switch (type) {
      case 'LineString':
        return JourneyGeometry(
          type: type,
          coordinates: [
            rawCoordinates
                .map(
                  (coordinate) =>
                      _coordinateToGeographic(coordinate as List<dynamic>),
                )
                .toList(),
          ],
        );

      case 'MultiLineString':
        return JourneyGeometry(
          type: type,
          coordinates: rawCoordinates
              .map(
                (line) => (line as List<dynamic>)
                    .map(
                      (coordinate) =>
                          _coordinateToGeographic(coordinate as List<dynamic>),
                    )
                    .toList(),
              )
              .toList(),
        );

      default:
        throw FormatException('Unsupported geometry type: $type');
    }
  }

  static Geographic _coordinateToGeographic(List<dynamic> coordinate) {
    if (coordinate.length < 2) {
      throw const FormatException('Invalid GeoJSON coordinate.');
    }

    return Geographic(
      lon: (coordinate[0] as num).toDouble(),
      lat: (coordinate[1] as num).toDouble(),
    );
  }

  List<Geographic> get flattened => coordinates.expand((line) => line).toList();

  Geographic? get firstPoint {
    if (coordinates.isEmpty) {
      return null;
    }

    for (final line in coordinates) {
      if (line.isNotEmpty) {
        return line.first;
      }
    }

    return null;
  }

  Geographic? get lastPoint {
    if (coordinates.isEmpty) {
      return null;
    }

    for (int i = coordinates.length - 1; i >= 0; i--) {
      if (coordinates[i].isNotEmpty) {
        return coordinates[i].last;
      }
    }

    return null;
  }
}
