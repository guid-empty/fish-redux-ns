import 'basic.dart';

StoreEnhancer<T>? applyMiddleware<T>(List<Middleware<T>> middleware) {
  return middleware.isEmpty
      ? null
      : (StoreCreator<T> creator) => (T initState, Reducer<T> reducer) {
            assert(middleware.isNotEmpty);

            final Store<T> store = creator(initState, reducer);
            final Dispatch initialValue = store.dispatch;
            store.dispatch = (Action action) {
              throw Exception(
                  'Dispatching while constructing your middleware is not allowed. '
                  'Other middleware would not be applied to this dispatch.');
            };
            store.dispatch = middleware
                .map((Middleware<T> middleware) => middleware(
                      dispatch: (Action action) => store.dispatch(action),
                      getState: store.getState,
                    ))
                .fold(
                  initialValue,
                  (Dispatch previousValue,
                          Dispatch Function(Dispatch) element) =>
                      element(previousValue),
                );

            return store;
          };
}

StoreEnhancer<T> applyMiddlewareNs<T>(List<Middleware<T>> middleware) {
  return (StoreCreator<T> creator) => (T initState, Reducer<T> reducer) {
        if (middleware.isEmpty) {
          return creator(initState, reducer);
        }

        final Store<T> store = creator(initState, reducer);
        final Dispatch initialValue = store.dispatch;
        store.dispatch = (Action action) {
          throw Exception(
              'Dispatching while constructing your middleware is not allowed. '
              'Other middleware would not be applied to this dispatch.');
        };
        store.dispatch = middleware
            .map((Middleware<T> middleware) => middleware(
                  dispatch: (Action action) => store.dispatch(action),
                  getState: store.getState,
                ))
            .fold(
              initialValue,
              (Dispatch previousValue, Dispatch Function(Dispatch) element) =>
                  element(previousValue),
            );

        return store;
      };
}
