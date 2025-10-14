class PollModel {
  final String pollToken;
  final String title;
  final String? description;
  final String? startDate;
  final String? endDate;
  final bool? active;

  PollModel({
    required this.pollToken,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.active,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      pollToken: json['pollToken'] ?? '',
      title: json['title'] ?? 'Encuesta sin título',
      description: json['description'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pollToken': pollToken,
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'active': active,
    };
  }
}
