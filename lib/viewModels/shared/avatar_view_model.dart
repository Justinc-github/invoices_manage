import 'package:fluent_ui/fluent_ui.dart';
import 'package:management_invoices/models/repositories/avatar_repositiory.dart';

class AvatarViewModel extends ChangeNotifier {
  final AvatarRepository _avatarRepository;
  bool _isLoading = false;
  String? _avatarUser;
  String? _error;

  AvatarViewModel(this._avatarRepository);

  bool get isLoading => _isLoading;
  String? get avatarUser => _avatarUser;
  String? get error => _error;

  Future<void> uploadAvatar() async {
    _isLoading = true;
    notifyListeners();
    // debugPrint(_avatarRepository.uploadAvatar('1').toString());
    try {
      _avatarUser = await _avatarRepository.uploadAvatar('1');
      debugPrint(_avatarUser);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
