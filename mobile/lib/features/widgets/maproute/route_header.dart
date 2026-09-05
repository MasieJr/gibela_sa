import 'package:flutter/material.dart';
import 'package:gibela_sa/features/widgets/global/base_card.dart';
import 'package:go_router/go_router.dart';

class RouteHeader extends StatelessWidget {
  final String destination;
  final String departure;
  final VoidCallback? onTap;

  const RouteHeader({
    super.key,
    required this.destination,
    required this.departure,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: BaseCard(
        child: Row(
          children: [
            BackButton(onPressed: context.pop),
            // Departure
            Expanded(
              child: Text(
                departure,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFF6161),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Direction Arrow
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Color.fromARGB(179, 0, 0, 0),
                size: 20,
              ),
            ),

            // Destination
            Expanded(
              child: Text(
                destination,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
