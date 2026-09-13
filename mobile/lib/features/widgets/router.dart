import 'package:gibela_sa/core/models/place.dart';
import 'package:gibela_sa/features/screens/destination_page.dart';
import 'package:gibela_sa/features/screens/home_page.dart';
import 'package:gibela_sa/features/screens/map_route_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/destination',
      builder: (context, state) => const DestinationPage(),
    ),
    GoRoute(
      path: '/routes',
      builder: (context, state) {
        final data = state.extra as Map<String, Place?>;

        return MapRoutePage(
          origin: data['origin']!,
          destination: data['destination']!,
        );
      },
    ),
  ],
);
