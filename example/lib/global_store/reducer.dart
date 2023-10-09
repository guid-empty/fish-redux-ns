import 'package:fish_redux_ns/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import 'action.dart';
import 'state.dart';

Reducer<GlobalState> buildReducer() {
  return asReducer(
    <Object, Reducer<GlobalState>>{
      GlobalAction.changeThemeColor: _onchangeThemeColor,
    },
  );
}

List<Color> _colors = <Color>[
  Colors.green,
  Colors.red,
  Colors.black,
  Colors.blue
];

GlobalState _onchangeThemeColor(GlobalState state, Action action) {
  if (state.themeColor != null) {
    final Color next =


        _colors[((_colors.indexOf(state.themeColor!) + 1) % _colors.length)];
    return state.clone()..themeColor = next;
  }
  return state.clone();
}
