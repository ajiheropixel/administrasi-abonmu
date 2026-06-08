import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';

class ProductAvatar extends StatelessWidget {
  final ProductModel? product;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;

  const ProductAvatar({
    super.key,
    required this.product,
    this.size = 48,
    this.borderRadius = 10,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg  = backgroundColor ?? AppColors.primary.withValues(alpha: 0.08);
    final url = product?.imageUrl;
    final has = product?.hasImage ?? false;

    if (has) {
      debugPrint('[ProductAvatar] loading: $url');
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: has
            ? Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: bg,
                    child: Center(
                      child: SizedBox(
                        width: size * 0.35,
                        height: size * 0.35,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, error, __) {
                  debugPrint('[ProductAvatar] ERROR loading $url — $error');
                  return _defaultIcon();
                },
              )
            : _defaultIcon(),
      ),
    );
  }

  Widget _defaultIcon() => Icon(
        Icons.inventory_2_outlined,
        size: size * 0.5,
        color: AppColors.primary.withValues(alpha: 0.5),
      );
}
