import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_typography.dart';
import 'sidebar.dart';

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget child;
  final int currentIndex;
  final Function(int) onItemSelected;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.currentIndex,
    required this.onItemSelected,
    this.actions,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        Sidebar(
          currentIndex: widget.currentIndex,
          onItemSelected: widget.onItemSelected,
        ),

        // Conteúdo Principal
        Expanded(
          child: Column(
            children: [
              // Top Bar
              Container(
                color: AppColors.cardBackground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.headingMedium.copyWith(
                        color: AppColors.darkText,
                      ),
                    ),
                    if (widget.actions != null) Row(children: widget.actions!),
                  ],
                ),
              ),

              // Conteúdo
              Expanded(
                child: Container(
                  color: AppColors.backgroundColor,
                  padding: const EdgeInsets.all(32),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
