class TaxiRoute {
  final int id;
  final String name;
  final String origin;
  final String destination;
  final String status;

  TaxiRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.status,
  });

  factory TaxiRoute.fromJson(Map<String, dynamic> json) {
    return TaxiRoute(
      id: json['id'],
      name: json['name'],
      origin: json['origin'],
      destination: json['destination'],
      status: json['status'],
    );
  }
}
