import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/rates/presentation/rates_colors.dart';

/// A "Showing X–Y of Z" + prev/page/next control bar for a paged list.
/// [page] is 0-indexed; [itemsPerPage] and [totalItems] drive the displayed
/// range and page count.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.itemsPerPage,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int page;
  final int itemsPerPage;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  int get _pageCount => (totalItems / itemsPerPage).ceil().clamp(1, 1 << 30);

  @override
  Widget build(BuildContext context) {
    final pageCount = _pageCount;
    final rangeStart = totalItems == 0 ? 0 : page * itemsPerPage + 1;
    final rangeEnd = ((page + 1) * itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $rangeStart–$rangeEnd of $totalItems',
            style: TextStyle(fontSize: 13, color: context.colors.textMuted),
          ),
          Row(
            children: [
              _PageButton(
                icon: CupertinoIcons.chevron_left,
                enabled: page > 0,
                onTap: () => onPageChanged(page - 1),
              ),
              const SizedBox(width: 8),
              Text(
                'Page ${page + 1} of $pageCount',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textBody),
              ),
              const SizedBox(width: 8),
              _PageButton(
                icon: CupertinoIcons.chevron_right,
                enabled: page < pageCount - 1,
                onTap: () => onPageChanged(page + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.borderStrong),
            borderRadius: BorderRadius.circular(8),
            color: context.colors.surface,
          ),
          child: Icon(icon, size: 16, color: enabled ? context.colors.textBody : context.colors.textFaint),
        ),
      ),
    );
  }
}
