import 'package:flutter/foundation.dart';

class VideoProvider extends ChangeNotifier {
  String _lastUrl = '';

  String getLastUrl() => _lastUrl;

  void setLastUrl(String url) => _lastUrl = url;
}
