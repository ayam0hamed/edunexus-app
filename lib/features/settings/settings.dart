import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        shadowColor: Color.fromARGB(255, 94, 92, 95),
        title: const Text(
          "Settings",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF163D69),
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SectionTitle(title: "Account"),
            SettingsCard(
              children: [
                SettingsTile(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  icon: Icons.person_outline,
                  title: "Profile",
                ),
                SettingsTile(
                  onTap: () => Navigator.pushNamed(context, '/change-password'),
                  icon: Icons.lock_outline,
                  title: "Change Password",
                ),
                SettingsTile(
                  onTap: () => Navigator.pushNamed(context, '/connected-apps'),
                  icon: Icons.flash_on_sharp,
                  title: "Connected Apps",
                ),
              ],
            ),

            const SizedBox(height: 20),

            const SectionTitle(title: "Support & About"),
            SettingsCard(
              children: [
                SettingsTile(
                  onTap: () =>
                      Navigator.pushNamed(context, '/language-preferences'),
                  icon: Icons.language,
                  title: "Language & Preferences",
                ),
                SettingsTile(
                  onTap: () =>
                      Navigator.pushNamed(context, '/privacy-settings'),
                  icon: Icons.privacy_tip,
                  title: "Privacy Settings",
                ),
                SettingsTile(
                  onTap: () => Navigator.pushNamed(context, '/help-support'),
                  icon: Icons.help_outline,
                  title: "Help & Support",
                ),
              ],
            ),

            const SizedBox(height: 20),

            const SectionTitle(title: "Actions"),
            SettingsCard(
              h: 142,
              children: [
                SettingsTile(
                  onTap: () => Navigator.pushNamed(context, '/report-problem'),
                  icon: Icons.flag_outlined,
                  title: "Report a Problem",
                ),
                SettingsTile(
                  onTap: () => Navigator.pushNamed(context, '/logout'),

                  icon: Icons.logout_sharp,
                  title: "Log out",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final double h;
  const SettingsCard({super.key, required this.children, this.h = 203});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: h,
      width: 347,
      decoration: BoxDecoration(
        color: Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF2F6FC),
        borderRadius: BorderRadius.circular(6),
      ),
      width: 300,
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
