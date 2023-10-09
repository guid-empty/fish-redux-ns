import 'package:fish_redux_ns/fish_redux.dart';

enum GlobalAction { changeThemeColor }

class GlobalActionCreator {
  static Action onchangeThemeColor() {
    return const Action(GlobalAction.changeThemeColor);
  }
}
