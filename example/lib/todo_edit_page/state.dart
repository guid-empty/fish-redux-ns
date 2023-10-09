import 'package:fish_redux_ns/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import '../global_store/state.dart';
import '../todo_list_page/todo_component/component.dart';

class TodoEditState implements GlobalBaseState, Cloneable<TodoEditState> {
  late ToDoState toDo;

  late TextEditingController nameEditController;
  late TextEditingController descEditController;

  late FocusNode focusNodeName;
  late FocusNode focusNodeDesc;

  @override
  Color? themeColor;

  @override
  TodoEditState clone() {
    return TodoEditState()
      ..nameEditController = nameEditController
      ..descEditController = descEditController
      ..focusNodeName = focusNodeName
      ..focusNodeDesc = focusNodeDesc
      ..toDo = toDo
      ..themeColor = themeColor;
  }
}

TodoEditState initState({ToDoState? args}) {
  final TodoEditState state = TodoEditState();
  state.toDo = args?.clone() ?? ToDoState();
  state.nameEditController = TextEditingController(text: args?.title);
  state.descEditController = TextEditingController(text: args?.desc);
  state.focusNodeName = FocusNode();
  state.focusNodeDesc = FocusNode();

  return state;
}
