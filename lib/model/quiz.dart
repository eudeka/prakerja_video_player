import 'dart:convert';

List<Quiz> quizFromMap(String str) =>
    List<Quiz>.from(json.decode(str).map((x) => Quiz.fromMap(x)));

String quizToMap(List<Quiz> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Quiz {
  Quiz({
    this.number,
    this.question,
    this.answerA,
    this.answerB,
    this.answerC,
    this.answerD,
    this.correct,
  });

  int number;
  String question;
  String answerA;
  String answerB;
  String answerC;
  String answerD;
  String correct;

  factory Quiz.fromJson(String str) => Quiz.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Quiz.fromMap(Map<String, dynamic> json) => Quiz(
        number: json["number"],
        question: json["question"].toString(),
        answerA: json["answerA"].toString(),
        answerB: json["answerB"].toString(),
        answerC: json["answerC"].toString(),
        answerD: json["answerD"].toString(),
        correct: json["correct"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "number": number,
        "question": question,
        "answerA": answerA,
        "answerB": answerB,
        "answerC": answerC,
        "answerD": answerD,
        "correct": correct,
      };

  @override
  String toString() => toJson();
}

class QuizValue {
  QuizValue({
    this.number = -1,
    this.answer = '',
    this.isCorrect = false,
  });

  int number;
  String answer;
  bool isCorrect;

  factory QuizValue.fromJson(String str) => QuizValue.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory QuizValue.fromMap(Map<String, dynamic> json) => QuizValue(
        number: json["number"],
        answer: json["answer"],
        isCorrect: json["isCorrect"],
      );

  Map<String, dynamic> toMap() => {
        "number": number,
        "answer": answer,
        "isCorrect": isCorrect,
      };

  @override
  String toString() => toJson();
}
