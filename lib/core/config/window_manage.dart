import 'package:auto_updater/auto_updater.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

class MyUpdaterListener implements UpdaterListener {
  @override
  void onUpdaterUpdateDownloaded(AppcastItem? appcastItem) async {
    debugPrint('Update downloaded: ${appcastItem?.versionString}');
    // 在这里调用安装更新逻辑
  }

  @override
  void onUpdaterError(UpdaterError? error) {
    debugPrint('Updater error: ${error?.message}');
  }

  @override
  void onUpdaterCheckingForUpdate(Appcast? appcast) {
    debugPrint('Checking for updates...');
  }

  @override
  void onUpdaterUpdateAvailable(AppcastItem? appcastItem) {
    debugPrint('Update available: ${appcastItem?.versionString}');
  }

  @override
  void onUpdaterUpdateNotAvailable(UpdaterError? error) {
    debugPrint('No updates available.');
  }

  @override
  Future<void> onUpdaterBeforeQuitForUpdate(AppcastItem? appcastItem) async {
    await windowManager.setPreventClose(false);
    await windowManager.close();
    debugPrint('Before quit for update.');
  }
}
