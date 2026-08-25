import 'package:flutter/material.dart';
import 'package:gibela_sa/features/routes/widgets/route_card.dart';

import '../api/routes_api.dart';
import '../models/taxi_route.dart';
import '../../../core/network/api_client.dart';
import 'route_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final RoutesApi routesApi;

  List<TaxiRoute> routes = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    final apiClient = ApiClient();

    routesApi = RoutesApi(apiClient.dio);

    loadRoutes();
  }

  Future<void> loadRoutes() async {
    try {
      final result = await routesApi.getRoutes();

      if (!mounted) return;

      setState(() {
        routes = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Unable to load routes';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),

      appBar: AppBar(
        title: const Text(
          'GibelaSA',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: _buildBody(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {},
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });

                loadRoutes();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (routes.isEmpty) {
      return const Center(child: Text('No taxi routes available'));
    }

    return RefreshIndicator(
      onRefresh: loadRoutes,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RouteCard(
              route: route,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RouteDetailsPage(routeId: route.id.toString()),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
