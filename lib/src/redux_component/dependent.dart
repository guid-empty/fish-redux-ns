import 'package:fish_redux_ns/fish_redux.dart';
import 'package:flutter/widgets.dart' hide Action, Page;

class _Dependent<T, P> implements Dependent<T> {
  final AbstractConnector<T, P> connector;
  final AbstractLogic<P> logic;

  /// 依据：[dependent.dart#21]
  /// 可空
  late final SubReducer<T>? subReducer;

  _Dependent({
    required this.logic,
    required this.connector,
  }) {
    final Reducer<P>? reducer = logic.createReducer();
    subReducer = reducer != null ? connector.subReducer(reducer) : null;
  }

  @override
  SubReducer<T>? createSubReducer() => subReducer;

  @override
  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    required DispatchBus bus,
    required Enhancer<Object> enhancer,
  }) {
    assert(isComponent(), 'Unexpected type of ${logic.runtimeType}.');
    final AbstractComponent<P> component = logic as AbstractComponent<P>;
    return component.buildComponent(
      store,

      /// todo(不确定)
      () => connector.get(getter())!,
      bus: bus,
      enhancer: enhancer,
    );
  }

  @override
  ListAdapter? buildAdapter(ContextSys<Object> ctx) {
    assert(isAdapter(), 'Unexpected type of ${logic.runtimeType}.');
    final AbstractAdapter<P> adapter = logic as dynamic;
    return adapter.buildAdapter(ctx as dynamic);
  }

  @override
  Get<P?> subGetter(Get<T> getter) {
    return () => connector.get(getter())!;
  }

  @override
  ContextSys<Object> createContext(
    Store<Object> store,
    BuildContext buildContext,
    Get<T> getState, {
    required DispatchBus bus,
    required Enhancer<Object> enhancer,
  }) {
    return logic.createContext(
      store,
      buildContext,
      subGetter(getState) as dynamic,
      bus: bus,
      enhancer: enhancer,
    ) as ContextSys<Object>;
  }

  @override
  bool isComponent() => logic is AbstractComponent;

  @override
  bool isAdapter() => logic is AbstractAdapter;

  @override
  Object key(T state) {
    return Tuple3<Type, Type, Object>(
      logic.runtimeType,
      connector.runtimeType,

      ///todo(不确定)
      logic.key(connector.get(state)!),
    );
  }
}

/// 可空
Dependent<K>? createDependent<K, T>(
    AbstractConnector<K, T> connector, AbstractLogic<T> logic) {
  return _Dependent<K, T>(connector: connector, logic: logic);
}
