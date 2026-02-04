import 'package:flutter/material.dart';

/// Page transition animations for smooth navigation across the app
class PageTransitions {
  /// Fade transition - simple opacity animation
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Scale transition - zoom in/out animation
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Slide transition - slide from right animation
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Rotate transition - rotation animation
  static PageRouteBuilder<T> rotateTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Combined fade + scale transition - premium feel
  static PageRouteBuilder<T> fadescaleTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
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
      transitionDuration: duration,
    );
  }

  /// Blur slide transition - modern iOS-like transition
  static PageRouteBuilder<T> blurSlideTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// Vertical slide transition - slide from bottom
  static PageRouteBuilder<T> bottomSlideTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Premium fade with 3D perspective
  static PageRouteBuilder<T> perspective3DTransition<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 700),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(Tween<double>(begin: 1, end: 0).evaluate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }
}

/// Extension on BuildContext for easy navigation with custom transitions
extension NavigationExtension on BuildContext {
  /// Navigate with fade transition
  Future<T?> pushWithFadeTransition<T>(Widget child) {
    return Navigator.of(this).push<T>(
      PageTransitions.fadeTransition<T>(child: child),
    );
  }

  /// Navigate with scale transition
  Future<T?> pushWithScaleTransition<T>(Widget child) {
    return Navigator.of(this).push<T>(
      PageTransitions.scaleTransition<T>(child: child),
    );
  }

  /// Navigate with slide transition
  Future<T?> pushWithSlideTransition<T>(Widget child) {
    return Navigator.of(this).push<T>(
      PageTransitions.slideTransition<T>(child: child),
    );
  }

  /// Navigate with fade+scale transition (premium)
  Future<T?> pushWithFadeScaleTransition<T>(Widget child) {
    return Navigator.of(this).push<T>(
      PageTransitions.fadescaleTransition<T>(child: child),
    );
  }

  /// Navigate with bottom slide transition
  Future<T?> pushWithBottomSlideTransition<T>(Widget child) {
    return Navigator.of(this).push<T>(
      PageTransitions.bottomSlideTransition<T>(child: child),
    );
  }

  /// Navigate and replace with fade transition
  Future<T?> pushReplacementWithFadeTransition<T, TO>(Widget child) {
    return Navigator.of(this).pushReplacement<T, TO>(
      PageTransitions.fadeTransition<T>(child: child),
    );
  }

  /// Navigate and replace with fade+scale transition
  Future<T?> pushReplacementWithFadeScaleTransition<T, TO>(Widget child) {
    return Navigator.of(this).pushReplacement<T, TO>(
      PageTransitions.fadescaleTransition<T>(child: child),
    );
  }
}
