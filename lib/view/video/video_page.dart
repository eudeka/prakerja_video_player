import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../model/menu_item.dart';
import '../../model/youtube_embed.dart';
import '../../network/api_client.dart';
import '../../provider/video_provider.dart';
import '../../tool/format.dart';
import '../../tool/player.dart';
import '../../widget/app_scaffold.dart';

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  String _id = '';
  String _title = '';
  VideoPlayerController _controller;
  VideoPlayerValue _value;
  double _aspectRatio = 2.5;
  Duration _duration = Duration();

  String get _url => context.read<VideoProvider>().getLastUrl();

  void _setTitle() async {
    YoutubeEmbed embed = await ApiClient.getVideoInfo(_id);
    _title = embed.title;
    setState(() {});
  }

  void _refresh({bool reset = false}) async {
    _controller.pause();
    if (reset) {
      Box box = await Hive.openBox('last_duration');
      await box.delete(_id);
    }
    _initializePlayer();
  }

  void _getLastDuration() async {
    Box box = await Hive.openBox('last_duration');
    String textDuration = box.get(_id);
    Duration duration = textDuration.decode().toDuration();
    _duration = duration == null ? Duration() : duration;
    await _controller.seekTo(_duration);
    setState(() {});
  }

  void _saveDuration(Duration duration) async {
    if (duration == Duration() || duration == null) return;
    Box box = await Hive.openBox('last_duration');
    String text = box.get(_id);
    if (text != null) {
      Duration last = text.decode().toDuration();
      int compare = duration.inSeconds - last.inSeconds;
      if (compare > 1) await _controller.seekTo(last);
    }
    await box.put(_id, duration.toString().encode());
  }

  Widget _bannerVideo({bool isPlaying = false}) {
    return Container(
      color: isPlaying ? Colors.transparent : Colors.black.withOpacity(0.25),
      child: !isPlaying
          ? Center(
              child: Icon(
                Icons.play_arrow,
                size: _aspectRatio * 96,
                color: Colors.red,
              ),
            )
          : Container(),
    );
  }

  List<Widget> _stackChildren() {
    List<Widget> children = <Widget>[
      Container(color: Colors.black45),
      VideoPlayer(_controller),
      VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
      ),
    ];
    if (_value == null) {
      children.add(Center(child: CircularProgressIndicator()));
    } else {
      children.addAll(
        <Widget>[
          AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            child: _bannerVideo(isPlaying: _value?.isPlaying ?? false),
          ),
          GestureDetector(
            onTap: () async => _value != null
                ? _value.isPlaying
                    ? await _controller.pause()
                    : await _controller.play()
                : null,
          ),
        ],
      );
    }
    return children;
  }

  void _initializePlayer() async {
    for (VideoYoutubeQuality quality in VideoYoutubeQuality.values) {
      try {
        await _controller.initialize(quality: quality);
        _controller.addListener(_controllerListener);
        break;
      } catch (e) {}
    }
    _getLastDuration();
  }

  void _controllerListener() {
    _value = _controller.value;
    _aspectRatio = _value.aspectRatio;
    double ratio = MediaQuery.of(context).size.aspectRatio + 0.5;
    if (_aspectRatio <= ratio) _aspectRatio = ratio;
    _saveDuration(_value.position);
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    duration ??= Duration();
    return '$duration'.split('.')[0];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _id = _url.split('youtu.be/')[1];
    _setTitle();
    _controller = VideoPlayerController.network(_url);
    _initializePlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      actions: <MenuItem>[
        MenuItem(
          label: 'Reset',
          onTap: () => _refresh(reset: true),
        ),
      ],
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: _aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: _stackChildren(),
            ),
          ),
          ListTile(
            title: Text(
              '$_title (${_formatDuration(_value?.position)}'
              ' / ${_formatDuration(_value?.duration)})',
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
