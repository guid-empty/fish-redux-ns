import 'package:fish_redux_ns/fish_redux.dart';

import '../state.dart';
import '../todo_component/component.dart';

class ToDoConnector extends ConnOp<PageState, ToDoState, ToDoConnector> {
  ToDoConnector({required this.index})
      : super(
            get: (ToDoConnector connector, PageState page) =>
                _reduceState(connector, page));

  final int index;

  @override
  ToDoState get(PageState state) {
    return _reduceState(this, state);
  }

  static ToDoState _reduceState(ToDoConnector connector, PageState state) {
    if (state.toDos == null || connector.index >= state.toDos!.length) {
      return ToDoState(isEmpty: true);
    }
    return state.toDos![connector.index];
  }

  @override
  void set(PageState state, ToDoState subState) {
    state.toDos![index] = subState;
  }
}
