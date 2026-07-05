import 'package:flutter/material.dart';
import 'package:grad_project/features/widgets/button.dart';

// ─── Data ────────────────────────────────────────────────────────────────────

class Language {
  final String name;
  final String nativeName;
  const Language(this.name, this.nativeName);
}

const List<Language> kLanguages = [
  Language('English', 'English'),
  Language('Arabic', 'عربي'),
  Language('Spanish', 'Español'),
  Language('French', 'Français'),
  Language('German', 'Deutsch'),
  Language('Italian', 'Italiano'),
];

const List<String> kTimezones = [
  '(UTC+01:00) Casablanca',
  '(UTC+02:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna',
  '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague',
  '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris',
  '(UTC+03:00) Sarajevo, Skopje, Warsaw, Zagreb',
  '(UTC+00:00) West Central Africa',
  '(UTC+02:00) Athens, Bucharest',
  '(UTC+02:00) Beirut',
  '(UTC+02:00) Africa/Cairo',
  '(UTC+02:00) Chisinau',
  '(UTC+02:00) Gaza, Hebron',
  '(UTC+03:00) Harare, Pretoria',
  '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius',
  '(UTC+02:00) Jerusalem',
  '(UTC-08:00) Pacific Time (US & Canada)',
  '(UTC-08:00) Baja California',
  '(UTC-07:00) Mountain Time (US & Canada)',
  '(UTC-07:00) Chihuahua, Mazatlan',
  '(UTC-06:00) Central Time (US & Canada)',
  '(UTC-06:00) Guadalajara, Mexico City, Monterrey',
];

// ─── Colors ───────────────────────────────────────────────────────────────────

const kPrimaryBlue = Color(0xFF1A3D8C);
const kAccentOrange = Color(0xFFC95C1A);
const kTextDark = Color(0xFF1A2744);
const kTextMuted = Color(0xFF8A93A8);
const kBorderColor = Color(0xFFE8EAF2);
const kActiveBlue = Color(0xFF3A5BAB);
const kActiveBg = Color(0xFFEEF2FF);

// ─── Main Screen ──────────────────────────────────────────────────────────────

class LanguagePreferencesScreen extends StatefulWidget {
  const LanguagePreferencesScreen({super.key});

  @override
  State<LanguagePreferencesScreen> createState() =>
      _LanguagePreferencesScreenState();
}

class _LanguagePreferencesScreenState extends State<LanguagePreferencesScreen> {
  int _selectedLangIndex = 0;
  String _selectedTimezone = '(UTC+02:00) Africa/Cairo';

  void _openTimezonePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimezonePickerSheet(
        selected: _selectedTimezone,
        onSelected: (tz) {
          setState(() => _selectedTimezone = tz);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),
                    _buildSectionLabel('Display Language'),
                    _buildLanguageList(),
                    _buildSectionLabel('Time Zone'),
                    _buildTimezoneSelector(),
                    const SizedBox(height: 24),
                    GradientButton(
                      width: 365,
                      height: 48,
                      borderRadius: 10,
                      onPressed: () {},
                      text: "Save Chsnges",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: kPrimaryBlue, size: 26),
            onPressed: () {},
          ),
          Text(
            'Language & Preferences',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Page Header ────────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌐', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Language & Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Choose your preferred language and regional preferences',
                style: TextStyle(fontSize: 12, color: kTextMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kActiveBlue,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Language List ──────────────────────────────────────────────────────────

  Widget _buildLanguageList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: List.generate(kLanguages.length, (i) {
          final lang = kLanguages[i];
          final isActive = i == _selectedLangIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedLangIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isActive ? kActiveBg : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? kActiveBlue : kBorderColor,
                  width: isActive ? 1.8 : 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang.nativeName,
                        style: const TextStyle(fontSize: 11, color: kTextMuted),
                      ),
                    ],
                  ),
                  if (isActive)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: kActiveBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Timezone Selector ──────────────────────────────────────────────────────

  Widget _buildTimezoneSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: _openTimezonePicker,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedTimezone,
                  style: const TextStyle(fontSize: 13, color: kTextDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: kActiveBlue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CTA Button ─────────────────────────────────────────────────────────────
}

// ─── Timezone Picker Bottom Sheet ─────────────────────────────────────────────

class TimezonePickerSheet extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const TimezonePickerSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<TimezonePickerSheet> createState() => _TimezonePickerSheetState();
}

class _TimezonePickerSheetState extends State<TimezonePickerSheet> {
  late String _current;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _current = widget.selected;
  }

  List<String> get _filtered => _search.isEmpty
      ? kTimezones
      : kTimezones
            .where((tz) => tz.toLowerCase().contains(_search.toLowerCase()))
            .toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5E8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Time Zone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F1F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF5A6275),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search timezone...',
                  hintStyle: const TextStyle(fontSize: 13, color: kTextMuted),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: kTextMuted,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F9FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: kActiveBlue,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // List
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final tz = _filtered[i];
                  final isSelected = tz == _current;
                  return GestureDetector(
                    onTap: () => setState(() => _current = tz),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? kActiveBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? kActiveBlue : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        tz,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? kTextDark
                              : const Color(0xFF3A4060),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Save Button
            GradientButton(
              width: 465,
              height: 48,
              borderRadius: 10,
              onPressed: () {},
              text: "Save Chsnges",
            ),
          ],
        ),
      ),
    );
  }
}
