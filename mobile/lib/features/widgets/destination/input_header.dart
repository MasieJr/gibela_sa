import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gibela_sa/core/models/place.dart';
import 'package:gibela_sa/core/network/api_client.dart';
import 'package:gibela_sa/core/theme/app_colors.dart';
import 'package:gibela_sa/features/widgets/destination/location_field.dart';
import 'package:go_router/go_router.dart';

class InputHeader extends StatefulWidget {
  final TextEditingController destinationController;
  final TextEditingController originController;
  final ValueChanged<Place>? onOriginSelected;
  final ValueChanged<Place>? onDestinationSelected;
  final VoidCallback? onSwap;

  const InputHeader({
    super.key,
    required this.destinationController,
    required this.originController,
    this.onDestinationSelected,
    this.onOriginSelected,
    this.onSwap,
  });

  @override
  State<InputHeader> createState() => _InputHeaderState();
}

class _InputHeaderState extends State<InputHeader> {
  late final ApiClient _api;
  SearchField? _activeField;

  bool isLoading = true;

  Timer? _debounce;

  List<dynamic> places = [];

  @override
  void initState() {
    super.initState();

    _api = ApiClient();
  }

  void _searchPlace(String query) {
    _debounce?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 3) {
      setState(() {
        places = [];
      });

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _api.searchPlace(trimmedQuery);

        if (!mounted) return;

        setState(() {
          places = results;
        });
      } catch (e) {
        debugPrint('Error searching places: $e');
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1E293B),
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Plan Your Taxi Route',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00A3FF),
                            width: 3,
                          ),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 38,
                        color: const Color(0xFFCBD5E1),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF95B2C),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      children: [
                        LocationField(
                          controller: widget.originController,
                          hint: 'Pickup location or rank',
                          isOrigin: true,
                          search: (query) {
                            _activeField = SearchField.origin;
                            _searchPlace(query);
                          },
                        ),

                        const SizedBox(height: 10),

                        LocationField(
                          controller: widget.destinationController,
                          hint: 'Where do you want to go?',
                          isOrigin: false,
                          search: (query) {
                            _activeField = SearchField.destination;
                            _searchPlace(query);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.swap_vert_rounded,
                        color: Color(0xFF475569),
                      ),
                      onPressed: widget.onSwap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search suggestions
        if (places.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: places.length,
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 68,
                    endIndent: 16,
                    color: Color(0xFFF1F5F9),
                  );
                },
                itemBuilder: (context, index) {
                  final place = places[index];

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_activeField == SearchField.origin) {
                          widget.originController.text = place.name;
                          widget.onOriginSelected?.call(place);
                        } else if (_activeField == SearchField.destination) {
                          widget.destinationController.text = place.name;
                          widget.onDestinationSelected?.call(place);
                        }

                        setState(() {
                          places = [];
                        });

                        FocusScope.of(context).unfocus();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Location icon
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF00A3FF),
                                size: 22,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Place information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    place.address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      height: 1.3,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Icon(
                              Icons.north_west_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

enum SearchField { origin, destination }
