import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/animated_pressable.dart';
import '../../../../../core/widgets/pagination_bar.dart';
import '../../../../../core/widgets/shine_sweep.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/client.dart';
import '../../bloc/rates_shell_bloc.dart';
import '../../rates_colors.dart';
import '../client_picker_page.dart';

const _clientGridRows = 2;
const _clientGridPadding = EdgeInsets.fromLTRB(125, 0, 125, 28);
const _clientGridPaddingMobile = EdgeInsets.fromLTRB(24, 0, 24, 28);

SliverGridDelegateWithFixedCrossAxisCount _clientGridDelegate(int crossAxisCount) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    mainAxisSpacing: 20,
    crossAxisSpacing: 20,
    mainAxisExtent: 168,
  );
}

int _clientGridColumnCount(BuildContext context) {
  if (Breakpoints.isMobile(context)) return 1;
  if (Breakpoints.isDesktop(context)) return 3;
  return 2;
}

class ShippingCalculatorClientsView extends StatelessWidget {
  const ShippingCalculatorClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;
    final isMobile = Breakpoints.isMobile(context);
    final columns = _clientGridColumnCount(context);
    final gridDelegate = _clientGridDelegate(columns);
    final gridPadding = isMobile ? _clientGridPaddingMobile : _clientGridPadding;

    final searchField = _ClientSearchField(
      initialValue: state.calcClientSearch,
      onChanged: (v) => bloc.add(ShippingCalculatorClientSearchChanged(v)),
    );

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Calculator',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: context.colors.textBody),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a client to calculate freight rates',
          style: TextStyle(fontSize: 14, color: context.colors.textMuted),
        ),
      ],
    );

    // Desktop/tablet always fits its fixed-row grid within the Expanded
    // region. Mobile doesn't — rows can exceed the viewport left after the
    // header/pagination bar, and a non-scrollable grid just clips instead
    // of scrolling.
    final physics = isMobile
        ? const AlwaysScrollableScrollPhysics()
        : const NeverScrollableScrollPhysics();

    final body = Expanded(
      child: state.isLoading
          ? SkeletonShimmer(
              child: GridView.builder(
                padding: gridPadding,
                physics: physics,
                itemCount: columns * _clientGridRows,
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) => const GridCardSkeleton(),
              ),
            )
          : GridView.builder(
              padding: gridPadding,
              physics: physics,
              itemCount: state.pagedCalcClients.length,
              gridDelegate: gridDelegate,
              itemBuilder: (context, index) {
                final client = state.pagedCalcClients[index];
                return _CalcClientCard(
                  client: client,
                  rateCount: state.clientRateCounts[client.id] ?? 0,
                  onTap: () => bloc.add(ShippingCalculatorClientChosen(client.id)),
                );
              },
            ),
    );

    final paginationBar = state.filteredCalcClients.isNotEmpty
        ? PaginationBar(
            page: state.calcClientPage,
            itemsPerPage: RatesShellState.clientsPerPage,
            totalItems: state.filteredCalcClients.length,
            onPageChanged: (p) => bloc.add(ShippingCalculatorClientPageChanged(p)),
          )
        : null;

    final parts = (titleColumn: titleColumn, searchField: searchField);

    return isMobile
        ? ClientPickerPageMobile(parts: parts, body: body, paginationBar: paginationBar)
        : ClientPickerPageWeb(parts: parts, body: body, paginationBar: paginationBar);
  }
}

class _CalcClientCard extends StatelessWidget {
  const _CalcClientCard({required this.client, required this.rateCount, required this.onTap});

  final Client client;
  final int rateCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: context.colors.shadowSoft, blurRadius: 28, offset: const Offset(0, 10)),
            BoxShadow(color: context.colors.shadowSoft.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: ShineSweep(
                        child: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [context.colors.primary, context.colors.primaryDeep],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Text(
                            client.initials,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            client.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textBody),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            client.accountNumber,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.primaryDeep, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoPill(
                        icon: CupertinoIcons.briefcase_fill,
                        label: client.businessType.toUpperCase(),
                      ),
                      InfoPill(
                        icon: CupertinoIcons.doc_text_fill,
                        label: 'VAT ${client.vatStatus.label}',
                        bordered: true,
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceSubtle,
                      border: Border(top: BorderSide(color: context.colors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '$rateCount custom rate${rateCount == 1 ? '' : 's'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textMutedStrong),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate_outlined, size: 13, color: context.colors.primaryDeep),
                            const SizedBox(width: 4),
                            Text(
                              'Calculate',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primaryDeep),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

/// Client search field with a clear ("x") button — only shown once there's
/// text to clear. Owns its own [TextEditingController] (rather than relying
/// on `ShadInput.initialValue`, which only seeds once and can't be
/// programmatically cleared afterward) so the clear button can actually
/// empty the visible field, not just reset the bloc's search query.
class _ClientSearchField extends StatefulWidget {
  const _ClientSearchField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_ClientSearchField> createState() => _ClientSearchFieldState();
}

class _ClientSearchFieldState extends State<_ClientSearchField> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: ShadInput(
                controller: _controller,
                placeholder: const Text('Search clients...'),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(CupertinoIcons.search, size: 16, color: context.colors.textMuted),
                ),
                onChanged: widget.onChanged,
              ),
            ),
            if (_controller.text.isNotEmpty) ...[
              const SizedBox(width: 8),
              Material(
                color: context.colors.surfaceMuted,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _clear,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(CupertinoIcons.clear, size: 15, color: context.colors.textMuted),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
