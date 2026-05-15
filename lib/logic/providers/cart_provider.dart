import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_model.dart';
import 'package:matger_pro_core_logic/features/commrec/data/order_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  final double unitPrice;
  final double? originalPrice;
  final double? discountPercentage;

  final double multiplier; // Units per item (e.g. 10 if it's a pack of 10)
  final String? unitName;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.unitPrice,
    this.originalPrice,
    this.discountPercentage,
    this.multiplier = 1.0,
    this.unitName,
  });

  double get totalPrice => quantity * multiplier * unitPrice;
  double get totalSavings => originalPrice != null ? (originalPrice! - unitPrice) * quantity : 0.0;

  OrderItemData toOrderItemData() {
    final int totalPhysicalQuantity = (quantity * multiplier).toInt();
    final String unit = unitName ?? '';

    return OrderItemData(
      id: product.productId,
      name: product.name.ar,
      description: multiplier > 1 
          ? '${product.description.ar} (${quantity} عبوة × ${multiplier.toInt()} ${unit})' 
          : product.description.ar,
      quantity: totalPhysicalQuantity,
      unitPrice: unitPrice, // السعر يظل كما هو (سعر القطعة)
      totalPrice: totalPrice, // الإجمالي (الكمية الكلية * السعر)
    );
  }
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  OrganizationPolicyModel? _policy;
  String? _selectedGovernorate;

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  String? get selectedGovernorate => _selectedGovernorate;

  // Setters
  void setPolicy(OrganizationPolicyModel policy) {
    _policy = policy;
    notifyListeners();
  }

  void setGovernorate(String? govCode) {
    _selectedGovernorate = govCode;
    notifyListeners();
  }

  // --- Calculations ---

  double get subtotalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }

  /// Calculates discount from Buying Tiers (Invoice Slices)
  double get invoiceDiscount {
    if (_policy?.salesRules?.invoiceSlices == null || _policy!.salesRules!.invoiceSlices!.isEmpty) {
      return 0.0;
    }

    final subtotal = subtotalAmount;
    double discount = 0.0;
    
    // Find the highest slice that fits the subtotal
    for (var slice in _policy!.salesRules!.invoiceSlices!) {
      if (subtotal >= (slice.minAmount ?? 0)) {
        // Assuming discountAmount is a fixed value or we could check if it's a percentage. 
        // Based on policies_tab.dart, it looks like a value.
        if ((slice.discountAmount ?? 0) > discount) {
          discount = (slice.discountAmount ?? 0).toDouble();
        }
      }
    }
    return discount;
  }

  /// Calculates VAT
  double get taxAmount {
    if (_policy?.logistics?.enableVat != true) return 0.0;
    final taxPercent = (_policy?.logistics?.taxPercentage ?? 0).toDouble();
    if (taxPercent <= 0) return 0.0;
    
    // Tax is usually calculated after invoice discount
    final amountAfterDiscount = subtotalAmount - invoiceDiscount;
    return amountAfterDiscount * (taxPercent / 100);
  }

  /// Calculates Shipping Fee
  double get shippingFee {
    if (_policy?.shipping == null) return 0.0;
    
    // Free shipping check
    if (_policy!.shipping!.freeShippingEnabled == true) {
      // In a real app, there's usually a threshold. If not, it's 0.
      return 0.0;
    }

    // Check specific governorate fee
    if (_selectedGovernorate != null && _policy!.shipping!.feesByGovernorate != null) {
      final fee = _policy!.shipping!.feesByGovernorate![_selectedGovernorate];
      if (fee != null) return fee.toDouble();
    }

    // Fallback to default fee
    return (_policy!.shipping!.defaultFee ?? 0).toDouble();
  }

  /// Final amount the user will pay
  double get totalAmount {
    return subtotalAmount - invoiceDiscount + taxAmount + shippingFee;
  }

  /// Total amount saved by the user (Product discounts + Invoice discount)
  double get totalSavings {
    double savings = invoiceDiscount;
    _items.forEach((key, item) {
      savings += item.totalSavings;
    });
    return savings;
  }

  /// Preparing additional calculations for the backend
  Map<String, double> getAdditionalCalculations() {
    final Map<String, double> calculations = {};

    if (shippingFee > 0) {
      calculations['مصاريف شحن'] = shippingFee;
    }

    if (taxAmount > 0) {
      calculations['الضريبة'] = taxAmount;
    }

    if (invoiceDiscount > 0) {
      calculations['خصم الكمية'] = -invoiceDiscount;
    }

    return calculations;
  }

  List<InvoiceSlice> get availableSlices => _policy?.salesRules?.invoiceSlices ?? [];

  String get currency => _policy?.logistics?.currency ?? 'ج.م';

  void addItem(ProductModel product, {double? customPrice, int quantity = 1, double multiplier = 1.0, String? unitName}) {
    final originalPrice = customPrice ?? product.price;
    double finalPrice = originalPrice;
    
    // Calculate discount if available
    final discount = product.discount ?? 0;
    if (discount > 0) {
      finalPrice = originalPrice * (1 - (discount / 100));
    }

    if (_items.containsKey(product.productId)) {
      _items.update(
        product.productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
          unitPrice: customPrice ?? existingItem.unitPrice,
          originalPrice: existingItem.originalPrice,
          discountPercentage: existingItem.discountPercentage,
          multiplier: (multiplier != 1.0) ? multiplier : existingItem.multiplier,
          unitName: unitName ?? existingItem.unitName,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.productId,
        () => CartItem(
          product: product,
          quantity: quantity,
          unitPrice: finalPrice,
          originalPrice: originalPrice,
          discountPercentage: discount > 0 ? discount : null,
          multiplier: multiplier,
          unitName: unitName,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
          unitPrice: existingItem.unitPrice,
          originalPrice: existingItem.originalPrice,
          discountPercentage: existingItem.discountPercentage,
          multiplier: existingItem.multiplier,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<OrderItemData> getOrderItems() {
    return _items.values.map((item) => item.toOrderItemData()).toList();
  }
}
