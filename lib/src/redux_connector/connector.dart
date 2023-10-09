import '../redux/redux.dart';

import 'op_mixin.dart';

class ConnOp<T, P, TConnector> extends MutableConn<T, P>
    with ConnOpMixin<T, P> {
  final P Function(TConnector, T) _getter;
  final void Function(T, P)? _setter;

  const ConnOp({
    required P Function(TConnector, T) get,
    void Function(T, P)? set,
  })  : _getter = get,
        _setter = set;

  @override
  P get(T state) => _getter.call(this as TConnector, state);

  @override
  void set(T state, P subState) => _setter?.call(state, subState);
}
