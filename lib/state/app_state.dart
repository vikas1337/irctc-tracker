import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _favorites = (_prefs.getStringList(_kFav) ?? []).toSet();
    _recent = _prefs.getStringList(_kRecent) ?? [];
    final mode = _prefs.getString(_kTheme);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == mode,
      orElse: () => ThemeMode.system,
    );
  }

  static const _kFav = 'favorite_trains';
  static const _kRecent = 'recent_trains';
  static const _kTheme = 'theme_mode';

  final SharedPreferences _prefs;
  late Set<String> _favorites;
  late List<String> _recent;
  late ThemeMode _themeMode;

  List<String> get favorites => _favorites.toList();
  List<String> get recent => _recent;
  ThemeMode get themeMode => _themeMode;

  bool isFavorite(String number) => _favorites.contains(number);

  void toggleFavorite(String number) {
    if (!_favorites.add(number)) _favorites.remove(number);
    _prefs.setStringList(_kFav, _favorites.toList());
    notifyListeners();
  }

  void pushRecent(String number) {
    _recent.remove(number);
    _recent.insert(0, number);
    if (_recent.length > 8) _recent = _recent.sublist(0, 8);
    _prefs.setStringList(_kRecent, _recent);
    notifyListeners();
  }

  void clearRecent() {
    _recent = [];
    _prefs.setStringList(_kRecent, _recent);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setString(_kTheme, mode.name);
    notifyListeners();
  }
}
