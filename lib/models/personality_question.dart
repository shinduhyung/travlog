class PersonalityQuestion {
  final int id;
  final String text;
  final Map<String, double> weights;

  PersonalityQuestion({
    required this.id,
    required this.text,
    required this.weights,
  });

  factory PersonalityQuestion.fromJson(Map<String, dynamic> json) {
    return PersonalityQuestion(
      id: json['id'],
      text: json['text'],
      weights: Map<String, double>.from(json['weights'].map(
            (key, value) => MapEntry(key, value.toDouble()),
      )),
    );
  }
}