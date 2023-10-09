import 'package:fish_redux_ns/fish_redux.dart';

import '../todo_list_page/todo_component/component.dart';
import 'effect.dart';
import 'state.dart';
import 'view.dart';

class TodoEditPage extends Page<TodoEditState, ToDoState> {
  TodoEditPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          view: buildView,


          // middleware: <Middleware<TodoEditState>>[
          //   logMiddleware(tag: 'TodoEditPage'),
          // ],
        );
}
