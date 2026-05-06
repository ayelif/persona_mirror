import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/spacing.dart';
import 'package:persona_mirror/core/radius.dart';
import 'package:persona_mirror/core/glass_container.dart';


class CreateScenarioScreen extends StatefulWidget {
  const CreateScenarioScreen({super.key});

  @override
  State<CreateScenarioScreen> createState() => _CreateScenarioScreenState();
}

class _CreateScenarioScreenState extends State<CreateScenarioScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'İş Dünyası', 'icon': Icons.work_outline_rounded, 'color': AppTheme.accentViolet},
    {'name': 'İlişkiler', 'icon': Icons.favorite_border_rounded, 'color': AppTheme.accentCoral},
    {'name': 'Sosyal', 'icon': Icons.people_outline_rounded, 'color': AppTheme.accentSky},
    {'name': 'Müzakere', 'icon': Icons.gavel_rounded, 'color': AppTheme.accentTeal},
  ];
  
  String _selectedCategory = 'İş Dünyası';
  final _contextController = TextEditingController();

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppLayout.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Kategori Seçin', 'Senaryonun ana temasını belirleyin.'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCategoryGrid(),
                  const SizedBox(height: AppSpacing.x4l),
                  _buildSectionTitle('Senaryo Bağlamı', 'Konuşacağınız kişiyi ve durumu detaylandırın.'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildContextInput(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildTipCard(),
                  const SizedBox(height: AppSpacing.x5l),
                  _buildStartButton(),
                  const SizedBox(height: AppSpacing.x3l),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.bgPrimary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Yeni Senaryo',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Outfit',
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategory == cat['name'];
        return _CategoryCard(
          name: cat['name'],
          icon: cat['icon'],
          color: cat['color'],
          isSelected: isSelected,
          onTap: () => setState(() => _selectedCategory = cat['name']),
        );
      },
    );
  }

  Widget _buildContextInput() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Row(
              children: const [
                Icon(Icons.edit_note_rounded, size: 20, color: AppTheme.textSecondary),
                SizedBox(width: 8),
                Text(
                  'Örn: Patronumla maaş artışı hakkında konuşacağım.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: _contextController,
            maxLines: 8,
            style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Detayları buraya yazın (Karşı taraf kim, ne istiyorsunuz, ortam nasıl?)...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: AppTheme.accentTeal),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'İpucu: Karşı tarafın kişiliğini ne kadar detaylı anlatırsanız, simülasyon o kadar gerçekçi olur.',
              style: TextStyle(fontSize: 12, color: AppTheme.accentTeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        if (_contextController.text.isNotEmpty) {
          context.push('/simulation');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen bir senaryo bağlamı girin.')),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.accentViolet, AppTheme.accentPurple],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.glowViolet,
        ),
        child: const Center(
          child: Text(
            'Simülasyonu Başlat',
            style: TextStyle(
              color: AppTheme.textInverse,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(delay: 400.ms)
    .scale(begin: const Offset(0.9, 0.9));
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppTheme.borderLight,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : AppTheme.shadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
