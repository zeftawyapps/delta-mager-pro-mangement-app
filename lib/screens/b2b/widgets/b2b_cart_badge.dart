import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/cart_provider.dart';
import 'package:delta_mager_pro_mangement_app/screens/b2b/cart_screen.dart';

class B2BCartBadge extends StatelessWidget {
  final String organizationId;
  final Color? color;

  const B2BCartBadge({
    super.key,
    required this.organizationId,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart, color: color),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CartScreen(organizationId: organizationId),
                ),
              ),
            ),
            if (cart.itemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${cart.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
