import 'dart:async';
import 'package:delta_mager_pro_mangement_app/configs/app_backend_env.dart';
import 'package:flutter/material.dart';
import '../delegate/home_screen_delegate.dart';

/// Promo Offers Slider — يتحرك تلقائياً كل 5 ثواني
class HomePromoSliderWidget extends StatefulWidget {
  final List<HomeOfferItem> offers;
  final bool isDark;
  final double height;
  final Duration autoPlayDuration;
  final void Function(HomeOfferItem offer) onTap;

  const HomePromoSliderWidget({
    super.key,
    required this.offers,
    required this.isDark,
    required this.onTap,
    this.height = 180,
    this.autoPlayDuration = const Duration(seconds: 5),
  });

  @override
  State<HomePromoSliderWidget> createState() => _HomePromoSliderWidgetState();
}

class _HomePromoSliderWidgetState extends State<HomePromoSliderWidget> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    if (widget.offers.length <= 1 ||
        !widget.offers.any((o) => (o.imageUrl ?? '').trim().isNotEmpty)) {
      return;
    }
    _timer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (!mounted || !_pageController.hasClients) return;
      _currentPage = (_currentPage + 1) % widget.offers.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant HomePromoSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offers.length != widget.offers.length) {
      _timer?.cancel();
      if (_currentPage >= widget.offers.length) {
        _currentPage = 0;
      }
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    if (widget.offers.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.offers.length,
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              final imageUrl = AppBackendEnv.resolveImageUrl(
                offer.imageUrl,
              ).trim();
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => widget.onTap(offer),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background / Image
                          imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildFallback(context),
                                )
                              : _buildFallback(context),

                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),

                          // Offer name
                          Positioned(
                            bottom: 16,
                            right: 16,
                            left: 16,
                            child: Text(
                              offer.nameAr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Dots indicator
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.offers.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPage == index ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == index
                    ? primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: widget.isDark ? Colors.grey[800] : Colors.grey[200],
      child: const Icon(Icons.local_offer, size: 50, color: Colors.grey),
    );
  }
}
