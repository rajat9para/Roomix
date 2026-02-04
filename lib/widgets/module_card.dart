import 'package:flutter/material.dart';
import 'package:roomix/constants/app_colors.dart';

class ModuleCard extends StatefulWidget {
  final ModuleData module;
  final VoidCallback onTap;
  final int index;

  const ModuleCard({
    super.key,
    required this.module,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _animationController.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.module.color.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                    // Enhanced shadow on hover
                    if (_isHovered)
                      BoxShadow(
                        color: widget.module.color.withOpacity(0.35),
                        blurRadius: 25,
                        offset: Offset(0, 15 * _elevationAnimation.value),
                      ),
                  ],
                  border: Border.all(
                    color: _isHovered
                        ? widget.module.color.withOpacity(0.5)
                        : AppColors.border,
                    width: _isHovered ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay on hover
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.module.color.withOpacity(0.05),
                                widget.module.color.withOpacity(0.02),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Main content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Icon Container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: _isHovered
                                ? widget.module.color.withOpacity(0.15)
                                : widget.module.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(_isHovered ? 16 : 12),
                          ),
                          child: Center(
                            child: AnimatedScale(
                              scale: _isHovered ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              child: Text(
                                widget.module.icon,
                                style: const TextStyle(fontSize: 36),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            widget.module.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isHovered
                                  ? widget.module.color
                                  : AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Animated Chevron
                        if (_isHovered) ...[
                          const SizedBox(height: 8),
                          AnimatedOpacity(
                            opacity: _isHovered ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: widget.module.color,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Re-export the ModuleData class for convenience
class ModuleData {
  final String title;
  final String icon;
  final Widget Function() route;
  final Color color;

  ModuleData({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}