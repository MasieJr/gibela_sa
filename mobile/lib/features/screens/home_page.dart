import 'package:flutter/material.dart';
import 'package:gibela_sa/features/widgets/homepage/current_location.dart';
import 'package:gibela_sa/features/widgets/homepage/greeting_card.dart';
import 'package:gibela_sa/features/widgets/homepage/mini_map.dart';
import 'package:gibela_sa/features/widgets/homepage/previous_searches_card.dart';
import 'package:gibela_sa/features/widgets/homepage/saved_location_card.dart';
import 'package:gibela_sa/features/widgets/homepage/search_destination_card.dart';
import 'package:gibela_sa/features/widgets/homepage/splash.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        children: [
          Splash(topPadding: topPadding + 10),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingCard(name: "Masie"),
                  const SizedBox(height: 16),
                  // CurrentLocation(),
                  // MiniMap(),
                  const SizedBox(height: 16),
                  SearchDestinationCard(),
                  const SizedBox(height: 16),
                  SavedLocationCard(),
                  const SizedBox(height: 16),
                  PreviousSearchesCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
