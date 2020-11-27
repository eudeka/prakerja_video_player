/// Clone of [https://github.com/ponnamkarthik/ext_video_player],
/// with last commit a1680cd71f7198a3396561f81a881d5433174652 (Jul 29, 2020).
/// Please read [https://pub.dev/packages/ext_video_player] for documentation.
/// Will be going back to using that after fully supporting YouTube videos.
///
/// LICENSED UNDER The BSD 3-Clause "New" or "Revised" License
///
/// Copyright 2017 The Chromium Authors. All rights reserved.
///
/// Redistribution and use in source and binary forms, with or without modification,
/// are permitted provided that the following conditions are met:
///
///     * Redistributions of source code must retain the above copyright
///       notice, this list of conditions and the following disclaimer.
///     * Redistributions in binary form must reproduce the above
///       copyright notice, this list of conditions and the following
///       disclaimer in the documentation and/or other materials provided
///       with the distribution.
///     * Neither the name of Google Inc. nor the names of its
///       contributors may be used to endorse or promote products derived
///       from this software without specific prior written permission.
///
/// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
/// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
/// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
/// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
/// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
/// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
/// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
/// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
/// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
/// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

enum VideoYoutubeQuality {
  hd1080,
  hd720,
  large,
  medium,
  small,
  tiny,
}

final VideoPlayerPlatform _videoPlayerPlatform = VideoPlayerPlatform.instance
  ..init();

class VideoPlayerValue {
  VideoPlayerValue({
    @required this.duration,
    this.size,
    this.position = const Duration(),
    this.buffered = const <DurationRange>[],
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.errorDescription,
  });

  VideoPlayerValue.uninitialized() : this(duration: null);

  VideoPlayerValue.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  final Duration duration;

  final Duration position;

  final List<DurationRange> buffered;

  final bool isPlaying;

  final bool isLooping;

  final bool isBuffering;

  final double volume;

  final String errorDescription;

  final Size size;

  bool get initialized => duration != null;

  bool get hasError => errorDescription != null;

  double get aspectRatio {
    if (size == null || size.width == 0 || size.height == 0) return 1.0;
    final double aspectRatio = size.width / size.height;
    if (aspectRatio <= 0) return 1.0;
    return aspectRatio;
  }

  VideoPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    List<DurationRange> buffered,
    bool isPlaying,
    bool isLooping,
    bool isBuffering,
    double volume,
    String errorDescription,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }
}

