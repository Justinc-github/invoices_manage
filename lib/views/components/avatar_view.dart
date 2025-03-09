import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:management_invoices/viewModels/shared/avatar_view_model.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarViewModel = context.watch<AvatarViewModel>();
    return Positioned(
      right: 20,
      top: 20,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => avatarViewModel.uploadAvatar(),
          child: CircleAvatar(
            radius: 30,
            backgroundImage:
                avatarViewModel.avatarUser != null &&
                        avatarViewModel.avatarUser!.isNotEmpty
                    ? NetworkImage(avatarViewModel.avatarUser.toString())
                    : const NetworkImage(
                          'https://pic1.imgdb.cn/item/67cd456e066befcec6e1dfe6.jpg',
                        )
                        as ImageProvider,
          ),
        ),
      ),
    );
  }
}
