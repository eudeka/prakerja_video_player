import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/constant.dart';

class HomeNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => await launch(Constant.whatsapp),
      child: Text(
        Constant.dataNotFound,
        textAlign: TextAlign.center,
      ),
    );
  }
}
