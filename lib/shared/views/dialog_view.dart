import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/shared/view_models/home_view_model.dart';

// 关闭确认弹窗
void showCloseDialog(BuildContext context, HomeViewModel homeViewModel) {
  showDialog(
    context: context,
    builder:
        (_) => ContentDialog(
          title: const Center(child: Text('是否关闭?')),
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('请确认你的信息全部保存，避免数据丢失！')],
          ),
          actions: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FilledButton(
                child: const Text('确认'),
                onPressed: () => homeViewModel.confirmClose(context, true),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FilledButton(
                child: const Text('取消'),
                onPressed: () => homeViewModel.confirmClose(context, false),
              ),
            ),
          ],
        ),
  );
}
