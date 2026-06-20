import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:delta_mager_pro_mangement_app/consts/constants/theme/app_colors.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/orders_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/cart_provider.dart';
import 'package:JoDija_tamplites/util/data_souce_bloc/feature_data_source_state.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/order_model.dart'
    as app_order;
import 'package:delta_mager_pro_mangement_app/logic/bloc/organization_policy_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/organization_policy_model.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/configs/b2b_home_config.dart';
import 'package:delta_mager_pro_mangement_app/logic/providers/app_changes_values.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/users_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/bloc/locations_bloc.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/location_models.dart';
import 'package:delta_mager_pro_mangement_app/screens/inputs/profile_input_form.dart';

class CartScreen extends StatefulWidget {
  final String organizationId;

  const CartScreen({super.key, required this.organizationId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load User Profile, Policy and Locations
    context.read<UsersBloc>().loadMyProfile();
    context.read<OrganizationPolicyBloc>().loadPolicy(widget.organizationId);
    context.read<LocationsBloc>().loadGovernorates('EG');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<
            OrganizationPolicyBloc,
            FeaturDataSourceState<OrganizationPolicyModel>
          >(
            listener: (context, state) {
              state.itemState.maybeWhen(
                success: (policy) {
                  if (policy != null) {
                    context.read<CartProvider>().setPolicy(policy);
                  }
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<OrdersBloc, FeaturDataSourceState<app_order.OrderModel>>(
            listener: (context, state) {
              state.itemState.when(
                init: () {},
                loading: () {},
                success: (order) {
                  // مسح السلة
                  context.read<CartProvider>().clear();
                  // إظهار رسالة نجاح
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إنشاء الطلب بنجاح!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                failure: (error, retry) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.message ?? 'حدث خطأ أثناء إنشاء الطلب',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              );
            },
          ),
        ],
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            if (cart.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'السلة فارغة حالياً',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? DarkColors.primary : LightColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('ابدأ التسوق'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items.values.toList()[index];
                      return _buildCartItem(cartItem, isDark, cart);
                    },
                  ),
                  _buildCheckoutSection(context, cart, isDark),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem cartItem, bool isDark, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: cartItem.product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        cartItem.product.mainImage,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      cartItem.product.name.ar,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (cartItem.multiplier > 1)
                      Text(
                        'إجمالي الوحدات: ${(cartItem.quantity * cartItem.multiplier).toInt()} ${cartItem.unitName ?? ""}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${cartItem.unitPrice.toStringAsFixed(1)} ج.م',
                        style: TextStyle(
                          color: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (cartItem.originalPrice != null &&
                          cartItem.originalPrice! > cartItem.unitPrice) ...[
                        const SizedBox(width: 8),
                        Text(
                          cartItem.originalPrice!.toStringAsFixed(1),
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quantity controls
                  Row(
                    children: [
                      _qtyButton(
                        Icons.remove,
                        () => cart.removeSingleItem(cartItem.product.productId),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _qtyButton(
                        Icons.add,
                        () => cart.addItem(cartItem.product),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 22,
                        ),
                        onPressed: () =>
                            cart.removeItem(cartItem.product.productId),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    CartProvider cart,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Info Section
          _buildUserInfoSection(context, isDark),

          // Governorate Selection
          _buildGovernorateSelector(isDark),
          const SizedBox(height: 20),

          // Cost Breakdown
          _buildBuyingTiersProgress(cart, isDark),
          const SizedBox(height: 20),

          _summaryRow(
            'الإجمالي الفرعي:',
            '${cart.subtotalAmount.toStringAsFixed(1)} ج.م',
            isDark,
          ),

          if (cart.invoiceDiscount > 0)
            _summaryRow(
              'خصم شريحة الشراء:',
              '- ${cart.invoiceDiscount.toStringAsFixed(1)} ج.م',
              isDark,
              isDiscount: true,
            ),

          if (cart.taxAmount > 0)
            _summaryRow(
              'ضريبة القيمة المضافة:',
              '+ ${cart.taxAmount.toStringAsFixed(1)} ج.م',
              isDark,
            ),

          _summaryRow(
            'مصاريف الشحن:',
            cart.shippingFee == 0
                ? "مجاني"
                : "${cart.shippingFee.toStringAsFixed(1)} ج.م",
            isDark,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي النهائي:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${cart.totalAmount.toStringAsFixed(1)} ج.م',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? DarkColors.primary : LightColors.primary,
                ),
              ),
            ],
          ),

          if (cart.totalSavings > 0)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'لقد قمت بتوفير ${cart.totalSavings.toStringAsFixed(1)} ج.م في هذا الطلب! 🎉',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Checkout Button
          _buildOrderButton(context, cart, isDark),
        ],
      ),
    );
  }

  Widget _buildGovernorateSelector(bool isDark) {
    return BlocBuilder<LocationsBloc, LocationsState>(
      builder: (context, state) {
        final governorates = state.governoratesState.maybeWhen(
          success: (data) => data ?? [],
          orElse: () => [],
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text(
                'اختر المحافظة لحساب الشحن',
                style: TextStyle(fontSize: 14),
              ),
              value: context.watch<CartProvider>().selectedGovernorate,
              items: governorates
                  .map<DropdownMenuItem<String>>(
                    (g) => DropdownMenuItem<String>(
                      value: g.code ?? g.id.toString(),
                      child: Text(
                        g.name.ar,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                context.read<CartProvider>().setGovernorate(val);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    bool isDark, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDiscount
                  ? Colors.green
                  : (isDark ? Colors.white : Colors.black),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton(
    BuildContext context,
    CartProvider cart,
    bool isDark,
  ) {
    return BlocBuilder<
      OrdersBloc,
      FeaturDataSourceState<app_order.OrderModel>
    >(
      builder: (context, state) {
        final isOrderLoading = state.itemState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        final isLoading = isOrderLoading;

        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    final appChanges = context.read<AppChangesValues>();
                    final user = appChanges.user;
                    final profile = appChanges.userProfile;

                    // 🚩 التحقق من اكتمال العنوان (محافظة، مدينة، عنوان تفصيلي)
                    final address = profile?.address;
                    final additionalInfo = profile?.additionalInfo ?? {};

                    // نتحقق من وجود المعرفات (IDs) أو الأسماء في البيانات الإضافية
                    final governorate =
                        profile?.governorateId ?? additionalInfo['governorate'];
                    final city = profile?.cityId ?? additionalInfo['city'];

                    bool isDataIncomplete =
                        (address == null || address.trim().isEmpty) ||
                        (governorate == null ||
                            governorate.toString().trim().isEmpty) ||
                        (city == null || city.toString().trim().isEmpty);

                    if (isDataIncomplete) {
                      _showIncompleteAddressDialog(context);
                      return;
                    }

                    final orderMode = B2bHomeConfig.defaultOrderMode;
                    final workflowSlug = B2bHomeConfig.defaultWorkflowSlug;
                    final calculationMode =
                        B2bHomeConfig.defaultCalculationMode;

                    context.read<OrdersBloc>().createOrder(
                      organizationId: widget.organizationId,
                      items: cart.getOrderItems(),
                      totalOrderPrice: cart.totalAmount,
                      orderMode: orderMode,
                      workflowSlug: workflowSlug != "" ? workflowSlug : null,
                      calculationMode: calculationMode,
                      senderOrganizationId: user?.organizationId,
                      additionalCalculation: cart.getAdditionalCalculations(),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? DarkColors.primary
                  : LightColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'تأكيد وإرسال الطلب',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildBuyingTiersProgress(CartProvider cart, bool isDark) {
    final slices = cart.availableSlices;
    if (slices.isEmpty) return const SizedBox.shrink();

    final subtotal = cart.subtotalAmount;
    final sortedSlices = List<InvoiceSlice>.from(slices)
      ..sort((a, b) => (a.minAmount ?? 0).compareTo(b.minAmount ?? 0));

    // Current achieved discount
    double currentDiscount = cart.invoiceDiscount;

    // Find next slice
    InvoiceSlice? nextSlice;
    for (var slice in sortedSlices) {
      if (subtotal < (slice.minAmount ?? 0)) {
        nextSlice = slice;
        break;
      }
    }

    if (nextSlice == null && currentDiscount > 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.green.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'تهانينا! لقد حصلت على أقصى خصم متاح لشرائح الشراء. 🎉',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (nextSlice == null) return const SizedBox.shrink();

    final remaining = nextSlice.minAmount! - subtotal;
    final progress = subtotal / nextSlice.minAmount!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? DarkColors.primary : LightColors.primary).withOpacity(
          0.05,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? DarkColors.primary : LightColors.primary)
              .withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخصم التالي: ${nextSlice.discountAmount} ج.م',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? DarkColors.primary : LightColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? DarkColors.primary : LightColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'باقي $remaining ج.م',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark ? DarkColors.primary : LightColors.primary,
                        (isDark ? DarkColors.primary : LightColors.primary)
                            .withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isDark ? DarkColors.primary : LightColors.primary)
                                .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'أضف بـ $remaining ج.م إضافية للحصول على الخصم!',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, bool isDark) {
    final appChanges = context.watch<AppChangesValues>();
    final profile = appChanges.userProfile;
    final user = appChanges.user;

    if (user == null) return const SizedBox.shrink();

    final address = profile?.address ?? "لم يتم تحديد عنوان";
    final phone = profile?.phone ?? user.phone;
    final additionalInfo = profile?.additionalInfo ?? {};

    final locState = context.watch<LocationsBloc>().state;

    String governorateName = additionalInfo['governorate_name'] ?? "";
    if (governorateName.isEmpty) {
      governorateName = locState.getGovernorateName(profile?.governorateId);
    }

    String cityName = additionalInfo['city_name'] ?? "";
    if (cityName.isEmpty) {
      cityName = locState.getCityName(profile?.cityId);

      // إذا لم تكن موجودة، قد نحتاج لتحميل مدن هذه المحافظة
      if (cityName.isEmpty && profile?.governorateId != null) {
        context.read<LocationsBloc>().loadCities(profile!.governorateId!);
      }
    }

    final governorate = governorateName.isNotEmpty
        ? governorateName
        : "لم يتم تحديد محافظة";
    final city = cityName.isNotEmpty ? cityName : "لم يتم تحديد مدينة";

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: isDark ? DarkColors.primary : LightColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'بيانات الشحن والتوصيل',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('تعديل', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  if (profile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileInputForm(
                          user: profile,
                          organizationId: widget.organizationId,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const Divider(height: 10),
          const SizedBox(height: 8),
          _infoRow(Icons.person_outline, user.name ?? user.username),
          const SizedBox(height: 8),
          _infoRow(Icons.phone_outlined, phone),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_outlined, "$governorate، $city، $address"),

          // Warning if data is incomplete
          if (address.isEmpty ||
              governorate.toString().isEmpty ||
              city.toString().isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يرجى إكمال بيانات العنوان لضمان وصول الطلب',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showIncompleteAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.orange),
            SizedBox(width: 10),
            Text('عنوان الشحن ناقص'),
          ],
        ),
        content: const Text(
          'يرجى إكمال بيانات العنوان في ملفك الشخصي (المحافظة، المدينة، الشارع) لضمان وصول الطلب بشكل صحيح.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // التوجه لصفحة تعديل الملف الشخصي
              // Navigator.pushNamed(context, AppRoutes.profileEdit);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('إكمال الملف الشخصي'),
          ),
        ],
      ),
    );
  }
}
