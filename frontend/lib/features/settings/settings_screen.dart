import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme.dart';
import 'package:persona_mirror/core/glass_container.dart';
import 'package:persona_mirror/core/widgets/premium_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      _buildProfileSection(user),
                      const SizedBox(height: 40),
                      _buildSettingsGroup('HESAP', [
                        _SettingRow(icon: Icons.person_outline_rounded, title: 'Profili Düzenle', color: AppTheme.accentViolet),
                        _SettingRow(icon: Icons.notifications_none_rounded, title: 'Bildirimler', color: AppTheme.accentSky),
                        _SettingRow(icon: Icons.lock_outline_rounded, title: 'Güvenlik ve Gizlilik', color: AppTheme.accentTeal),
                      ]),
                      const SizedBox(height: 24),
                      _buildSettingsGroup('DESTEK VE BİLGİ', [
                        _SettingRow(icon: Icons.help_outline_rounded, title: 'Yardım Merkezi', color: AppTheme.accentCoral),
                        _SettingRow(icon: Icons.info_outline_rounded, title: 'Hakkımızda', color: AppTheme.accentPurple),
                        _SettingRow(icon: Icons.description_outlined, title: 'Kullanım Koşulları', color: AppTheme.textTertiary),
                      ]),
                      const SizedBox(height: 40),
                      _buildLogoutButton(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.textPrimary),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Ayarlar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(User? user) {
    final email = user?.email ?? 'misafir@persona.com';
    final name = email.split('@')[0].toUpperCase();

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.accentViolet.withValues(alpha: 0.2), AppTheme.accentSky.withValues(alpha: 0.2)],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: AppTheme.accentViolet.withValues(alpha: 0.05),
                  child: Text(
                    name[0],
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.accentViolet),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppTheme.accentViolet, shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textTertiary, letterSpacing: 1.2),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) context.go('/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        foregroundColor: AppTheme.statusError,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.statusError.withValues(alpha: 0.2)),
        ),
        elevation: 0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 20),
          SizedBox(width: 12),
          Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SettingRow({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title, 
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 24),
      onTap: () {
        if (title == 'Profili Düzenle') {
          context.push('/edit-profile');
        }
      },
    );
  }
}

