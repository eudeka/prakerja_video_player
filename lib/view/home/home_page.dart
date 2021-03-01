import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/constant.dart';
import '../../model/student.dart';
import '../../network/api_client.dart';
import '../../provider/account_provider.dart';
import '../../widget/app_scaffold.dart';
import 'home_courses.dart';

class HomePage extends StatelessWidget {
  Widget get _notFound {
    return GestureDetector(
      onTap: () async => await launch(Constant.whatsapp),
      child: Text(
        Constant.dataNotFound,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Consumer<AccountProvider>(
        builder: (
          BuildContext context,
          AccountProvider account,
          Widget child,
        ) {
          return Center(
            child: FutureBuilder<Student>(
              future: ApiClient.getStudent(account.user.email),
              builder: (
                BuildContext context,
                AsyncSnapshot<Student> snapshot,
              ) {
                if (snapshot.hasData) {
                  Student student = snapshot.data;
                  if (student.result.isEmpty) return _notFound;
                  return HomeCourses(student: student);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return CircularProgressIndicator.adaptive();
                }
              },
            ),
          );
        },
      ),
      showBack: false,
    );
  }
}
