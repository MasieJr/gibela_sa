import 'package:flutter/material.dart';
import 'package:gibela_sa/core/models/place.dart';

class DisplayResults extends StatelessWidget {
  final List<Place> places;
  const DisplayResults({super.key, this.places = const []});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TextField(
        //   controller: searchController,
        //   onChanged: onSearchChanged,
        //   decoration: const InputDecoration(
        //     hintText: 'Search for a place',
        //     prefixIcon: Icon(Icons.search),
        //   ),
        // ),

        if (places.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];

                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(place.name),
                  subtitle: Text(place.address),
                  onTap: () {
                    print(place.latitude);
                    print(place.longitude);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
