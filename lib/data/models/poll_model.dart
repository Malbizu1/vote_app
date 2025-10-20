class PollModel {
  final String? token;
  final String? title;
  final String? description;

  PollModel({this.token, this.title, this.description});

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      token: json['token']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
