import 'package:carabaobillingapps/constant/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoCut = false;
  bool _sound = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings from SharedPreferences
  void _loadSettings() async {
    FlutterRingtonePlayer().stop();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoCut = prefs.getBool('auto_cut') ?? false;
      _sound = prefs.getBool('sound') ?? false;
    });
  }

  // Save settings to SharedPreferences
  void _saveSettings(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.primary, // Custom color for AppBar
        title: Text(
          'Settings',
          style: GoogleFonts.roboto(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "General Settings",
              style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.primary),
            ),
            const Divider(
              color: ColorConstant.primary,
              thickness: 1,
              height: 20,
            ),
            const SizedBox(height: 10),
            _buildSwitchTile(
              title: "Auto Stop",
              subtitle: "Automatically stop orders when time runs out",
              value: _autoCut,
              icon: Icons.cut,
              onChanged: (bool value) {
                setState(() {
                  _autoCut = value;
                  _saveSettings('auto_cut', value);
                });
              },
            ),
            _buildSwitchTile(
              title: "Sound",
              subtitle: "Play sound notifications for important events",
              value: _sound,
              icon: Icons.volume_up,
              onChanged: (bool value) {
                setState(() {
                  _sound = value;
                  _saveSettings('sound', value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to build switch list tiles with icons and subtitle
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, color: ColorConstant.primary, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                        fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: ColorConstant.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
