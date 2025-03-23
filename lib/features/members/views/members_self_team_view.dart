import 'package:fluent_ui/fluent_ui.dart';

class MembersSelfTeamView extends StatelessWidget {
  const MembersSelfTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(children: [const Center(child: Text('我的队伍'))]),
    );
  }
}
