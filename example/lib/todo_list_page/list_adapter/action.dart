import 'package:fish_redux_ns/fish_redux.dart';
import '../todo_component/component.dart';

enum ToDoListAction { add }

class ToDoListActionCreator {
  static Action add(ToDoState state) {
    return Action(ToDoListAction.add, payload: state);
  }
}
