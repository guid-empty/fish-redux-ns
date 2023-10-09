import 'basic.dart';

/// Combine an iterable of SubReducer<T> into one Reducer<T>
/// 可空
Reducer<T> combineSubReducers<T>(Iterable<SubReducer<T>> subReducers) {
  if (subReducers.isEmpty) {
    return (T state, Action action) => state;
  }

  if (subReducers.length == 1) {
    final SubReducer<T> single = subReducers.first;
    return (T state, Action action) => single.call(state, action, false);
  }

  return (T state, Action action) {
    late T _copy;
    bool hasChanged = false;
    for (SubReducer<T> subReducer in subReducers) {
      _copy = subReducer.call(state, action, hasChanged);
      hasChanged = hasChanged || _copy != state;
    }
    return _copy;
  };
}

/// Combine an iterable of Reducer<T> into one Reducer<T>
/// 可空
Reducer<T> combineReducers<T>(Iterable<Reducer<T>> reducers) {
  if (reducers.isEmpty) {
    return (T state, Action action) => state;
  }

  if (reducers.length == 1) {
    return reducers.single;
  }

  return (T state, Action action) {
    T nextState = state;
    for (Reducer<T> reducer in reducers) {
      final T _nextState = reducer.call(nextState, action);
      nextState = _nextState!;
    }
    return nextState;
  };
}

/// Convert a super Reducer<Sup> to a sub Reducer<Sub>
/// 可空
Reducer<Sub>? castReducer<Sub extends Sup, Sup>(Reducer<Sup>? sup) {
  return sup == null
      ? null
      : (Sub state, Action action) {
          final Sub result = sup(state, action) as dynamic;
          return result;
        };
}
