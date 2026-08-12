import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/term_model.dart';

class TermCard extends StatelessWidget {
  final TermModel term;
  final VoidCallback onTap;
  final bool isRecentlyViewed;

  const TermCard({
    super.key,
    required this.term,
    required this.onTap,
    this.isRecentlyViewed = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isRecentlyViewed ? AppColors.textSecondary : AppColors.secondary;
    return Card(
      color: isRecentlyViewed ? AppColors.divider.withOpacity(0.3) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      term.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isRecentlyViewed ? AppColors.textSecondary : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      term.category,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
