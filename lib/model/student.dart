import 'dart:convert';

class Student {
  Student({
    this.code,
    this.result,
  });

  int code;
  List<Result> result;

  factory Student.fromJson(String str) => Student.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Student.fromMap(Map<String, dynamic> json) => Student(
        code: json["code"],
        result: List<Result>.from(json["result"].map((x) => Result.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "result": List<dynamic>.from(result.map((x) => x.toMap())),
      };

  @override
  String toString() => toJson();
}

class Result {
  Result({
    this.name,
    this.email,
    this.voucher,
    this.course,
  });

  String name;
  String email;
  String voucher;
  Course course;

  factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Result.fromMap(Map<String, dynamic> json) => Result(
        name: json["name"],
        email: json["email"],
        voucher: json["voucher"],
        course: Course.fromMap(json["course"]),
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "email": email,
        "voucher": voucher,
        "course": course.toMap(),
      };

  @override
  String toString() => toJson();
}

class Course {
  Course({
    this.sku,
    this.title,
    this.videos,
  });

  String sku;
  String title;
  List<String> videos;

  factory Course.fromJson(String str) => Course.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Course.fromMap(Map<String, dynamic> json) => Course(
        sku: json["sku"],
        title: json["title"],
        videos: List<String>.from(json["videos"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "sku": sku,
        "title": title,
        "videos": List<dynamic>.from(videos.map((x) => x)),
      };

  @override
  String toString() => toJson();
}
