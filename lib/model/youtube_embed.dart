import 'dart:convert';

class YoutubeEmbed {
  YoutubeEmbed({
    this.authorUrl,
    this.providerName,
    this.height,
    this.thumbnailUrl,
    this.title,
    this.type,
    this.version,
    this.authorName,
    this.html,
    this.thumbnailWidth,
    this.providerUrl,
    this.thumbnailHeight,
    this.width,
  });

  String authorUrl;
  String providerName;
  int height;
  String thumbnailUrl;
  String title;
  String type;
  String version;
  String authorName;
  String html;
  int thumbnailWidth;
  String providerUrl;
  int thumbnailHeight;
  int width;

  factory YoutubeEmbed.fromJson(String str) =>
      YoutubeEmbed.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory YoutubeEmbed.fromMap(Map<String, dynamic> json) => YoutubeEmbed(
        authorUrl: json["author_url"],
        providerName: json["provider_name"],
        height: json["height"],
        thumbnailUrl: json["thumbnail_url"],
        title: json["title"],
        type: json["type"],
        version: json["version"],
        authorName: json["author_name"],
        html: json["html"],
        thumbnailWidth: json["thumbnail_width"],
        providerUrl: json["provider_url"],
        thumbnailHeight: json["thumbnail_height"],
        width: json["width"],
      );

  Map<String, dynamic> toMap() => {
        "author_url": authorUrl,
        "provider_name": providerName,
        "height": height,
        "thumbnail_url": thumbnailUrl,
        "title": title,
        "type": type,
        "version": version,
        "author_name": authorName,
        "html": html,
        "thumbnail_width": thumbnailWidth,
        "provider_url": providerUrl,
        "thumbnail_height": thumbnailHeight,
        "width": width,
      };
}
