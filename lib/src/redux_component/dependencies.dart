import '../redux/redux.dart';
import 'basic.dart';

class Dependencies<T> {
  /// 可空
  final Map<String, Dependent<T>>? slots;

  /// 可空
  final Dependent<T>? adapter;

  /// Use [adapter: NoneConn<T>() + Adapter<T>()] instead of [adapter: Adapter<T>()],
  /// Which is better reusability and consistency.
  Dependencies({
    this.slots,
    this.adapter,
  }) : assert(adapter == null || adapter.isAdapter(),
            'The dependent must contains adapter.');

  /// 可空 combine_reducers.dart#32
  Reducer<T>? createReducer() {
    final List<SubReducer<T>> subs = <SubReducer<T>>[];
    if (slots?.isNotEmpty == true) {
      for (final MapEntry<String, Dependent<T>> entry in slots!.entries) {
        final SubReducer<T>? subReducer = entry.value.createSubReducer();
        if (subReducer != null) {
          subs.add(subReducer);
        }
      }
    }

    if (adapter != null) {
      final SubReducer<T>? subReducer = adapter?.createSubReducer();
      if (subReducer != null) {
        subs.add(subReducer);
      }
    }

    return combineReducers(<Reducer<T>>[combineSubReducers(subs)]);
  }

  /// 可空
  Dependent<T>? slot(String type) {
    if (slots != null && slots?.isNotEmpty == true) {
      return slots![type];
    }
    return null;
  }

  /// 可空
  Dependencies<T>? trim() =>
      adapter != null || slots?.isNotEmpty == true ? this : null;
}
