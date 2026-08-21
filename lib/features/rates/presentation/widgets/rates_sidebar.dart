import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';

class RatesSidebar extends StatelessWidget {
  const RatesSidebar({super.key, this.onNavigated});

  /// Called after a nav tap dispatches its event — closes the
  /// `AdvancedDrawer` on the compact layout. Left null on desktop, where the
  /// sidebar is inline and there's nothing to close.
  final VoidCallback? onNavigated;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;

    final isDashboard = state.view == RatesView.dashboard;
    final isPublishActive = state.view == RatesView.publishedRates ||
        (state.view == RatesView.create && state.rateChoice == RateType.published);
    final isCustomActive = state.view == RatesView.customClients ||
        state.view == RatesView.customClientRates ||
        (state.view == RatesView.create && state.rateChoice == RateType.custom);
    final isCalculatorActive =
        state.view == RatesView.shippingCalculatorClients || state.view == RatesView.shippingCalculatorForm;

    void navigate(void Function() dispatch) {
      dispatch();
      onNavigated?.call();
    }

    return Container(
      color: RatesColors.dark.sidebarBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Logo(),
          const SizedBox(height: 24),
          _NavItem(
            icon: CupertinoIcons.house,
            label: 'Home',
            active: isDashboard,
            onTap: () => navigate(() => bloc.add(const RatesHomeRequested())),
          ),
          const SizedBox(height: 4),
          _NavParent(
            open: state.ratesMenuOpen,
            onToggle: () => bloc.add(const RatesMenuToggled()),
          ),
          if (state.ratesMenuOpen) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Container(
                padding: const EdgeInsets.only(left: 14),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0x1AFFFFFF))),
                ),
                child: Column(
                  children: [
                    _SubNavItem(
                      icon: CupertinoIcons.arrow_up,
                      label: 'Publish Rates',
                      active: isPublishActive,
                      onTap: () => navigate(() => bloc.add(const PublishedRatesRequested())),
                    ),
                    _SubNavItem(
                      icon: CupertinoIcons.list_bullet,
                      label: 'Custom Rates',
                      active: isCustomActive,
                      onTap: () => navigate(() => bloc.add(const CustomClientsRequested())),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          _NavItem(
            icon: Icons.local_shipping_rounded,
            label: 'Shipping Calculator',
            active: isCalculatorActive,
            onTap: () => navigate(() => bloc.add(const ShippingCalculatorRequested())),
          ),
          const Spacer(),
          const _ThemeToggleRow(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: Column(
              children: [
                // Notifications row hidden for the meantime. Re-enable when needed:
                // _NotificationsRow(),
                // const SizedBox(height: 4),
                _ProfileBlock(state: state, bloc: bloc),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleRow extends StatelessWidget {
  const _ThemeToggleRow();

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeCubit>().state;
    final isDark = mode == ThemeMode.dark;

    return AnimatedPressable(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.read<ThemeCubit>().toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text('Theme', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Switch(
              value: isDark,
              onChanged: (_) => context.read<ThemeCubit>().toggle(),
              thumbIcon: WidgetStateProperty.resolveWith((states) {
                final on = states.contains(WidgetState.selected);
                return Icon(
                  on ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                  size: 14,
                  color: on ? RatesColors.dark.primary : const Color(0xFFB45309),
                );
              }),
              activeTrackColor: RatesColors.dark.primarySoftBg,
              activeThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              inactiveThumbColor: Colors.white,
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The asset's own canvas is solid black (no alpha), so it only blends
    // seamlessly against a black/near-black background — fine here since
    // the sidebar is always `RatesColors.dark.sidebarBg` regardless of theme.
    return Image.asset('assets/images/ratrix_logo.png', height: 72);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? RatesColors.dark.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: active ? Colors.white : Colors.white.withValues(alpha: 0.75)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavParent extends StatelessWidget {
  const _NavParent({required this.open, required this.onToggle});

  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(8),
      onTap: onToggle,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.bars, size: 14, color: Colors.white.withValues(alpha: 0.75)),
                  const SizedBox(width: 12),
                  Text('Rates', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              AnimatedRotation(
                turns: open ? 0 : -0.25,
                duration: const Duration(milliseconds: 150),
                child: Icon(CupertinoIcons.chevron_down, size: 16, color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
        ),
    );
  }
}

class _SubNavItem extends StatelessWidget {
  const _SubNavItem({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Icon(icon, size: 13, color: active ? RatesColors.dark.primary : Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: active ? RatesColors.dark.primary : Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.bell, size: 15, color: Colors.white.withValues(alpha: 0.75)),
              const SizedBox(width: 10),
              Text('Notifications', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          Positioned(
            left: 15,
            top: -1,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: RatesColors.dark.primary, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile toggle button with a dropdown menu (View profile / Log out).
///
/// The menu renders on the root [Overlay] via [CompositedTransformFollower]
/// instead of a plain [Stack]+[Positioned] — the previous version nested the
/// dropdown in a [Stack] sized to the profile button itself, which made its
/// hit-test area unreliable (taps landed on whatever painted beneath it).
/// Overlay entries are always full top-level render objects, so this
/// guarantees the menu is actually clickable regardless of surrounding
/// layout.
class _ProfileBlock extends StatefulWidget {
  const _ProfileBlock({required this.state, required this.bloc});

  final RatesShellState state;
  final RatesShellBloc bloc;

  @override
  State<_ProfileBlock> createState() => _ProfileBlockState();
}

class _ProfileBlockState extends State<_ProfileBlock> {
  final _link = LayerLink();
  OverlayEntry? _entry;

  @override
  void didUpdateWidget(covariant _ProfileBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.profileMenuOpen && _entry == null) {
      // Overlay.insert() marks the Overlay dirty; doing that synchronously
      // here would run mid-build (didUpdateWidget fires during the parent's
      // build), which Flutter forbids. Defer to the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.state.profileMenuOpen && _entry == null) _open();
      });
    } else if (!widget.state.profileMenuOpen && _entry != null) {
      _close();
    }
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  void _open() {
    final authBloc = context.read<AuthBloc>();
    _entry = OverlayEntry(
      // Overlay's internal Stack hands every entry tight, full-screen
      // constraints — without this Align, the follower's child would get
      // force-stretched to fill the viewport instead of shrink-wrapping to
      // its own content. Align eats the tight constraints and lets the
      // child size itself naturally.
      builder: (_) => Align(
        alignment: Alignment.topLeft,
        child: CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.bottomLeft,
          offset: const Offset(0, -8),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 232,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: RatesColors.dark.sidebarPanelBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // _MenuRow(
                  //   label: 'View profile',
                  //   color: Colors.white.withValues(alpha: 0.8),
                  //   onTap: () => widget.bloc.add(const ProfileMenuToggled()),
                  // ),
                  _MenuRow(
                    label: 'Log out',
                    color: const Color(0xFFFF8A8A),
                    bold: true,
                    onTap: () {
                      widget.bloc.add(const ProfileMenuToggled());
                      authBloc.add(const AuthSignOutRequested());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.bloc.add(const ProfileMenuToggled()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: widget.state.profileMenuOpen ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: RatesColors.dark.primaryChipBg, shape: BoxShape.circle),
                  child: Text('AU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RatesColors.dark.primaryDeep)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Admin User', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('Administrator', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: widget.state.profileMenuOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(CupertinoIcons.chevron_down, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.color, this.bold = false, this.onTap});

  final String label;
  final Color color;
  final bool bold;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap ?? () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w600 : FontWeight.w500, color: color)),
        ),
      ),
    );
  }
}
