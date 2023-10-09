import 'package:fish_redux_ns/fish_redux.dart';

import 'effect.dart';
import 'flow_adapter/adapter.dart';
import 'reducer.dart';
import 'report_component/component.dart';
import 'state.dart';

import 'view.dart';

class ToDoListPage extends Page<PageState, Map<String, dynamic>> {
  ToDoListPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          dependencies: Dependencies<PageState>(
              adapter: const NoneConn<PageState>() +
                  adapter, //NoneConn<PageState>() + ToDoListAdapter(),
              slots: <String, Dependent<PageState>>{
                'report': ReportConnector(
                        get: (ReportConnector connector, PageState state) =>
                            connector.computed(state)) +
                    ReportComponent()
              }),


          // middleware: <Middleware<PageState>>[
          //   logMiddleware(tag: 'ToDoListPage'),
          // ],
        );
}