class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  VideoPlayerController.asset(this.dataSource, {this.package})
      : dataSourceType = DataSourceType.asset,
        formatHint = null,
        super(VideoPlayerValue(duration: null));

  VideoPlayerController.network(this.dataSource, {this.formatHint})
      : dataSourceType = DataSourceType.network,
        package = null,
        super(VideoPlayerValue(duration: null));

  int _textureId;

  final String dataSource;

  final VideoFormat formatHint;

  final DataSourceType dataSourceType;

  final String package;

  Timer _timer;
  bool _isDisposed = false;
  Completer<void> _creatingCompleter;
  StreamSubscription<dynamic> _eventSubscription;
  _VideoAppLifeCycleObserver _lifeCycleObserver;

  @visibleForTesting
  int get textureId => _textureId;

  Future<void> initialize({
    VideoYoutubeQuality quality = VideoYoutubeQuality.medium,
  }) async {
    _lifeCycleObserver = _VideoAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = Completer<void>();

    String finalYoutubeUrl = dataSource;
    if (_getIdFromUrl(dataSource) != null) {
      try {
        Map<String, String> videoUrls = Map();
        String _videoId = _getIdFromUrl(dataSource);
        String _fetchUrl = "";
        if (kIsWeb) {
          _fetchUrl = "https://youtubevideodownloadurls.netlify.app/"
              ".netlify/functions/server?vid=$_videoId";
        } else {
          _fetchUrl = "https://www.youtube.com/get_video_info?"
              "&video_id=$_videoId";
        }
        var dio = Dio(BaseOptions(responseType: ResponseType.plain));
        var response = await dio.get(_fetchUrl);

        Uri uri = Uri.parse('http://google.com?' + response.data);
        var jsonRes = jsonDecode(uri.queryParameters['player_response']);
        var formats = jsonRes['streamingData']['formats'];
        formats.forEach((format) {
          if (videoUrls[format['quality']] == null) {
            videoUrls[format['quality']] = format['url'];
          }
        });
        String newUrl = videoUrls[quality.toString().split('.').last];

        List<VideoYoutubeQuality> qualityValues = VideoYoutubeQuality.values;
        if (newUrl == null) {
          for (int i = quality.index + 1; i < qualityValues.length; i++) {
            newUrl = videoUrls[qualityValues[i].toString().split('.').last];
          }
        }
        if (newUrl == null) {
          for (int i = quality.index - 1; i >= 0; i--) {
            newUrl = videoUrls[qualityValues[i].toString().split('.').last];
          }
        }
        if (newUrl != null) finalYoutubeUrl = newUrl;
      } catch (err) {}
    }

    DataSource dataSourceDescription;
    switch (dataSourceType) {
      case DataSourceType.asset:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.asset,
          asset: dataSource,
          package: package,
        );
        break;
      case DataSourceType.network:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.network,
          uri: finalYoutubeUrl,
          formatHint: formatHint,
        );
        break;
      case DataSourceType.file:
        dataSourceDescription = DataSource(
          sourceType: DataSourceType.file,
          uri: dataSource,
        );
        break;
    }
    _textureId = await _videoPlayerPlatform.create(dataSourceDescription);
    _creatingCompleter.complete(null);
    final Completer<void> initializingCompleter = Completer<void>();

    void eventListener(VideoEvent event) {
      if (_isDisposed) return;

      switch (event.eventType) {
        case VideoEventType.initialized:
          value = value.copyWith(
            duration: event.duration,
            size: event.size,
          );
          initializingCompleter.complete(null);
          _applyLooping();
          _applyVolume();
          _applyPlayPause();
          break;
        case VideoEventType.completed:
          value = value.copyWith(isPlaying: false, position: value.duration);
          _timer?.cancel();
          break;
        case VideoEventType.bufferingUpdate:
          value = value.copyWith(buffered: event.buffered);
          break;
        case VideoEventType.bufferingStart:
          value = value.copyWith(isBuffering: true);
          break;
        case VideoEventType.bufferingEnd:
          value = value.copyWith(isBuffering: false);
          break;
        case VideoEventType.unknown:
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj;
      value = VideoPlayerValue.erroneous(e.message);
      _timer?.cancel();
      if (!initializingCompleter.isCompleted) {
        initializingCompleter.completeError(obj);
      }
    }

    _eventSubscription = _videoPlayerPlatform
        .videoEventsFor(_textureId)
        .listen(eventListener, onError: errorListener);
    return initializingCompleter.future;
  }

  static String _getIdFromUrl(String url, [bool trimWhitespaces = true]) {
    List<RegExp> _regexps = [
      RegExp(
        r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$',
      ),
      RegExp(
        r'^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$',
      ),
      RegExp(
        r'^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$',
      )
    ];

    if (url == null || url.isEmpty) return null;

    if (trimWhitespaces) url = url.trim();

    for (RegExp exp in _regexps) {
      final Match match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  @override
  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!_isDisposed) {
        _isDisposed = true;
        _timer?.cancel();
        await _eventSubscription?.cancel();
        await _videoPlayerPlatform.dispose(_textureId);
      }
      _lifeCycleObserver.dispose();
    }
    _isDisposed = true;
    super.dispose();
  }

  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
  }

  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLooping();
  }

  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
  }

  Future<void> _applyLooping() async {
    if (!value.initialized || _isDisposed) return;
    await _videoPlayerPlatform.setLooping(_textureId, value.isLooping);
  }

  Future<void> _applyPlayPause() async {
    if (!value.initialized || _isDisposed) return;
    if (value.isPlaying) {
      await _videoPlayerPlatform.play(_textureId);
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer timer) async {
          if (_isDisposed) return;
          final Duration newPosition = await position;
          if (_isDisposed) return;
          _updatePosition(newPosition);
        },
      );
    } else {
      _timer?.cancel();
      await _videoPlayerPlatform.pause(_textureId);
    }
  }

  Future<void> _applyVolume() async {
    if (!value.initialized || _isDisposed) return;
    await _videoPlayerPlatform.setVolume(_textureId, value.volume);
  }

  Future<Duration> get position async {
    if (_isDisposed) return null;
    return await _videoPlayerPlatform.getPosition(_textureId);
  }

  Future<void> seekTo(Duration position) async {
    if (_isDisposed) return;
    if (position > value.duration) {
      position = value.duration;
    } else if (position < const Duration()) {
      position = const Duration();
    }
    await _videoPlayerPlatform.seekTo(_textureId, position);
    _updatePosition(position);
  }

  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume.clamp(0.0, 1.0));
    await _applyVolume();
  }

  void _updatePosition(Duration position) {
    value = value.copyWith(position: position);
  }
}

class _VideoAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  _VideoAppLifeCycleObserver(this._controller);

  bool _wasPlayingBeforePause = false;
  final VideoPlayerController _controller;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) _controller.play();
        break;
      default:
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

class VideoPlayer extends StatefulWidget {
  VideoPlayer(this.controller);

  final VideoPlayerController controller;

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState() {
    _listener = () {
      final int newTextureId = widget.controller.textureId;
      if (newTextureId != _textureId) {
        _textureId = newTextureId;
        setState(() {});
      }
    };
  }

