import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_mirror/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildProfileSection(user),
            const SizedBox(height: 32),
            _buildSettingsGroup('Hesap', [
              _SettingRow(icon: Icons.person_outline_rounded, title: 'Profili Düzenle', color: AppTheme.primaryColor),
              _SettingRow(icon: Icons.notifications_none_rounded, title: 'Bildirimler', color: AppTheme.accentColor),
              _SettingRow(icon: Icons.lock_outline_rounded, title: 'Güvenlik', color: Colors.blueGrey),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup('Destek', [
              _SettingRow(icon: Icons.help_outline_rounded, title: 'Yardım Merkezi', color: Colors.amber),
              _SettingRow(icon: Icons.info_outline_rounded, title: 'Hakkımızda', color: Colors.orange),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(User? user) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, size: 50, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.email?.split('@')[0].toUpperCase() ?? 'KULLANICI',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        Text(
          user?.email ?? 'E-posta yok',
          style: const TextStyle(fontSize: 14, color: AppTheme.mutedTextColor),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.mutedTextColor, letterSpacing: 1.1),
          ),
        ),
        Container(
          decoration: AppTheme.glassDecoration,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) context.go('/login');
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Colors.redAccent, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: Colors.redAccent,
      ),
      child: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.mutedTextColor, size: 20),
      onTap: () {},
    );
  }
}
