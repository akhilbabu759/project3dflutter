import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:project3d/dashboard/dashboard.dart';
import 'package:project3d/detaild_screen/detaild_screen.dart';
import 'package:project3d/home/controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    // Adaptive grid count
    int gridCountForSize(BoxConstraints c) {
      final width = c.maxWidth;
      if (width >= 1100) return 3;
      if (width >= 700) return 2;
      return 1;
    }

    return Scaffold(
      backgroundColor: color.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const DashboardScreen()),
        label: const Text('Dashboard'),
        icon: const Icon(Icons.dashboard_customize_outlined),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        elevation: 6,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _FrostedAppBar(
          title: '3D Models',
          color: color,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _ShimmerGridPlaceholders();
        }

        if (controller.modelList.isEmpty) {
          return _EmptyState(
            onRefresh: () async => controller.fetchModels(),
            message: 'No models found',
            hint: 'Pull down to refresh or check your connection.',
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = gridCountForSize(constraints);
            return RefreshIndicator(
              onRefresh:()async{ controller.fetchModels();},
              color: color.primary,
              child: AnimationLimiter(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    // Taller header for the 3D preview area
                    childAspectRatio: crossAxisCount == 1 ? 0.88 : 0.9,
                  ),
                  itemCount: controller.modelList.length,
                  itemBuilder: (context, index) {
                    final model = controller.modelList[index];

                    // Derive size text once
                    final sizeKB = (model.bytes / 1024).clamp(0, double.infinity);
                    final sizeText = sizeKB >= 1024
                        ? '${(sizeKB / 1024).toStringAsFixed(2)} MB'
                        : '${sizeKB.toStringAsFixed(2)} KB';

                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 420),
                      columnCount: crossAxisCount,
                      child: SlideAnimation(
                        verticalOffset: 36,
                        child: FadeInAnimation(
                          child: _ModelCard(
                            index: index,
                            title:  '3D Model',
                            subtitle: 'A stunning 3D asset from our collection.',
                            sizeText: sizeText,
                            color: color,
                            onTap: () => Get.to(() => ModelDetailScreen(model: model)),
                            modelUrl: model.url,
                            heroTag: 'model-hero-$index',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/* Frosted/gradient app bar with large title */
class _FrostedAppBar extends StatelessWidget {
  final String title;
  final ColorScheme color;
  const _FrostedAppBar({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.primary.withOpacity(0.18),
                  color.primaryContainer.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: color.outline.withOpacity(0.12)),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color.onSurface,
          fontSize: 22,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/* Model card with improved layout and hero */
class _ModelCard extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final String sizeText;
  final ColorScheme color;
  final VoidCallback onTap;
  final String modelUrl;
  final String heroTag;

  const _ModelCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.sizeText,
    required this.color,
    required this.onTap,
    required this.modelUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        Colors.purpleAccent.withOpacity(0.12 * (index % 3 + 2)), // slightly stronger
        Colors.blueAccent.withOpacity(0.10 * ((index + 1) % 3 + 2)),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Preview header
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 3D Viewer
                    Hero(
                      tag: heroTag,
                      child: ModelViewer(
                        src: modelUrl,
                        alt: "3D Model",
                        ar: false,
                        autoRotate: true,
                        cameraControls: true,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    // Bottom soft shadow overlay
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.12),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    // Subtle corner light
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x33FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Metadata
                  Row(
                    children: [
                      Icon(Icons.memory_rounded, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Size',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sizeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // CTA row
                  Row(
                    children: [
                      _ChipPill(
                        icon: Icons.threed_rotation_outlined,
                        label: 'Preview',
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade500,
                          ),
                        ),
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
}

/* Small pill for action hint */
class _ChipPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme color;
  const _ChipPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.primaryContainer.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.primary.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/* Empty state with pull-to-refresh hint */
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  final String message;
  final String hint;

  const _EmptyState({
    required this.onRefresh,
    required this.message,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: color.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
          Icon(Icons.view_in_ar_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

/* Simple shimmer placeholders while loading */
class _ShimmerGridPlaceholders extends StatelessWidget {
  const _ShimmerGridPlaceholders();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final crossAxisCount = width >= 1100 ? 3 : width >= 700 ? 2 : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: crossAxisCount * 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: crossAxisCount == 1 ? 0.88 : 0.9,
          ),
          itemBuilder: (context, index) {
            return _ShimmerCard(color: color);
          },
        );
      },
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final ColorScheme color;
  const _ShimmerCard({required this.color});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final base = Colors.grey.shade300;
        final highlight = Colors.grey.shade100;
        Color lerp(Color a, Color b, double t) =>
            Color.lerp(a, b, t.clamp(0, 1))!;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              // header placeholder
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  gradient: LinearGradient(
                    colors: [
                      lerp(base, highlight, (t + 0.2) % 1.0),
                      lerp(base, highlight, (t + 0.6) % 1.0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  children: [
                    _shimmerLine(lerp(base, highlight, (t + 0.3) % 1.0), widthFactor: 0.7),
                    const SizedBox(height: 8),
                    _shimmerLine(lerp(base, highlight, (t + 0.5) % 1.0), widthFactor: 0.45),
                    const SizedBox(height: 8),
                    _shimmerLine(lerp(base, highlight, (t + 0.7) % 1.0), widthFactor: 0.9),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerLine(Color color, {double widthFactor = 1}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
