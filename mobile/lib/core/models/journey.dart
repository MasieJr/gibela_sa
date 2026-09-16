import 'package:maplibre/maplibre.dart';

class Journey {
  final String type;
  final Geographic origin;
  final Geographic destination;
  final Geographic boardingPoint;
  final Geographic dropOffPoint;
  final JourneyRoute route;
  final List<JourneyLeg> legs;

  const Journey({
    required this.type,
    required this.origin,
    required this.destination,
    required this.boardingPoint,
    required this.dropOffPoint,
    required this.route,
    required this.legs,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      type: json['type'] as String,
      origin: _geographicFromJson(json['origin']),
      destination: _geographicFromJson(json['destination']),
      boardingPoint: _geographicFromJson(json['boardingPoint']),
      dropOffPoint: _geographicFromJson(json['dropOffPoint']),
      route: JourneyRoute.fromJson(json['route'] as Map<String, dynamic>),
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

class JourneyLeg {
  final String type;
  final double? distanceMeters;
  final double? durationSeconds;
  final JourneyGeometry geometry;

  const JourneyLeg({
    required this.type,
    this.distanceMeters,
    this.durationSeconds,
    required this.geometry,
  });

  factory JourneyLeg.fromJson(Map<String, dynamic> json) {
    return JourneyLeg(
      type: json['type'] as String,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
      geometry: JourneyGeometry.fromJson(
        json['geometry'] as Map<String, dynamic>,
      ),
    );
  }

  bool get isWalking => type == 'walk';

  bool get isTaxi => type == 'taxi';
}

class JourneyGeometry {
  final String type;

  /// Normalized into a list of lines.
  ///
  /// LineString:
  /// [
  ///   [point, point, point]
  /// ]
  ///
  /// MultiLineString:
  /// [
  ///   [point, point],
  ///   [point, point]
  /// ]
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
    return Geographic(
      lon: (coordinate[0] as num).toDouble(),
      lat: (coordinate[1] as num).toDouble(),
    );
  }

  /// Useful when you just need one continuous list
  /// of points for MapLibre.
  List<Geographic> get flattened {
    return coordinates.expand((line) => line).toList();
  }
}
