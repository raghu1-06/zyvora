import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _focusModeOn = true;
  bool _hapticOn = true;
  bool _adaptiveOn = true;
  bool _darkThemeOn = false;
  bool _syncOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1B33), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text("Profile", style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
            Text("Manage your account", style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E1B33), size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildUserCard(),
            _buildProductivitySummary(),
            _buildHeatmap(),
            _buildCircadianRhythms(),
            _buildSettingsSections(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text("R", style: TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("raghu", style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
                const SizedBox(height: 2),
                Text("Learning something new everyday.", style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF6B7280))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPill("📅 Member since Jan 2026", const Color(0xFFF3F4F6), const Color(0xFF4B5563)),
                    const SizedBox(width: 8),
                    _buildPill("🎓 Student", const Color(0xFFEDE9FE), const Color(0xFF7C3AED)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: textCol)),
    );
  }

  Widget _buildProductivitySummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _buildStatCard("Tasks completed", "0", "0% done", Icons.check_circle_outline, const Color(0xFFD1FAE5), const Color(0xFF10B981)),
          _buildStatCard("Attendance %", "100%", "3 subjects", Icons.fact_check_outlined, const Color(0xFFEDE9FE), const Color(0xFF7C3AED)),
          _buildStatCard("Current streak", "21", "Days on track", Icons.local_fire_department_outlined, const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
          _buildStatCard("Focus score", "60", "Consistency index", Icons.bolt_outlined, const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, String sub, IconData icon, Color bg, Color iconCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 14, color: iconCol)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B33))),
          Text(sub, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _buildHeatmap() {
    // 5 rows x 15 cols
    final random = Random(42);
    final levels = [const Color(0xFFE5E7EB), const Color(0xFFDDD6FE), const Color(0xFFA78BFA), const Color(0xFF7C3AED), const Color(0xFF5B21B6)];
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Activity Logs", style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
              Text("Last 6 Months", style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: List.generate(5, (r) {
                return Row(
                  children: List.generate(15, (c) {
                    int level = (c > 10 && random.nextBool()) ? random.nextInt(5) : (random.nextInt(10) == 0 ? random.nextInt(3) : 0);
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 2, bottom: 2),
                      decoration: BoxDecoration(color: levels[level], borderRadius: BorderRadius.circular(2)),
                    );
                  }),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text("Less", style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9CA3AF))),
              const SizedBox(width: 4),
              for (var c in levels) Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 8, height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Text("More", style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircadianRhythms() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Peak Focus Window", style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B33))),
          Text("Time of day productivity", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
          const SizedBox(height: 16),
          _buildRhythmRow("🌅", "MORNING", "06:00 - 12:00", 0.7, true, "5 logs"),
          _buildRhythmRow("🌤", "AFTERNOON", "12:00 - 17:00", 0.3, false, ""),
          _buildRhythmRow("🌙", "EVENING", "17:00 - 21:00", 0.1, false, ""),
          _buildRhythmRow("🌑", "NIGHT OWL", "21:00 - 06:00", 0.05, false, ""),
        ],
      ),
    );
  }

  Widget _buildRhythmRow(String emoji, String title, String time, double pct, bool isPeak, String badge) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6B7280))),
                Text(time, style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF9CA3AF))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4))),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(height: 8, decoration: BoxDecoration(color: isPeak ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(4))),
                ),
              ],
            ),
          ),
          if (isPeak) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
              child: Text(badge, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSettingsSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Account"),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.person_outline, bg: const Color(0xFFEDE9FE), iconCol: const Color(0xFF7C3AED), title: "Edit Profile", subtitle: "Name, bio, avatar", isArrow: true),
                const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                _SettingsTile(icon: Icons.workspace_premium_outlined, bg: const Color(0xFFFEF3C7), iconCol: const Color(0xFFF59E0B), title: "Zyvora Pro", subtitle: "Upgrade to premium", isArrow: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Preferences"),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.notifications_outlined, bg: const Color(0xFFCFFAFE), iconCol: const Color(0xFF06B6D4), title: "Notifications", subtitle: "Reminders and alerts", isSwitch: true, switchVal: _notificationsOn, onChanged: (v) => setState(() => _notificationsOn = v)),
                const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                _SettingsTile(icon: Icons.center_focus_strong_outlined, bg: const Color(0xFFFEE2E2), iconCol: const Color(0xFFEF4444), title: "Focus Mode", subtitle: "Silence distractions", isSwitch: true, switchVal: _focusModeOn, onChanged: (v) => setState(() => _focusModeOn = v)),
                const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                _SettingsTile(icon: Icons.vibration, bg: const Color(0xFFE0E7FF), iconCol: const Color(0xFF4F46E5), title: "Haptic Feedback", subtitle: "Vibrations on actions", isSwitch: true, switchVal: _hapticOn, onChanged: (v) => setState(() => _hapticOn = v)),
                const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                _SettingsTile(icon: Icons.dark_mode_outlined, bg: const Color(0xFFF3F4F6), iconCol: const Color(0xFF4B5563), title: "Dark Theme", subtitle: "Easy on the eyes", isSwitch: true, switchVal: _darkThemeOn, onChanged: (v) => setState(() => _darkThemeOn = v)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Data & Backup"),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.cloud_outlined, bg: const Color(0xFFD1FAE5), iconCol: const Color(0xFF10B981), title: "Cloud Sync", subtitle: "Backup your data", isSwitch: true, switchVal: _syncOn, onChanged: (v) => setState(() => _syncOn = v)),
                const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),
                _SettingsTile(icon: Icons.download_outlined, bg: const Color(0xFFE0E7FF), iconCol: const Color(0xFF4F46E5), title: "Export Data", subtitle: "Download to CSV/JSON", isArrow: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Experimental"),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.auto_awesome, bg: const Color(0xFFEDE9FE), iconCol: const Color(0xFF7C3AED), title: "Adaptive Intelligence", subtitle: "Zeni learns from you", isSwitch: true, switchVal: _adaptiveOn, onChanged: (v) => setState(() => _adaptiveOn = v)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Danger Zone", color: const Color(0xFFEF4444)),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFEE2E2))),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.delete_sweep_outlined, bg: const Color(0xFFFEF2F2), iconCol: const Color(0xFFEF4444), title: "Clear Completed Tasks", subtitle: "Cannot be undone", isDestructive: true),
                const Divider(height: 1, indent: 56, color: Color(0xFFFEF2F2)),
                _SettingsTile(icon: Icons.history_toggle_off, bg: const Color(0xFFFEF2F2), iconCol: const Color(0xFFEF4444), title: "Reset Attendance", subtitle: "Wipes all attendance data", isDestructive: true),
                const Divider(height: 1, indent: 56, color: Color(0xFFFEF2F2)),
                _SettingsTile(icon: Icons.logout_rounded, bg: const Color(0xFFFEF2F2), iconCol: const Color(0xFFEF4444), title: "Log Out", subtitle: "Sign out of this device", isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color color = const Color(0xFF6B7280)}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: color)),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        "● Version 1.3.0  |  Built for focused task and attendance tracking.",
        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF)),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color iconCol;
  final String title;
  final String subtitle;
  final bool isSwitch;
  final bool isArrow;
  final bool switchVal;
  final ValueChanged<bool>? onChanged;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.bg,
    required this.iconCol,
    required this.title,
    required this.subtitle,
    this.isSwitch = false,
    this.isArrow = false,
    this.switchVal = false,
    this.onChanged,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconCol, size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF1E1B33))),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
      trailing: isSwitch
          ? Switch(value: switchVal, onChanged: onChanged, activeColor: const Color(0xFF7C3AED))
          : (isArrow ? const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)) : null),
      onTap: isSwitch ? () => onChanged?.call(!switchVal) : () {},
    );
  }
}
