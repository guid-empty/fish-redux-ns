import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import 'auto_dispose.dart';
import 'basic.dart';
import 'lifecycle.dart';

mixin _ExtraMixin {
  Map<String, Object>? _extra;

  Map<String, Object> get extra => _extra ??= <String, Object>{};
}

/// Default Context
abstract class LogicContext<T> extends ContextSys<T> with _ExtraMixin {
  final AbstractLogic<T> logic;

  @override
  final Store<Object> store;
  @override
  final DispatchBus bus;
  @override
  final Enhancer<Object> enhancer;

  final Get<T> getState;

  void Function()? _forceUpdate;

  final BuildContext _buildContext;
  late Dispatch _dispatch;
  late Dispatch _effectDispatch;

  LogicContext({
    required this.logic,
    required this.store,
    required BuildContext buildContext,
    required this.getState,

    /// pageBus
    required this.bus,
    required this.enhancer,
  }) : _buildContext = buildContext {
    _effectDispatch = logic.createEffectDispatch(this, enhancer);
    _dispatch = logic.createDispatch(
      _effectDispatch,
      logic.createNextDispatch(
        this,
        enhancer,
      ),
      this,
    );

    /// Register inter-component broadcast
    registerOnDisposed(bus.registerReceiver(_effectDispatch));
  }

  @override
  void bindForceUpdate(void Function() forceUpdate) {
    assert(_forceUpdate == null);
    _forceUpdate = forceUpdate;
  }

  @override
  BuildContext get context => _buildContext;

  @override
  T get state => getState.call();

  @override
  dynamic dispatch(Action action) => _dispatch(action);

  @override
  Widget buildComponent(String name, {Widget? defaultWidget}) {
    final Dependent<T>? dependent = logic.slot(name);
    final Widget? result = dependent?.buildComponent(store, getState,
        bus: bus, enhancer: enhancer);
    assert(result != null || defaultWidget != null,
        'Could not found component by name "$name." You can set a default widget for buildComponent');
    return result ?? (defaultWidget ?? Container());
  }

  @override
  void onLifecycle(Action action) {
    assert(_throwIfDisposed());
    _dispatch(action);
  }

  @override
  void dispose() {
    super.dispose();
    _forceUpdate = null;
  }

  bool _throwIfDisposed() {
    if (isDisposed) {
      throw Exception(
          'Ctx has been disposed which could not been used any more.');
    }
    return true;
  }

  /// 可空
  @override
  State<StatefulWidget>? get stfState {
    assert(_buildContext is StatefulElement);
    if (_buildContext is StatefulElement) {
      final StatefulElement stfElement = _buildContext as StatefulElement;
      return stfElement.state;
    }
    return null;
  }

  @override
  void broadcastEffect(Action action, {bool? excluded}) =>
      bus.dispatch(action, excluded: excluded == true ? _effectDispatch : null);

  @override
  void broadcast(Action action) => bus.broadcast(action);

  @override
  void Function() addObservable(Subscribe observable) {
    final void Function() unsubscribe = observable(() {
      _forceUpdate?.call();
    });
    registerOnDisposed(unsubscribe);
    return unsubscribe;
  }

  @override
  void forceUpdate() => _forceUpdate?.call();

  @override
  void Function() listen({
    /// 可空 #151
    bool Function(T?, T?)? isChanged,
    void Function()? onChange,
  }) {
    assert(onChange != null);
    T? oldState;
    final AutoDispose? disposable = registerOnDisposed(
      store.subscribe(
        () => () {
          final T newState = state;
          final bool flag = isChanged == null
              ? !identical(oldState, newState)
              : isChanged(oldState, newState);
          oldState = newState;
          if (flag) {
            onChange?.call();
          }
        },
      ),
    );

    return () => disposable?.dispose();
  }
}

class ComponentContext<T> extends LogicContext<T> implements ViewUpdater<T> {
  final ViewBuilder<T> view;
  final ShouldUpdate<T> shouldUpdate;
  final String name;
  final Function()? markNeedsBuild;
  final ContextSys<Object>? sidecarCtx;

  /// 可空
  Widget? _widgetCache;
  late T _latestState;

  ComponentContext({
    required AbstractComponent<T> logic,
    required Store<Object> store,
    required BuildContext buildContext,
    required Get<T> getState,
    required this.view,
    required this.shouldUpdate,
    required this.name,
    this.markNeedsBuild,
    required this.sidecarCtx,
    required DispatchBus bus,
    required Enhancer<Object> enhancer,
  }) : super(
          logic: logic,
          store: store,
          buildContext: buildContext,
          getState: getState,
          bus: bus,
          enhancer: enhancer,
        ) {
    _latestState = state;

    sidecarCtx?.setParent(this);
  }

  @override
  void onLifecycle(Action action) {
    super.onLifecycle(action);
    sidecarCtx?.onLifecycle(action);
  }

  @override
  ListAdapter buildAdapter() {
    assert(sidecarCtx != null);
    return logic.adapterDep()?.buildAdapter(sidecarCtx!) ??
        const ListAdapter(null, 0);
  }

  @override
  Widget buildWidget() {
    Widget? result = _widgetCache;
    if (result == null) {
      result = _widgetCache = view(state, dispatch, this);

      dispatch(LifecycleCreator.build(name));
    }
    return result;
  }

  @override
  void didUpdateWidget() {
    final T now = state;
    if (shouldUpdate(_latestState, now)) {
      _widgetCache = null;
      _latestState = now;
    }
  }

  @override
  void onNotify() {
    final T now = state;
    if (shouldUpdate(_latestState, now)) {
      _widgetCache = null;

      markNeedsBuild?.call();

      _latestState = now;
    }
  }

  @override
  void clearCache() {
    _widgetCache = null;
  }

  @override
  void forceUpdate() {
    _widgetCache = null;

    try {
      markNeedsBuild?.call();
    } catch (e) {
      /// TODO
      /// should try-catch in force mode which is called from outside
    }
  }
}

class PureViewViewService implements ViewService {
  final DispatchBus bus;

  @override
  final BuildContext context;

  PureViewViewService(this.bus, this.context);

  @override
  void broadcast(Action action) => bus.broadcast(action);

  @override
  void broadcastEffect(Action action, {bool? excluded}) => bus.dispatch(action);

  @override
  ListAdapter buildAdapter() => throw Exception(
      'Unexpected call of "buildAdapter" in a PureViewComponent');

  @override
  Widget buildComponent(String name, {Widget? defaultWidget}) =>
      throw Exception(
          'Unexpected call of "buildComponent" in a PureViewComponent');

  @override
  Map<String, Object> get extra =>
      throw Exception('Unexpected call of "extra" in a PureViewComponent');
}
