import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class AppDateRangePicker extends StatelessWidget {
  final String? startDate;
  final String? endDate;
  final ValueChanged<DateTimeRange?> onChanged;

  const AppDateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onChanged,
  });

  String get _label {
    if (startDate == null && endDate == null) return 'Semua Periode';
    final fmt = DateFormat('dd MMM yyyy');
    final s = startDate != null ? fmt.format(DateTime.parse(startDate!)) : '?';
    final e = endDate != null ? fmt.format(DateTime.parse(endDate!)) : '?';
    return '$s – $e';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: startDate != null && endDate != null
              ? DateTimeRange(
                  start: DateTime.parse(startDate!),
                  end: DateTime.parse(endDate!),
                )
              : null,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        onChanged(range);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.date_range, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(_label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            if (startDate != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close,
                    size: 14, color: AppColors.textHint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



