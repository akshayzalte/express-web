class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime dateCreated;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.dateCreated,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      isRead: json['isRead'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'dateCreated': dateCreated.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      dateCreated: dateCreated,
      isRead: isRead ?? this.isRead,
    );
  }
}
