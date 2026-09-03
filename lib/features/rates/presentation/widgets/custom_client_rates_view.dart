import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ratrix/core/widgets/shine_sweep.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/mr_ratrix.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../domain/entities/client_rate.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';
import 'back_pill.dart';
import 'custom_client_rates_view_mobile.dart';
import 'custom_client_rates_view_web.dart';
import 'delete_rate_dialog.dart';
import 'onboarding_tour.dart';
import 'rate_table.dart';
import 'status_toast.dart';

const _kAllValue = '__all__';

/// Pre-built, bloc-wired pieces shared by [CustomClientRatesPageWeb] and
/// [CustomClientRatesPageMobile] — they differ only in how these are
/// arranged, not in what they are.
typedef ClientRateHeaderParts = ({
  Widget backPill,
  Widget avatar,
  Widget clientInfo,
  Widget createRateButton,
  Widget tabsRow,
  Widget freightFilter,
  Widget serviceFilter,
  Widget searchField,
  Widget sortToggle,
});

class CustomClientRatesView extends StatelessWidget {
  const CustomClientRatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;
    final client = state.selectedClient;
    if (client == null) return const SizedBox.shrink();

    final backPill = BackPill(onTap: () => bloc.add(const ClientsBackRequested()));

    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ShineSweep(
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          color: context.colors.primary.withValues(alpha: 0.2),
          child: Text(
            client.initials,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
        ),
      ),
    );

    final clientInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          client.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${client.accountNumber} · ${client.email}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.55),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );

    final createRateButton = _CreateRateButtonWithHint(
      onPressed: () =>
          bloc.add(const CreateCustomRateForSelectedClientRequested()),
    );

    final tabsRow = Row(
      children: [
        RateTabPill(
          label: 'Active',
          selected: state.clientRatesTab == RateStatus.active,
          onTap: () => bloc.add(const ClientRatesTabChanged(RateStatus.active)),
        ),
        const SizedBox(width: 8),
        RateTabPill(
          label: 'Expired',
          selected: state.clientRatesTab == RateStatus.expired,
          onTap: () =>
              bloc.add(const ClientRatesTabChanged(RateStatus.expired)),
        ),
      ],
    );

    final freightFilter = SizedBox(
      width: 170,
      child: ShadSelect<String>(
        placeholder: const Text('Freight mode'),
        initialValue: state.clientRateFreightFilter?.name ?? _kAllValue,
        selectedOptionBuilder: (context, value) => Text(
          value == _kAllValue
              ? 'All modes'
              : FreightMode.values.byName(value).label,
        ),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(
            ClientRateFreightFilterChanged(
              value == _kAllValue ? null : FreightMode.values.byName(value),
            ),
          );
        },
        options: [
          const ShadOption(value: _kAllValue, child: Text('All modes')),
          for (final m in FreightMode.values)
            ShadOption(value: m.name, child: Text(m.label)),
        ],
      ),
    );

    final serviceFilter = SizedBox(
      width: 170,
      child: ShadSelect<String>(
        placeholder: const Text('Service mode'),
        initialValue: state.clientRateServiceFilter?.name ?? _kAllValue,
        selectedOptionBuilder: (context, value) => Text(
          value == _kAllValue
              ? 'All services'
              : ServiceMode.values.byName(value).label,
        ),
        onChanged: (value) {
          if (value == null) return;
          bloc.add(
            ClientRateServiceFilterChanged(
              value == _kAllValue ? null : ServiceMode.values.byName(value),
            ),
          );
        },
        options: [
          const ShadOption(value: _kAllValue, child: Text('All services')),
          for (final m in ServiceMode.values)
            ShadOption(value: m.name, child: Text(m.label)),
        ],
      ),
    );

    final searchField = SizedBox(
      width: 260,
      child: ShadInput(
        placeholder: const Text('Search by charge code, freight mode...'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            CupertinoIcons.search,
            size: 16,
            color: context.colors.textMuted,
          ),
        ),
        onChanged: (v) => bloc.add(ClientRateSearchChanged(v)),
      ),
    );

    final sortToggle = RateSortByExpiryToggle(
      active: state.clientRateSortByExpiry,
      onTap: () => bloc.add(const ClientRateSortByExpiryToggled()),
    );

    final parts = (
      backPill: backPill,
      avatar: avatar,
      clientInfo: clientInfo,
      createRateButton: createRateButton,
      tabsRow: tabsRow,
      freightFilter: freightFilter,
      serviceFilter: serviceFilter,
      searchField: searchField,
      sortToggle: sortToggle,
    );

    final body = RateTableFitReporter(
      currentPerPage: state.clientRatesPerPage,
      onFit: (fit) => bloc.add(ClientRatesPerPageChanged(fit)),
      builder: (context, availableHeight, fit) =>
        state.clientRatesLoading
        ? buildFittedRateSkeleton(availableHeight)
        : state.filteredClientRates.isEmpty
        ? SizedBox(
            height: availableHeight,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colors.borderStrong,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MrRatrix(size: 96),
                  const SizedBox(height: 4),
                  Text(
                    'No ${state.clientRatesTab.label.toLowerCase()} rates for this client.',
                    style: TextStyle(fontSize: 14, color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
          )
        : ResponsiveRateTable<ClientRate>(
            rates: state.pagedClientRates,
            columns: const [
              RateTableColumn(label: 'MODE', flex: 2, width: 90),
              RateTableColumn(label: 'SERVICE', flex: 2, width: 90),
              RateTableColumn(label: 'ROUTES', flex: 2, width: 90),
              RateTableColumn(label: 'STATUS', flex: 3, width: 130),
            ],
            cellBuilders: [
              (context, rate, {required compact}) => Align(
                alignment: Alignment.centerLeft,
                child: rateModeBadge(context, rate.freightMode),
              ),
              (context, rate, {required compact}) => Text(
                rate.serviceMode.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 12,
                  color: context.colors.textMutedStrong,
                ),
              ),
              (context, rate, {required compact}) => Text(
                '${rate.routeCount} route(s)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 13 : 12,
                  color: context.colors.textMuted,
                ),
              ),
              (context, rate, {required compact}) => Align(
                alignment: Alignment.centerLeft,
                child: rateStatusBadge(
                  context,
                  isActive: rate.status == RateStatus.active,
                  label: rate.expiryLabel,
                ),
              ),
            ],
            chargeCodeOf: (rate) => rate.chargeCode,
            idOf: (rate) => rate.id,
            deletingRateId: state.deletingRateId,
            onEdit: (rate) => bloc.add(EditRateRequested(rate.id)),
            onDelete: (rate) async {
              final confirmed = await showShadDialog<bool>(
                context: context,
                builder: (_) => DeleteRateDialog(chargeCode: rate.chargeCode),
              );
              if (confirmed == true) bloc.add(DeleteRateRequested(rate.id));
            },
          ),
    );

    // Reserved even while loading (just invisible) so the table's measured
    // height doesn't shrink the moment loading finishes and the bar turns
    // visible — that shrink would otherwise overflow the row count already
    // fit against the taller loading-time space.
    final paginationBar = state.clientRatesLoading || state.filteredClientRates.isNotEmpty
        ? Opacity(
            opacity: state.clientRatesLoading ? 0 : 1,
            child: IgnorePointer(
              ignoring: state.clientRatesLoading,
              child: PaginationBar(
                page: state.clientRatePage,
                itemsPerPage: state.clientRatesPerPage,
                totalItems: state.filteredClientRates.length,
                onPageChanged: (p) => bloc.add(ClientRatePageChanged(p)),
              ),
            ),
          )
        : null;

    return MultiBlocListener(
      listeners: [
        BlocListener<RatesShellBloc, RatesShellState>(
          listenWhen: (prev, curr) =>
              curr.deleteRateError != null &&
              prev.deleteRateError != curr.deleteRateError,
          listener: (context, state) {
            showStatusToast(
              context,
              title: 'Delete failed',
              description: state.deleteRateError,
              isError: true,
            );
            bloc.add(const DeleteRateErrorDismissed());
          },
        ),
        BlocListener<RatesShellBloc, RatesShellState>(
          listenWhen: (prev, curr) =>
              curr.deleteRateSucceeded && !prev.deleteRateSucceeded,
          listener: (context, state) {
            showStatusToast(context, title: 'Rate deleted');
            bloc.add(const DeleteRateSuccessDismissed());
          },
        ),
      ],
      child: Breakpoints.isMobile(context)
          ? CustomClientRatesPageMobile(
              parts: parts,
              body: body,
              paginationBar: paginationBar,
            )
          : CustomClientRatesPageWeb(
              parts: parts,
              body: body,
              paginationBar: paginationBar,
            ),
    );
  }
}

