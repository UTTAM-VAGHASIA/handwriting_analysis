import 'package:flutter/material.dart';
import 'dart:ui';

class Hover3DCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double? height;
  final double? width;
  final bool isSelected;
  final Color? selectedColor;
  final bool animate;

  const Hover3DCard({
    super.key,
    required this.child,
    required this.onTap,
    this.height,
    this.width,
    this.isSelected = false,
    this.selectedColor,
    this.animate = true,
  });

  @override
  State<Hover3DCard> createState() => _Hover3DCardState();
}

class _Hover3DCardState extends State<Hover3DCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // For 3D tilt effect
  double _xRotation = 0;
  double _yRotation = 0;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (!widget.animate) return;
    setState(() {
      _isHovering = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
      setState(() {
        _xRotation = 0;
        _yRotation = 0;
      });
    }
  }

  void _onMouseMove(PointerEvent details) {
    if (!widget.animate || !_isHovering) return;

    final size = context.size;
    if (size == null) return;

    final center = Offset(size.width / 2, size.height / 2);
    final position = details.localPosition;

    // Normalize position (-1 to 1)
    final dx = (position.dx - center.dx) / (size.width / 2);
    final dy = (position.dy - center.dy) / (size.height / 2);

    setState(() {
      // Max rotation: 0.15 radians
      _xRotation = -dy * 0.15;
      _yRotation = dx * 0.15;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.selectedColor ?? Theme.of(context).colorScheme.primary;
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      onHover: _onMouseMove,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateX(_xRotation)
                ..rotateY(_yRotation)
                ..scale(widget.animate ? _scaleAnimation.value : 1.0),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: widget.height,
                    width: widget.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? [
                                primaryColor.withValues(alpha: 0.2),
                                primaryColor.withValues(alpha: 0.1),
                              ]
                            : [
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : Colors.white.withValues(alpha: 0.1),
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.05),
                              ],
                      ),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.5)
                            : Theme.of(context).brightness == Brightness.light
                                ? Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.2),
                        width: isSelected ? 2.0 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.3)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(
                                      alpha: _isHovering
                                          ? (Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? 0.4
                                              : 0.3)
                                          : (Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? 0.2
                                              : 0.1)),
                          blurRadius: _isHovering || isSelected ? 30 : 10,
                          offset: Offset(0, _isHovering || isSelected ? 10 : 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shine effect
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Content with Parallax
                        Transform.translate(
                          offset: Offset(_yRotation * 20, -_xRotation * 20),
                          child: widget.child,
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
    );
  }
}
