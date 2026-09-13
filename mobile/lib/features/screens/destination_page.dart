import 'package:flutter/material.dart';
import 'package:gibela_sa/core/theme/app_colors.dart';
import 'package:gibela_sa/features/widgets/destination/bottom_action_bar.dart';
import 'package:gibela_sa/features/widgets/destination/input_header.dart';
import 'package:gibela_sa/features/widgets/destination/popular_destination.dart';
import 'package:gibela_sa/features/widgets/destination/quick_action_items.dart';
import 'package:maplibre/maplibre.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage({super.key});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  late final TextEditingController _originController;
  late final TextEditingController _destinationController;

  Geographic? origin;
  Geographic? destination;

  final List<Map<String, String>> _recentPlaces = const [
    {
      'title': 'Auckland Park Mall',
      'subtitle': 'Richmond, Johannesburg',
      'distance': '1.8 km',
    },
    {
      'title': 'Park Station Taxi Rank',
      'subtitle': 'Rissik St, Johannesburg City Centre',
      'distance': '5.2 km',
    },
    {
      'title': 'Diepsloot Taxi Rank',
      'subtitle': 'Ext 2, Diepsloot, Midrand',
      'distance': '28.4 km',
    },
    {
      'title': 'Fourways Mall',
      'subtitle': 'William Nicol Dr & Fourways Blvd',
      'distance': '21.0 km',
    },
  ];

  void _setOrigin(Geographic location) {
    setState(() {
      origin = location;
    });
  }

  void _setDestination(Geographic location) {
    setState(() {
      destination = location;
    });
  }

  void _swapLocations() {
    setState(() {
      final tempText = _originController.text;
      _originController.text = _destinationController.text;
      _destinationController.text = tempText;

      final tempLocation = origin;
      origin = destination;
      destination = tempLocation;
    });
  }

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController();
    _destinationController = TextEditingController();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            InputHeader(
              originController: _originController,
              destinationController: _destinationController,
              onOriginSelected: _setOrigin,
              onDestinationSelected: _setDestination,
              onSwap: _swapLocations,
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  QuickActionItems(
                    icon: Icons.my_location_rounded,
                    iconColor: const Color(0xFF00A3FF),
                    title: 'Use your current location',
                    subtitle: 'Requires device GPS access',
                    onTap: () {
                      setState(() {
                        _originController.text = 'Current Location';
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  QuickActionItems(
                    icon: Icons.map_outlined,
                    iconColor: const Color(0xFF388E9F),
                    title: 'Choose point on map',
                    subtitle: 'Pin origin or destination visually',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Recent & Popular Destinations',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ..._recentPlaces.map(
                    (place) => PopularDestination(
                      title: place['title']!,
                      subtitle: place['subtitle']!,
                      distance: place['distance']!,
                      onTap: () {
                        setState(() {
                          _destinationController.text = place['title']!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            BottomActionBar(origin: origin, destination: destination),
          ],
        ),
      ),
    );
  }
}
