import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_route.dart';
import '../model/menu_item.dart';
import '../provider/account_provider.dart';
import '../provider/theme_provider.dart';
import '../view/login/login_page.dart';
import 'dialog_logout.dart';

class AppScaffold extends StatelessWidget {
  final List<MenuItem> actions;
  final Widget body;
  final bool showBack;

  AppScaffold({
    Key key,
    this.actions = const <MenuItem>[],
    this.body = const SizedBox(),
    this.showBack = true,
  }) : super(key: key);

  bool get _canPop => AppRoute.navigator.canPop();

  List<MenuItem> get _items {
    return <MenuItem>[
      ...this.actions,
      MenuItem(label: 'Switch Theme'),
      MenuItem(label: 'Logout'),
    ];
  }

  List<PopupMenuEntry<MenuItem>> get _menus {
    return List<PopupMenuEntry<MenuItem>>.generate(
      _items.length,
      (int index) => PopupMenuItem(
        value: _items[index],
        child: Text(_items[index].label),
      ),
    );
  }

  List<Widget> _children(BuildContext context, String email) {
    return <Widget>[
      _canPop && showBack
          ? BackButton()
          : Image.network('images/eudeka_logo.png'),
      Spacer(),
      PopupMenuButton<MenuItem>(
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<MenuItem>>[
            ..._menus,
            PopupMenuItem(
              enabled: false,
              child: Text(email),
            ),
          ];
        },
        onSelected: (MenuItem item) {
          switch (item.label) {
            case 'Switch Theme':
              return context.read<ThemeProvider>().change();
            case 'Logout':
              return DialogLogout(context).show();
            default:
              return item.onTap?.call();
          }
        },
      ),
    ];
  }

  Widget _appBar(BuildContext context, {AccountProvider provider}) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: kToolbarHeight,
        child: Row(
          children: this._children(
            context,
            provider.user.email,
          ),
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColorLight,
      child: Text('Copyright Eudeka 2021'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (
        BuildContext context,
        AccountProvider account,
        Widget child,
      ) {
        if (account.user == null) return LoginPage();
        return Column(
          children: <Widget>[
            _appBar(
              context,
              provider: account,
            ),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  children: <Widget>[
                    this.body,
                    this._footer(context),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
