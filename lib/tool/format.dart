import 'dart:convert';

extension FormatDuration on String {
  Duration toDuration() {
    if (this == null) return Duration();
    List<String> splitter = this.split('.')[0].split(':');
    if (splitter.length != 3) throw 'Unknown format: $this';
    return Duration(
      hours: int.tryParse(splitter[0]),
      minutes: int.tryParse(splitter[1]),
      seconds: int.tryParse(splitter[2]),
      microseconds: int.tryParse(this.split('.')[1]),
    );
  }

  String encode() {
    if (this == null) return null;
    return base64Encode(utf8.encode(this));
  }

  String decode() {
    if (this == null) return null;
    return utf8.decode(base64Decode(this));
  }
}
