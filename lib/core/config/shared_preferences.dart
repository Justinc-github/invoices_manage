import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._();
  factory AppPreferences() => _instance;
  AppPreferences._();

  final ValueNotifier<String?> _avatarNotifier = ValueNotifier(null);

  ValueNotifier<String?> get avatarNotifier => _avatarNotifier;

  Future<void> setAvatar(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar', url);
    _avatarNotifier.value = url; // 触发通知
  }
}