/// Closing beat of the dashboard/custom-rate story: real spotlight + arrow
/// on the actual Create New Rate button, via the same `TutorialCoachMark`
/// mechanics as the rest of the tour. A plain `Positioned` arrow here got
/// clipped by an ancestor somewhere in the header layout and never
/// rendered — `TutorialCoachMark` draws through the root `Overlay`, so it
/// isn't subject to that. The user clicks the real button themselves
/// (no auto-navigate); `CustomRateTour` picks up once `WizardPage` mounts.
class _CreateRateButtonWithHint extends StatefulWidget {
  const _CreateRateButtonWithHint({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_CreateRateButtonWithHint> createState() =>
      _CreateRateButtonWithHintState();
}

class _CreateRateButtonWithHintState extends State<_CreateRateButtonWithHint> {
  final _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // TODO: gate behind a "seen" flag once the story tour end-to-end is
    // confirmed solid — always showing for now so it's retestable every
    // visit without clearing storage, same as the other two tour pieces.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHint());
  }

  void _showHint() {
    if (!mounted) return;
    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'create-new-rate',
          keyTarget: _buttonKey,
          shape: ShapeLightFocus.RRect,
          radius: 10,
          contents: [
            TargetContent(
              // Button sits at the far-right edge of the header — beside it
              // (to the left, where the rest of the row's room is) reads
              // clearer than above/below on a row this narrow.
              align: ContentAlign.left,
              builder: (context, controller) => _CreateRateHintBubble(
                onDone: () {
                  stopTourSpeech();
                  controller.skip();
                },
              ),
            ),
          ],
        ),
      ],
      colorShadow: Colors.black,
      opacityShadow: 0.75,
      paddingFocus: 8,
      hideSkip: true,
      onClickTarget: (_) {},
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _buttonKey,
      child: ShadButton(
        backgroundColor: context.colors.primary,
        hoverBackgroundColor: context.colors.primaryHover,
        leading: const Icon(CupertinoIcons.add, size: 17, color: Colors.white),
        onPressed: widget.onPressed,
        child: const Text('Create New Rate'),
      ),
    );
  }
}

class _CreateRateHintBubble extends StatefulWidget {
  const _CreateRateHintBubble({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_CreateRateHintBubble> createState() => _CreateRateHintBubbleState();
}

class _CreateRateHintBubbleState extends State<_CreateRateHintBubble> {
  static const _body =
      "There it is — click Create New Rate when you're ready to build one.";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => speakTourLine(_body));
  }

  @override
  Widget build(BuildContext context) {
    // `ContentAlign.left`'s box spans the full screen width up to the
    // target — a plain `mainAxisSize.min` Row still gets stretched to that
    // whole tight width, so its default start-alignment packs everything
    // against the screen's left edge instead of next to the target. `end`
    // pins it to the target-adjacent edge instead.
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TourSpeechBubble(
          width: 280,
          title: 'One more step',
          body: _body,
          onSpeak: () => speakTourLine(_body),
          leftLabel: 'Skip',
          onLeft: widget.onDone,
          rightLabel: 'Got it!',
          onRight: widget.onDone,
        ),
        const SizedBox(width: 4),
        Icon(
          CupertinoIcons.arrow_right,
          size: 22,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ],
    );
  }
}
