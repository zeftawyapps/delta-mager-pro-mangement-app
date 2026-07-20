import 'package:flutter/material.dart';
import '../delegate/home_screen_delegate.dart';

/// Search bar مستقل تماماً — StatefulWidget منفصل
/// حل مشكلة الـ setState القديمة اللي كانت تعيد بناء الشاشة كلها
class HomeSearchBarWidget extends StatefulWidget {
  final List<HomeProductItem> allProducts;
  final bool isDark;
  final String hintText;
  final void Function(String productId) onProductTap;
  final void Function(String query) onSearchSubmit;

  const HomeSearchBarWidget({
    super.key,
    required this.allProducts,
    required this.isDark,
    required this.onProductTap,
    required this.onSearchSubmit,
    this.hintText = 'ابحث عن منتج...',
  });

  @override
  State<HomeSearchBarWidget> createState() => _HomeSearchBarWidgetState();
}

class _HomeSearchBarWidgetState extends State<HomeSearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  List<HomeProductItem> _suggestions = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _isSearching = false;
        _suggestions = [];
      });
      return;
    }
    final query = value.toLowerCase();
    setState(() {
      _isSearching = true;
      _suggestions = widget.allProducts
          .where((p) =>
              p.nameAr.toLowerCase().contains(query) ||
              p.nameEn.toLowerCase().contains(query))
          .take(5)
          .toList();
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _isSearching = false;
      _suggestions = [];
    });
  }

  void _onSubmit(String value) {
    if (value.isEmpty) return;
    setState(() {
      _isSearching = false;
      _suggestions = [];
    });
    widget.onSearchSubmit(value);
  }

  void _onSuggestionTap(HomeProductItem product) {
    _clearSearch();
    widget.onProductTap(product.id);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search input
          Container(
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.grey.withOpacity(0.1)),
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onChanged: _onChanged,
              onSubmitted: _onSubmit,
            ),
          ),

          // Suggestions dropdown
          if (_isSearching && _suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.1)),
                itemBuilder: (_, index) {
                  final product = _suggestions[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? Image.network(
                              product.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image,
                                  size: 20, color: Colors.grey),
                            ),
                    ),
                    title: Text(product.nameAr,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      product.price,
                      style: TextStyle(fontSize: 12, color: primaryColor),
                    ),
                    onTap: () => _onSuggestionTap(product),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
