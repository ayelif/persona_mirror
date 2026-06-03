import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/features/dashboard/views/home_view.dart';
import 'package:persona_mirror/features/dashboard/views/discovery_view.dart';
import 'package:persona_mirror/features/dashboard/views/reports_view.dart';
import 'package:persona_mirror/core/widgets/premium_background.dart';
import 'package:persona_mirror/core/di/scenario_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(statsProvider);
      ref.invalidate(scenariosProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      const DiscoveryView(),
      const HomeView(),
      const ReportsView(),
    ];

    return Scaffold(
      extendBody: true,
      body: PremiumBackground(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: views.map((view) => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: view,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton.extended(
        onPressed: () => context.push('/create-scenario'),
        backgroundColor: AppTheme.accentViolet,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Yeni Prova', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack) : null,
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Persona',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Mirror',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w300,
                color: AppTheme.accentViolet,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(35),
        boxShadow: AppTheme.shadowLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.explore_rounded, 'Keşfet'),
            _buildNavItem(1, Icons.home_rounded, 'Ana Sayfa'),
            _buildNavItem(2, Icons.analytics_rounded, 'Analizler'),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 1, end: 0);
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 2) {
          ref.invalidate(statsProvider);
        } else if (index == 1) {
          ref.invalidate(scenariosProvider);
          ref.invalidate(statsProvider);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentViolet.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentViolet : AppTheme.textTertiary,
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.accentViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ).animate().fadeIn().scale(alignment: Alignment.centerLeft),
            ],
          ],
        ),
      ),
    );
  }
}

