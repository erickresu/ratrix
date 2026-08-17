import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/rates_enums.dart';
import '../bloc/rates_shell_bloc.dart';
import '../rates_colors.dart';

class RatesSidebar extends StatelessWidget {
  const RatesSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RatesShellBloc>();
    final state = context.watch<RatesShellBloc>().state;

    final isDashboard = state.view == RatesView.dashboard;
    final isPublishActive = state.view == RatesView.create && state.rateChoice == RateType.published;
    final isCustomActive = state.view == RatesView.customClients ||
        state.view == RatesView.customClientRates ||
        (state.view == RatesView.create && state.rateChoice == RateType.custom);

    return Container(
      width: 272,
      color: RatesColors.sidebarBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          _Logo(),
          const SizedBox(height: 24),
          _NavItem(
            icon: CupertinoIcons.house,
            label: 'Home',
            active: isDashboard,
            onTap: () => bloc.add(const RatesHomeRequested()),
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
                      onTap: () => bloc.add(const PublishedRateChosen()),
                    ),
                    _SubNavItem(
                      icon: CupertinoIcons.list_bullet,
                      label: 'Custom Rates',
                      active: isCustomActive,
                      onTap: () => bloc.add(const CustomClientsRequested()),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(CupertinoIcons.cube_box, size: 15, color: Colors.white.withValues(alpha: 0.35)),
                const SizedBox(width: 10),
                Text(
                  'Shipping Calculator',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: Column(
              children: [
                _NotificationsRow(),
                const SizedBox(height: 4),
                _ProfileBlock(state: state, bloc: bloc),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: RatesColors.primary, width: 2),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CERRO',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.8),
            ),
            const Text(
              'RATRIX',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
            ),
          ],
        ),
      ],
    );
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: active ? RatesColors.primary : Colors.transparent,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Icon(icon, size: 13, color: active ? RatesColors.primary : Colors.white.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: active ? RatesColors.primary : Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
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
              decoration: const BoxDecoration(color: RatesColors.primary, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.state, required this.bloc});

  final RatesShellState state;
  final RatesShellBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => bloc.add(const ProfileMenuToggled()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: state.profileMenuOpen ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: RatesColors.primaryChipBg, shape: BoxShape.circle),
                    child: const Text('AU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RatesColors.primaryDeep)),
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
                    turns: state.profileMenuOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(CupertinoIcons.chevron_down, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.profileMenuOpen)
          Positioned(
            left: 0,
            right: 0,
            bottom: 52,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: RatesColors.sidebarPanelBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MenuRow(label: 'View profile', color: Colors.white.withValues(alpha: 0.8)),
                  _MenuRow(
                    label: 'Log out',
                    color: const Color(0xFFFF8A8A),
                    bold: true,
                    onTap: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
                  ),
                ],
              ),
            ),
          ),
      ],
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
