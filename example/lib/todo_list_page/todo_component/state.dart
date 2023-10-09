import 'package:fish_redux_ns/fish_redux.dart';
// import 'package:uuid/uuid.dart';

class ToDoState implements Cloneable<ToDoState> {
  String? uniqueId;
  String? title;
  String? desc;
  bool isDone;
  bool isEmpty;

  static int _seed = 202103051044;

  ToDoState({
    this.uniqueId,
    this.title,
    this.desc,
    this.isDone = false,
    this.isEmpty = false,
  }) {
    uniqueId ??= '${_seed++}';
  }

  @override
  ToDoState clone() {
    return ToDoState()
      ..uniqueId = uniqueId
      ..title = title
      ..desc = desc
      ..isEmpty = isEmpty
      ..isDone = isDone;
  }

  @override
  String toString() =>
      'ToDoState{uniqueId: $uniqueId, title: $title, desc: $desc, isDone: $isDone}';
}
