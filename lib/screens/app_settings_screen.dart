import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() =>
      _AppSettingsScreenState();
}

class _AppSettingsScreenState
    extends State<AppSettingsScreen> {

  bool notifications = true;
  bool sounds = true;
  bool darkMode = true;
  bool aiSuggestions = true;
  bool autoRefresh = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs =
        await SharedPreferences.getInstance();

    setState(() {
      notifications =
          prefs.getBool("notifications") ??
              true;

      sounds =
          prefs.getBool("sounds") ?? true;

      darkMode =
          prefs.getBool("dark_mode") ?? true;

      aiSuggestions =
          prefs.getBool("ai_suggestions") ??
              true;

      autoRefresh =
          prefs.getBool("auto_refresh") ??
              true;
    });
  }

  Future<void> saveSettings() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      "notifications",
      notifications,
    );

    await prefs.setBool(
      "sounds",
      sounds,
    );

    await prefs.setBool(
      "dark_mode",
      darkMode,
    );

    await prefs.setBool(
      "ai_suggestions",
      aiSuggestions,
    );

    await prefs.setBool(
      "auto_refresh",
      autoRefresh,
    );
  }

  Widget buildTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [

          Icon(
            icon,
            color: const Color(0xFF00C8FF),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),

          Switch(
            value: value,
            activeColor:
                const Color(0xFF00C8FF),
            onChanged: (v) async {
              onChanged(v);
              await saveSettings();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          "App Settings",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            buildTile(
              icon:
                  Icons.notifications,
              title: "Notifications",
              value: notifications,
              onChanged: (v) {
                setState(() {
                  notifications = v;
                });
              },
            ),

            buildTile(
              icon: Icons.volume_up,
              title: "Sound Effects",
              value: sounds,
              onChanged: (v) {
                setState(() {
                  sounds = v;
                });
              },
            ),

            buildTile(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              value: darkMode,
              onChanged: (v) {
                setState(() {
                  darkMode = v;
                });
              },
            ),

            buildTile(
              icon: Icons.smart_toy,
              title: "AI Suggestions",
              value: aiSuggestions,
              onChanged: (v) {
                setState(() {
                  aiSuggestions = v;
                });
              },
            ),

            buildTile(
              icon: Icons.refresh,
              title: "Auto Refresh",
              value: autoRefresh,
              onChanged: (v) {
                setState(() {
                  autoRefresh = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}