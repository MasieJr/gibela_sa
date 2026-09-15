class TaxiRoute {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final RouteGeometry geometry;
  final String status;
  final String createdAt;
  final String updatedAt;

  TaxiRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.geometry,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaxiRoute.fromJson(Map<String, dynamic> json) {
    return TaxiRoute(
      id: json['id'].toString(),
      name: json['name'],
      origin: json['origin'],
      destination: json['destination'],
      geometry: RouteGeometry.fromJson(json['geometry']),
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class RouteGeometry {
  final String type;
  final List<List<double>> coordinates;

  RouteGeometry({required this.type, required this.coordinates});

  factory RouteGeometry.fromJson(Map<String, dynamic> json) {
    return RouteGeometry(
      type: json['type'],
      coordinates: (json['coordinates'] as List)
          .map(
            (coordinate) => [
              (coordinate[0] as num).toDouble(),
              (coordinate[1] as num).toDouble(),
            ],
          )
          .toList(),
    );
  }
}
