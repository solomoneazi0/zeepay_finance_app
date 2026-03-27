part of '../home_screen.dart';

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  static const double _bannerHeight = 200;
  static const double _overlap = 24;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Important: the search bar must stay INSIDE the Stack’s bounds so taps work.
    return SizedBox(
      height: _bannerHeight + _overlap,
      child: Stack(
        children: [
          // Banner — full width no margin
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: _bannerHeight,
            child: _HomeBanner(isDark: isDark),
          ),

          // AppBar floating on top of banner
          Positioned(
            left: 0,
            right: 0,
            top: 46,
            child: _HomeAppBar(isDark: isDark),
          ),

          // Search bar overlapping bottom of banner (but inside hit-test bounds)
          Positioned(
            left: 20,
            right: 20,
            top: _bannerHeight - _overlap,
            child: _SearchBar(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ── AppBar ─────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  final bool isDark;
  const _HomeAppBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Zevoa logo + text
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.flash, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'zevoa',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // User avatar
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/images/Avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Banner ─────────────────────────────────────────────────
class _HomeBanner extends StatelessWidget {
  final bool isDark;
  const _HomeBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
        image: DecorationImage(
          image: AssetImage(
            isDark
                ? 'assets/images/bannerdarkmode.png'
                : 'assets/images/bannerwhitemode.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Search Bar ─────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final bool isDark;
  const _SearchBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.search_normal,
              size: 18,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              'Find services, food, & places',
              style: AppTextStyles.body.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}

// ── Wallet Card ────────────────────────────────────────────
class _WalletCard extends StatelessWidget {
  final bool isDark;
  const _WalletCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zevoa label
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Iconsax.coin,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'My Balance',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Balance + Action buttons row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Balance
                  Expanded(
                    child: Text(
                      '\$ 1430.67',
                      style: AppTextStyles.h1.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontSize: 32,
                      ),
                    ),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      _WalletAction(
                        icon: Iconsax.arrow_up_1,
                        label: 'Pay',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 16),
                      _WalletAction(
                        icon: Iconsax.add,
                        label: 'Top Up',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 16),
                      _WalletAction(
                        icon: Iconsax.more,
                        label: 'More',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 400.ms);
  }
}

// ── Wallet Action Button ───────────────────────────────────
class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _WalletAction({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Services Grid ──────────────────────────────────────────
class _ServicesGrid extends StatelessWidget {
  final bool isDark;
  const _ServicesGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final services = ServicesData.services;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero, // ← removes default GridView padding
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 25,
          crossAxisSpacing: 0,
          childAspectRatio: 1,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _ServiceItem(service: services[index], isDark: isDark)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 400 + (index * 50)),
                duration: 300.ms,
              )
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                delay: Duration(milliseconds: 400 + (index * 50)),
                duration: 300.ms,
              );
        },
      ),
    );
  }
}

// ── Service Item ───────────────────────────────────────────
class _ServiceItem extends StatelessWidget {
  final ServiceModel service;
  final bool isDark;

  const _ServiceItem({required this.service, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openServiceScreen(context, service.name),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : service.bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(service.image, width: 32, height: 32),
          ),

          const SizedBox(height: 10),

          // Service name
          Text(
            service.name,
            style: AppTextStyles.small.copyWith(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Promo Banner ───────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  final bool isDark;
  const _PromoBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 140,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            // clips image to stay inside rounded corners
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // ── Image fills entire right side ──────
                Positioned(
                  right: 0,
                  top: 45,
                  bottom: 0,
                  width: 210, // how wide the image takes on the right
                  child: Image.asset(
                    'assets/images/BANNIMAGE.png',
                    fit: BoxFit.cover, // fills completely
                  ),
                ),

                // ── Gradient over image so text is readable ──

                // ── Text content on the left ───────────
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  right: 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enjoy the benefits of',
                              style: AppTextStyles.body.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                fontSize: 12,
                              ),
                            ),

                            Text(
                              'Zevoa Plus',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get 25% off in groceries',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Available for this winter',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 400.ms);
  }
}

