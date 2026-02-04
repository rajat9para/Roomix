import 'package:flutter/material.dart';

/// Custom page transition builder for premium fade+scale effect
class FadeScalePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeScalePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Custom material page route with smooth page transitions
class SmoothPageRoute<T> extends MaterialPageRoute<T> {
  SmoothPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Global navigation helper with smooth transitions
class SmoothNavigation {
  /// Push a new screen with smooth fade+scale transition
  static Future<T?> push<T>(
    BuildContext context,
    Widget screen, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return Navigator.of(context).push<T>(
      _buildSmoothRoute<T>(
        builder: (_) => screen,
        duration: duration,
      ),
    );
  }

  /// Push replacement with smooth transition
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget screen, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      _buildSmoothRoute<T>(
        builder: (_) => screen,
        duration: duration,
      ),
    );
  }

  /// Pop current screen
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Build smooth route with fade+scale transition
  static PageRouteBuilder<T> _buildSmoothRoute<T>({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
