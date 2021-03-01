import 'package:flutter/widgets.dart';

class MenuItem {
  String label;
  Widget child;
  VoidCallback onTap;

  MenuItem({
    @required this.label,
    this.child,
    this.onTap,
  });

  @override
  String toString() {
    return 'MenuItem{label: $label, child: $child, onTap: $onTap}';
  }
}
