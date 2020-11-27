import 'package:flutter/material.dart';

import 'widget_report.dart';

class BaseScaffold extends StatefulWidget {
  final bool showAppBar;
  final String title;
  final List<Widget> actions;
  final Widget body;
  final VoidCallback onRefresh;
  final VoidCallback onReport;
  final VoidCallback onSignOut;

  const BaseScaffold({
    Key key,
    this.showAppBar = true,
    this.title = '',
    this.actions = const <Widget>[],
    this.body,
    this.onRefresh,
    this.onReport,
    this.onSignOut,
  }) : super(key: key);

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  void _bugReporting() async {
    if (this.widget.onReport != null) this.widget.onReport();
    bool done = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return WidgetReport();
      },
    );
    if (done == null ? true : !done) return;
    _key.currentState.showSnackBar(
      SnackBar(
        content: Text('thanks for reporting'),
      ),
    );
  }

  List<Widget> _actions() {
    List<Widget> widgets = <Widget>[];
    widgets.addAll(this.widget.actions);
    widgets.addAll(
      <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: this.widget.onRefresh,
          tooltip: 'refresh',
        ),
        IconButton(
          icon: Icon(Icons.bug_report_outlined),
          onPressed: _bugReporting,
          tooltip: 'report',
        ),
      ],
    );
    if (this.widget.onSignOut == null) return widgets;
    widgets.add(
      IconButton(
        icon: Icon(Icons.logout),
        onPressed: this.widget.onSignOut,
        tooltip: 'logout',
      ),
    );
    return widgets;
  }

  AppBar _appBar() {
    return AppBar(
      title: Text(this.widget.title ?? ''),
      actions: _actions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: this.widget.showAppBar ? _appBar() : null,
      body: this.widget.body ?? Container(),
    );
  }
}