  VoidCallback _listener;
  int _textureId;

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_listener);
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return _textureId == null
        ? Container()
        : _videoPlayerPlatform.buildView(_textureId);
  }
}

class VideoProgressColors {
  VideoProgressColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
  });

  final Color playedColor;

  final Color bufferedColor;

  final Color backgroundColor;
}

class _VideoScrubber extends StatefulWidget {
  _VideoScrubber({
    @required this.child,
    @required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) return;
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) controller.pause();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) return;
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) controller.play();
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) return;
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

class VideoProgressIndicator extends StatefulWidget {
  VideoProgressIndicator(
    this.controller, {
    VideoProgressColors colors,
    this.allowScrubbing = false,
    this.padding = EdgeInsets.zero,
  }) : colors = colors ?? VideoProgressColors();

  final VideoPlayerController controller;

  final VideoProgressColors colors;

  final bool allowScrubbing;

  final EdgeInsets padding;

  @override
  _VideoProgressIndicatorState createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  _VideoProgressIndicatorState() {
    listener = () {
      if (!mounted) return;
      setState(() {});
    };
  }

  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.initialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) maxBuffering = end;
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          CustomLinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return _VideoScrubber(
        child: paddedProgressIndicator,
        controller: controller,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}

const int _kIndeterminateLinearDuration = 1800;

class CustomLinearProgressIndicator extends ProgressIndicator {
  const CustomLinearProgressIndicator({
    Key key,
    double value,
    Color backgroundColor,
    this.bubbleRadius = 4.0,
    Animation<Color> valueColor,
    this.minHeight,
    String semanticsLabel,
    String semanticsValue,
  })  : assert(minHeight == null || minHeight > 0),
        super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

  final double minHeight;
  final double bubbleRadius;

  @override
  _CustomLinearProgressIndicatorState createState() =>
      _CustomLinearProgressIndicatorState();
}

class _CustomLinearProgressIndicatorState
    extends State<CustomLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kIndeterminateLinearDuration),
      vsync: this,
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(CustomLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator(
    BuildContext context,
    double animationValue,
    TextDirection textDirection,
  ) {
    return Container(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: widget.minHeight ?? 4.0,
      ),
      child: CustomPaint(
        painter: _LinearProgressIndicatorPainter(
          backgroundColor:
              widget.backgroundColor ?? Theme.of(context).backgroundColor,
          valueColor: widget.valueColor?.value ?? Theme.of(context).accentColor,
          value: widget.value,
          animationValue: animationValue,
          textDirection: textDirection,
          bubbleRadius: widget.bubbleRadius,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    if (widget.value != null) {
      return _buildIndicator(context, _controller.value, textDirection);
    }

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget child) {
        return _buildIndicator(context, _controller.value, textDirection);
      },
    );
  }
}

class _LinearProgressIndicatorPainter extends CustomPainter {
  const _LinearProgressIndicatorPainter({
    this.backgroundColor,
    this.valueColor,
    this.value,
    this.bubbleRadius,
    this.animationValue,
    @required this.textDirection,
  }) : assert(textDirection != null);

  final Color backgroundColor;
  final Color valueColor;
  final double value;
  final double bubbleRadius;
  final double animationValue;
  final TextDirection textDirection;

  static const Curve line1Head = Interval(
    0.0,
    750.0 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / _kIndeterminateLinearDuration,
    (333.0 + 750.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / _kIndeterminateLinearDuration,
    (1000.0 + 567.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / _kIndeterminateLinearDuration,
    (1267.0 + 533.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    final indicatorPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    paint.color = valueColor;
    indicatorPaint.color = valueColor;

    void drawBar(double x, double width) {
      if (width <= 0.0) return;

      double left;
      switch (textDirection) {
        case TextDirection.rtl:
          left = size.width - width - x;
          break;
        case TextDirection.ltr:
          left = x;
          break;
      }
      canvas.drawRect(Offset(left, 0.0) & Size(width, size.height), paint);
    }

    void drawIndicator(double x, double width) {
      if (width <= 0.0) return;
      canvas.drawCircle(Offset(width, 1.5), bubbleRadius, paint);
    }

    if (value != null) {
      drawBar(0.0, value.clamp(0.0, 1.0) * size.width as double);
      drawIndicator(0.0, value.clamp(0.0, 1.0) * size.width as double);
    } else {
      final double x1 = size.width * line1Tail.transform(animationValue);
      final double width1 =
          size.width * line1Head.transform(animationValue) - x1;

      final double x2 = size.width * line2Tail.transform(animationValue);
      final double width2 =
          size.width * line2Head.transform(animationValue) - x2;

      drawBar(x1, width1);
      drawIndicator(x1, width1);
      drawBar(x2, width2);
    }
  }

  @override
  bool shouldRepaint(_LinearProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.animationValue != animationValue ||
        oldPainter.textDirection != textDirection;
  }
}
