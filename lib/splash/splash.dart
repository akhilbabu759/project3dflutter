import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project3d/home/home.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  late final Animation<double> _scale = Tween(begin: 0.95, end: 1.0).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    // Do any initialization here (auth check, prefetch, etc.)
    await Future.delayed(const Duration(seconds: 5));
    Get.offAll(() => const HomeScreen());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: color.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft gradient
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.primaryContainer.withOpacity(0.25),
                    color.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Decorative glows
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.primary.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -50,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.secondary.withOpacity(0.08),
              ),
            ),
          ),
          // Center content
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: color.primaryContainer.withOpacity(0.35),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.view_in_ar_rounded, color: color.primary, size: 52),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Project 3D',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: color.onSurface,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rendering the future',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: color.primaryContainer.withOpacity(0.35),
                          color: color.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Version
          Positioned(
            bottom: 24, left: 0, right: 0,
            child: Opacity(
              opacity: 0.7,
              child: Text('v1.0.0',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
