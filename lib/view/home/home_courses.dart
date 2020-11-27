import 'package:flutter/material.dart';

import '../../model/student.dart';
import '../../model/youtube_embed.dart';
import '../../network/api_client.dart';
import '../video/video_page.dart';

class HomeCourses extends StatefulWidget {
  final Student student;

  const HomeCourses({
    Key key,
    @required this.student,
  }) : super(key: key);

  @override
  _HomeCoursesState createState() => _HomeCoursesState();
}

class _HomeCoursesState extends State<HomeCourses> {
  List<Result> _listResult = <Result>[];
  List<List<String>> _listOfTitle = <List<String>>[];

  Widget _tile({Widget title, VoidCallback onTap}) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        width: double.infinity,
        child: title,
      ),
      onTap: onTap,
    );
  }

  Widget _itemCourse(BuildContext context, int i) {
    Result result = _listResult[i];
    List<String> contents = <String>[
      'Name : ${result.name}',
      'Email : ${result.email}',
      'Voucher : ${result.voucher}',
      'Course : ${result.course.title}',
    ];
    List<Widget> children = List<Widget>.generate(
      contents.length,
      (int index) => _tile(
        title: Text(contents[index]),
      ),
    );
    List<String> listTitle = _listOfTitle.length == _listResult.length
        ? _listOfTitle[i]
        : <String>[];
    List<Widget> videos = List.generate(
      listTitle.length,
      (int index) => _tile(
        title: Text(
          'Video ${index + 1} : ${listTitle[index] ?? ''}',
          style: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => VideoPage(
              url: result.course.videos[index],
              student: result,
            ),
          ),
        ),
      ),
    );
    children.addAll(videos);
    return Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
      ),
      child: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  void _initTitle() async {
    for (Result result in _listResult) {
      List<String> listTitle = <String>[];
      for (String url in result.course.videos) {
        YoutubeEmbed embed = await ApiClient.getVideoInfo(
          url.split('youtu.be/')[1],
        );
        listTitle.add(embed.title);
      }
      _listOfTitle.add(listTitle);
    }
    setState(() {});
  }

  @override
  void initState() {
    _listResult = widget.student.result;
    _initTitle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: _itemCourse(context, index),
        );
      },
      itemCount: _listResult.length,
    );
  }
}
